# Spring PetClinic sur Kubernetes (AWS EKS)

Ce projet déploie l'application [Spring PetClinic](https://github.com/spring-projects/spring-petclinic) sur un **cluster Kubernetes managé : AWS EKS**, avec stockage persistant, autoscaling et accès public via Load Balancer.

> 🚀 **Migration réussie depuis Minikube vers AWS EKS (production-ready)**

> 💡 **Version Minikube archivée**
> La version précédente avec Minikube est conservée dans la branche
> 👉 [`minikube-final`](https://github.com/donorassa667/petclinic-kubernetes/tree/minikube-final)

---

## 🧱 Architecture & fonctionnalités

L’architecture inclut :

* 🗄️ **MySQL persistant** via **Amazon EBS (CSI Driver)**
* 🐳 Application **Spring Boot** packagée en Docker et stockée sur **Amazon ECR**
* 📈 **Autoscaling horizontal (HPA)**
* 🌐 Accès externe via **AWS Load Balancer** (Ingress Nginx)
* ⚙️ **Scripts d’automatisation** pour le déploiement et le nettoyage EKS

Ce projet permet une **maîtrise avancée** de :

Docker · Kubernetes · AWS · EKS · IAM · ECR · CSI Driver · Cloud-Native Architecture

---

## 🔧 Prérequis nécessaires

### ☁️ Infrastructure AWS

* Compte AWS avec crédits (ex : **95 $ gratuits**)
* **Clé SSH AWS** existante : `docker-host-m1resi-*`
* **Utilisateur IAM** avec permissions suffisantes
  👉 `AdministratorAccess` **temporaire recommandé**

---

### 🛠️ Outils requis (local ou EC2 de gestion)

* AWS CLI
* eksctl
* kubectl
* helm
* Docker
* Git

> ⚠️ **Minikube n’est plus requis**
> Ce projet est conçu pour **AWS EKS en environnement réel**

---

## 🚀 Instructions de déploiement

### 1️⃣ Cloner le projet

```bash
git clone https://github.com/donorassa667/petclinic-kubernetes.git
cd petclinic-kubernetes
```

---

### 2️⃣ Déployer automatiquement sur AWS EKS

```bash
chmod +x scripts/deploy-eks.sh
./scripts/deploy-eks.sh
```

Le script effectue automatiquement :

* Création du cluster **EKS**
* Installation du **CSI Driver Amazon EBS**
* Build & push de l’image Docker vers **Amazon ECR**
* Déploiement de **MySQL** (PVC + StatefulSet)
* Déploiement de **Spring PetClinic**
* Installation de **Ingress Nginx**
* Exposition via **AWS Load Balancer**

---

### 3️⃣ Accès à l’application

À la fin du script, une URL de type est affichée :

```
http://xxxxxxxx.elb.<region>.amazonaws.com
```

👉 Copiez directement l’URL dans votre navigateur
👉 **Aucune modification du fichier `/etc/hosts` n’est nécessaire**

---

## 🧪 Commandes de vérification

| Objectif           | Commande                                               |
| ------------------ | ------------------------------------------------------ |
| Voir les pods      | `kubectl get pods -n petclinic`                        |
| Voir les logs      | `kubectl logs -l app=petclinic -n petclinic --tail=50` |
| Vérifier l’Ingress | `kubectl get ingress -n petclinic`                     |
| Vérifier le HPA    | `kubectl get hpa -n petclinic`                         |
| Voir les métriques | `kubectl top pods -n petclinic`                        |

---

## 📁 Structure du projet

```text
petclinic-kubernetes/
├── README.md
├── docker/
│   └── Dockerfile
├── docs/
│   ├── architecture.md
│   ├── architecture.svg
│   ├── deployment-guide.md
│   └── screenshots/
├── kubernetes/
│   ├── namespace.yaml
│   ├── ingress/
│   │   └── petclinic-ingress.yaml
│   ├── mysql/
│   │   ├── mysql-pvc.yaml
│   │   ├── mysql-secret.yaml
│   │   ├── mysql-service.yaml
│   │   └── mysql-statefulset.yaml
│   └── petclinic/
│       ├── petclinic-configmap.yaml
│       ├── petclinic-deployment.yaml
│       ├── petclinic-hpa.yaml
│       └── petclinic-service.yaml
├── scripts/
│   ├── deploy-eks.sh
│   └── cleanup-eks.sh
```

---

## 🔄 Mise à jour du cluster EKS (Kubernetes v1.32)

Le cluster **petclinic-prod** a été mis à jour vers **Kubernetes v1.32**, la version la plus récente supportée par AWS EKS.

### Éléments vérifiés après mise à jour

- ✅ Nœuds EKS opérationnels
- ✅ Node Group managé fonctionnel
- ✅ CSI Driver Amazon EBS actif
- ✅ Ingress Nginx fonctionnel
- ✅ Application et base de données stables

```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n petclinic
```
---

## 🏆 Défis techniques surmontés

* Permissions IAM insuffisantes → **AdministratorAccess temporaire**
* Stockage persistant non fonctionnel → **CSI Driver Amazon EBS**
* PVC gp3 non reconnu → **basculement vers gp2**
* Ingress sans adresse ELB → **installation ingress-nginx**
* Accès via host local → **accès direct via ELB**

---

## 🎯 Conclusion

Ce projet est désormais **100 % cloud-native**, déployé sur **AWS EKS** selon les bonnes pratiques DevOps.

Il constitue une base solide pour :

* CI/CD (GitHub Actions + EKS)
* Sécurité avancée (IRSA, IAM)
* Optimisation des coûts (arrêt / destruction du cluster)
