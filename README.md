# Spring PetClinic sur Kubernetes

Ce projet déploie l'application [Spring PetClinic](https://github.com/spring-projects/spring-petclinic) sur un cluster Kubernetes local (**Minikube**) hébergé sur une instance **AWS EC2**.

L’architecture inclut :

* Une base de données **MySQL persistante**
* Un déploiement applicatif **Spring Boot**
* Un **autoscaling** via HPA (Horizontal Pod Autoscaler)
* Un accès externe via **NodePort** et **Ingress**
* Des **scripts d’automatisation** pour le build et le déploiement

Ce projet a pour but de démontrer la maîtrise des concepts fondamentaux de **Docker**, **Kubernetes** et du déploiement applicatif sur le cloud.

---

## 🔧 Prérequis nécessaires

### Infrastructure

* **Instance AWS EC2** (type `c7i-flex.large` ou supérieur recommandé)

  * Ubuntu 22.04
  * Ports ouverts dans le Security Group :

    * `22/TCP` (SSH)
    * `8080/TCP` (NodePort)
    * `80/TCP` (Ingress)

### Logiciels installés sur l’EC2

* Docker
* Minikube
* kubectl
* Git

> ⚠️ L’application est conçue pour fonctionner sur **Minikube** (cluster Kubernetes local) et non sur un cluster managé comme EKS.

---

## 🚀 Instructions de déploiement

### 1️⃣ Cloner le projet

```bash
git clone https://github.com/donorassa667/petclinic-kubernetes.git
cd petclinic-kubernetes
```

---

### 2️⃣ Démarrer Minikube

```bash
minikube start --driver=docker --ports=8080:30080
minikube addons enable ingress
minikube addons enable metrics-server
```

---

### 3️⃣ Déployer l’application

```bash
./scripts/deploy.sh
```

Le script `deploy.sh` effectue automatiquement :

* La construction de l’image Docker dans Minikube
* Le déploiement de MySQL (StatefulSet + PVC)
* Le déploiement de PetClinic (Deployment)
* La création des Services et de l’Ingress

---

### 4️⃣ Accès à l’application

1. Récupérer l’IP publique de l’instance EC2 (exemple : `51.21.201.212`)
2. Ajouter l’entrée suivante dans le fichier hosts de votre machine locale :

**Linux / macOS** : `/etc/hosts`

**Windows** : `C:\Windows\System32\drivers\etc\hosts`

```
51.21.201.212 petclinic.local
```

3. Ouvrir le navigateur et accéder à :

```
http://petclinic.local
```

---

## 🧪 Commandes de vérification importantes

| Objectif                       | Commande                                               |
| ------------------------------ | ------------------------------------------------------ |
| Voir l’état des pods           | `kubectl get pods -n petclinic`                        |
| Voir les logs de l’application | `kubectl logs -l app=petclinic -n petclinic --tail=50` |
| Vérifier l’Ingress             | `kubectl get ingress -n petclinic`                     |
| Vérifier l’HPA                 | `kubectl get hpa -n petclinic`                         |
| Consulter les métriques        | `kubectl top pods -n petclinic`                        |
| Accéder au dashboard           | `minikube dashboard`                                   |
| Reconstruire l’image           | `./scripts/build.sh`                                   |

---

## 📁 Structure du projet

```
petclinic-kubernetes/
├── README.md
├── docker/
│ └── Dockerfile
├── docs/
│ ├── architecture.md
│ ├── architecture.svg
│ ├── deployment-guide.md
│ └── screenshots/
│ ├── app-running.png
│ ├── monitoring-pods.png
│ ├── monitoring-workload-status.png
│ └── pods-list.png
├── kubernetes/
│ ├── namespace.yaml
│ ├── ingress/
│ │ └── petclinic-ingress.yaml
│ ├── mysql/
│ │ ├── mysql-pvc.yaml
│ │ ├── mysql-secret.yaml
│ │ ├── mysql-service.yaml
│ │ └── mysql-statefulset.yaml
│ └── petclinic/
│ ├── petclinic-configmap.yaml
│ ├── petclinic-deployment.yaml
│ ├── petclinic-hpa.yaml
│ └── petclinic-service.yaml
├── scripts/
│ ├── build.sh
│ ├── cleanup.sh
│ ├── deploy.sh
│ └── restart-minikube.sh
```

---

## ✅ Validation du projet

* Tous les pods sont en état **Running**
* L’application est accessible via navigateur
* Les données persistent après redémarrage du pod MySQL
* Les pods applicatifs sont automatiquement recréés
* Les métriques sont consultables via Metrics Server

---

## 🎯 Conclusion

Ce projet présente un déploiement Kubernetes complet et réaliste d’une application Spring Boot, intégrant persistance, haute disponibilité, autoscaling, monitoring et documentation. Il constitue une base solide pour évoluer vers un environnement de production (Helm, CI/CD, EKS).
