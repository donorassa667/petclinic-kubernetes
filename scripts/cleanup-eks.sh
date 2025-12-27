#!/bin/bash
# cleanup-eks.sh
# Nettoyage complet des ressources AWS créées par deploy-eks.sh
# Compatible avec EKS 1.32

set -e

echo "🧹 Nettoyage complet du projet PetClinic sur AWS EKS"

# === CONFIGURATION ===
CLUSTER_NAME="petclinic-prod"
REGION="eu-north-1"
REPO_NAME="petclinic"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# === 1. SUPPRIMER LE CLUSTER EKS ===
echo "🗑️  Suppression du cluster EKS..."
if eksctl get cluster --name $CLUSTER_NAME --region $REGION &>/dev/null; then
  eksctl delete cluster --name $CLUSTER_NAME --region $REGION
  echo "✅ Cluster EKS supprimé"
else
  echo "ℹ️  Cluster EKS non trouvé (déjà supprimé ?)"
fi

# === 2. SUPPRIMER LE REPO ECR ===
echo "🗑️  Suppression du repository ECR..."
if aws ecr describe-repositories --repository-names $REPO_NAME --region $REGION &>/dev/null; then
  aws ecr delete-repository --repository-name $REPO_NAME --region $REGION --force
  echo "✅ Repository ECR supprimé"
else
  echo "ℹ️  Repository ECR non trouvé"
fi

# === 3. SUPPRIMER LES RÔLES IAM ===
ROLES_TO_DELETE=(
  "${CLUSTER_NAME}-ebs-csi-role"
  "${CLUSTER_NAME}-cloudwatch-role"
)

for ROLE in "${ROLES_TO_DELETE[@]}"; do
  echo "🗑️  Suppression du rôle IAM: $ROLE..."
  if aws iam get-role --role-name $ROLE --region $REGION &>/dev/null; then
    # Récupère les politiques attachées
    POLICIES=$(aws iam list-attached-role-policies --role-name $ROLE --query 'AttachedPolicies[].PolicyArn' --output text --region $REGION)
    for POLICY in $POLICIES; do
      aws iam detach-role-policy --role-name $ROLE --policy-arn $POLICY --region $REGION
    done
    aws iam delete-role --role-name $ROLE --region $REGION
    echo "✅ Rôle IAM $ROLE supprimé"
  else
    echo "ℹ️  Rôle IAM $ROLE non trouvé"
  fi
done

# === 4. SUPPRIMER LE PROVIDER OIDC (si plus aucun cluster EKS dans le compte) ===
echo "🗑️  Nettoyage du provider OIDC..."
OIDC_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text 2>/dev/null | sed 's/https:\/\///' || echo "")
if [ -n "$OIDC_URL" ]; then
  OIDC_ARN="arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_URL"
  if aws iam get-open-id-connect-provider --open-id-connect-provider-arn $OIDC_ARN &>/dev/null; then
    aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $OIDC_ARN --region $REGION
    echo "✅ Provider OIDC supprimé"
  fi
else
  echo "ℹ️  Aucun provider OIDC à supprimer"
fi

# === 5. NETTOYER LES RESSOURCES KUBERNETES (si cluster encore actif) ===
echo "🗑️  Nettoyage des ressources Kubernetes (monitoring)..."
kubectl delete namespace amazon-cloudwatch 2>/dev/null || true

# === 6. NETTOYER LES FICHIERS LOCAUX ===
rm -f cwagent-fluentd-quickstart.yaml trust-policy.json

echo ""
echo "✅ Nettoyage terminé !"
echo "💡 Coût estimé à partir de maintenant : ~\$0/jour"
echo "🚀 Tu peux relancer ./scripts/deploy-eks.sh à tout moment pour repartir."