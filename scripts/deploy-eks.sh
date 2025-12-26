#!/bin/bash
# deploy-eks.sh
# Déploiement complet de Spring PetClinic sur AWS EKS
# Prérequis : AWS CLI configuré, eksctl, kubectl, docker, helm

set -e

echo "🚀 Démarrage du déploiement EKS pour PetClinic"

# === CONFIGURATION ===
CLUSTER_NAME="petclinic-prod"
REGION="eu-north-1"
NAMESPACE="petclinic"
REPO_NAME="petclinic"
IMAGE_TAG="1.0"
NODE_TYPE="c7i-flex.large"
SSH_KEY_NAME="docker-host-m1resi-kp"  # doit exister dans AWS

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# === 1. CRÉER LE CLUSTER EKS ===
echo "🔧 Création du cluster EKS..."
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --version 1.30 \
  --nodes 2 \
  --node-type $NODE_TYPE \
  --nodes-min 1 \
  --nodes-max 3 \
  --ssh-access \
  --ssh-public-key "$SSH_KEY_NAME" \
  --managed

# === 2. INSTALLER LE CSI DRIVER EBS ===
echo "🔧 Installation du CSI driver EBS..."
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --region $REGION --approve

eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster $CLUSTER_NAME \
  --role-name "$CLUSTER_NAME-ebs-csi-role" \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --region $REGION

helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm upgrade --install aws-ebs-csi-driver \
  --namespace kube-system \
  aws-ebs-csi-driver/aws-ebs-csi-driver \
  --set controller.serviceAccount.name=ebs-csi-controller-sa \
  --set node.serviceAccount.name=ebs-csi-controller-sa

# === 3. CRÉER LE REPO ECR ET POUSSER L'IMAGE ===
echo "📦 Build et push de l'image PetClinic vers ECR..."
aws ecr create-repository --repository-name $REPO_NAME --region $REGION >/dev/null 2>&1 || true
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

# Construire l'image (suppose que le Dockerfile est dans ./docker)
docker build -t petclinic:$IMAGE_TAG -f docker/Dockerfile .

docker tag petclinic:$IMAGE_TAG $ECR_URI/$REPO_NAME:$IMAGE_TAG
docker push $ECR_URI/$REPO_NAME:$IMAGE_TAG

# === 4. METTRE À JOUR LES MANIFESTS ===
echo "📝 Mise à jour des manifests avec l'image ECR..."
sed -i "s|image: petclinic:1.0|image: $ECR_URI/$REPO_NAME:$IMAGE_TAG|" kubernetes/petclinic/petclinic-deployment.yaml
sed -i "s|imagePullPolicy: IfNotPresent|imagePullPolicy: Always|" kubernetes/petclinic/petclinic-deployment.yaml

# === 5. DÉPLOYER L'APPLICATION ===
echo "🚀 Déploiement de PetClinic..."
kubectl apply -f kubernetes/namespace.yaml

# MySQL
kubectl apply -f kubernetes/mysql/mysql-secret.yaml
kubectl apply -f kubernetes/mysql/mysql-pvc.yaml    # doit utiliser storageClassName: gp2
kubectl apply -f kubernetes/mysql/mysql-statefulset.yaml

echo "⏳ Attente de MySQL (max 5 min)..."
kubectl wait --for=condition=ready pod/mysql-0 -n $NAMESPACE --timeout=300s

# PetClinic
kubectl apply -f kubernetes/petclinic/

# Ingress
kubectl apply -f kubernetes/ingress/petclinic-ingress.yaml

# ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

echo "⏳ Attente de l'Ingress (max 2 min)..."
sleep 30
while [ -z "$(kubectl get ingress petclinic-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')" ]; do
  echo "  Ingress en cours de création... réessai dans 15s"
  sleep 15
done

# === 6. AFFICHER LES RÉSULTATS ===
ELB_HOST=$(kubectl get ingress petclinic-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo ""
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo "--------------------------------------------------"
echo "🌐 Accède à PetClinic ici : http://$ELB_HOST"
echo "📋 Pods : kubectl get pods -n $NAMESPACE"
echo "📊 Ingress : kubectl get ingress -n $NAMESPACE"
echo "--------------------------------------------------"
echo "💡 Astuce : garde ce terminal ouvert pour copier l'URL !"