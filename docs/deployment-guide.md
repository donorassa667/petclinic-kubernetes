# Guide de déploiement – Spring PetClinic sur AWS EKS

Ce guide décrit **pas à pas** le déploiement de l’application **Spring PetClinic** sur **AWS EKS**, en remplacement d’une approche locale (Minikube). Il est conçu pour être **reproductible, clair et orienté production**.

---

## 1️⃣ Préparation AWS

### 1.1 Permissions IAM

* Utilisateur IAM utilisé : `kals`
* Accorder **temporairement** la permission :

```
AdministratorAccess
```

> 🔐 Ces permissions pourront être réduites après le déploiement (bonne pratique sécurité).

---

### 1.2 Clé SSH EC2

Vérifier dans **AWS EC2 → Key Pairs** que la clé suivante existe :

```
docker-host-m1resi-**
```

Elle sera utilisée pour les nœuds EKS si nécessaire.

---

## 2️⃣ Préparation de la machine de gestion

> Peut être :
>
> * une **instance EC2 dédiée**
> * ou ta **machine locale** avec AWS CLI configuré

---

### 2.1 Installation des outils requis

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip && sudo ./aws/install

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Docker
sudo apt install -y docker.io
sudo usermod -aG docker $USER && newgrp docker
```

---

### 2.2 Configuration AWS CLI

```bash
aws configure
```

Renseigner :

* AWS Access Key ID
* AWS Secret Access Key
* Région : `eu-north-1`

---

## 3️⃣ Déploiement sur AWS EKS

### 3.1 Cloner le projet

```bash
git clone https://github.com/donorassa667/petclinic-kubernetes.git
cd petclinic-kubernetes
```

---

### 3.2 Lancer le script de déploiement EKS

```bash
chmod +x scripts/deploy-eks.sh
./scripts/deploy-eks.sh
```

⏱️ **Temps estimé : 12 à 15 minutes**

Le script automatise :

* Création du cluster EKS
* Installation du **CSI Driver Amazon EBS**
* Création du repository **ECR**
* Build & push de l’image Docker
* Déploiement MySQL (PVC + StatefulSet)
* Déploiement Spring PetClinic
* Installation Ingress Nginx
* Exposition via **AWS Load Balancer**

---

## 4️⃣ Validation du déploiement

### 4.1 Accès à l’application

À la fin du script, une URL ELB est affichée, par exemple :

```
http://a1b2c3d4e5f6.elb.eu-north-1.amazonaws.com
```

➡️ Ouvrir l’URL dans le navigateur : **PetClinic s’affiche**

---

### 4.2 Vérification des composants critiques

```bash
kubectl get pvc -n petclinic          # STATUS = Bound
kubectl get pods -n petclinic         # mysql-0 + petclinic-* = Running
kubectl get ingress -n petclinic      # ADDRESS = ELB
```
---

## 🔄 Mise à jour Kubernetes vers la version 1.32

Après le déploiement initial, le cluster EKS a été mis à jour vers **Kubernetes 1.32**.

### Vérifications post-mise à jour

```bash
kubectl get nodes
eksctl get nodegroup --cluster petclinic-prod
kubectl get pods -n kube-system
---

## 5️⃣ Défis rencontrés & solutions

| Problème                | Cause                         | Solution                                |
| ----------------------- | ----------------------------- | --------------------------------------- |
| AccessDeniedException   | Permissions IAM insuffisantes | Ajout temporaire de AdministratorAccess |
| PVC en Pending          | CSI Driver absent             | Installation via Helm + rôle IAM        |
| StorageClass gp3 absent | Non disponible par défaut     | Utilisation de gp2                      |
| Ingress sans adresse    | Contrôleur absent             | Déploiement ingress-nginx               |
| NXDOMAIN                | Règle `host:` dans Ingress    | Accès direct via ELB                    |

---

## 6️⃣ Nettoyage (économie de coûts)

```bash
chmod +x scripts/cleanup-eks.sh
./scripts/cleanup-eks.sh
```

💡 **Conseil** : arrêter l’instance EC2 plutôt que la supprimer pour conserver le code.

---

## 7️⃣ Conclusion

Ce guide permet un **déploiement complet et production-ready** de Spring PetClinic sur **AWS EKS**, intégrant persistance, scalabilité, sécurité et accès public.

Il constitue une **référence DevOps professionnelle**, directement applicable à des environnements réels.
