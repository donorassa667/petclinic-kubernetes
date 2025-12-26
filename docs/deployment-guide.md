# Guide de déploiement – Spring PetClinic sur AWS EKS

Ce guide décrit **pas à pas** le déploiement sur **AWS EKS** (remplace Minikube).

---

## 1. Préparation AWS

### 1.1 Permissions IAM
Accorder temporairement **`AdministratorAccess`** à l’utilisateur `kals`.

### 1.2 Clé SSH
Assurez-vous que la clé **`docker-host-m1resi-kp`** existe dans EC2 → Key Pairs.

---

## 2. Préparation de la machine de gestion

> Peut être une instance EC2 ou ta machine locale (avec AWS CLI configuré)

### 2.1 Installer les outils
```bash
# AWS CLI, eksctl, kubectl, helm, docker
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip && sudo ./aws/install

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

sudo apt install -y docker.io
sudo usermod -aG docker $USER && newgrp docker

2.2 Configurer AWS CLI
aws configure
# AWS Access Key, Secret, région eu-north-1

3. Déploiement
3.1 Cloner le projet
git clone https://github.com/votre-nom/petclinic-kubernetes.git
cd petclinic-kubernetes

3.2 Lancer le script EKS
chmod +x scripts/deploy-eks.sh
./scripts/deploy-eks.sh
  ⏱️ Temps estimé : 12–15 minutes

4. Validation

4.1 Accès à l’application
Copier l’URL ELB affichée par le script
Ouvrir dans le navigateur → PetClinic s’affiche

4.2 Vérifier les composants critiques
kubectl get pvc -n petclinic          # STATUS = Bound
kubectl get pods -n petclinic         # mysql-0 + petclinic-* = Running
kubectl get ingress -n petclinic      # ADDRESS = ELB

5. Défis rencontrés & solutions

Problème                Cause                       Solution
AccessDeniedException   Permissions IAM             Ajout de AdministratorAccess
PVC Pending             CSI Driver manquant         Installation via Helm + rôle IAM
gp3 non trouvé          StorageClass inexistant     Utilisation de gp2
Ingress sans adresse    Contrôleur non déployé      kubectl apply -f ingress-nginx
Erreur NXDOMAIN         Règle host dans Ingress     Suppression de host: petclinic.local

6. Nettoyage (économie de coûts)
chmod +x scripts/cleanup-eks.sh
./scripts/cleanup-eks.sh
  💡 Conseil : arrêter l’instance EC2 au lieu de la supprimer pour garder le code.

7. Conclusion
Ce guide permet de déployer PetClinic sur AWS EKS en production, avec persistance, scalabilité, et accès public. Il reflète une approche DevOps moderne et est directement applicable à des projets professionnels.