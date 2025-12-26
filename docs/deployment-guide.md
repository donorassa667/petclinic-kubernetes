# Guide de déploiement – Spring PetClinic sur Kubernetes

Ce document décrit **pas à pas** comment déployer l’application **Spring PetClinic** sur un cluster Kubernetes local (Minikube) hébergé sur une instance **AWS EC2**. En suivant ce guide, toute personne disposant des prérequis pourra reproduire exactement le déploiement.

---

## 1. Préparation de l’environnement

### 1.1 Créer et accéder à l’instance EC2

* Lancer une instance EC2 Ubuntu 22.04
* Type recommandé : `c7i-flex.large` ou supérieur
* Ouvrir les ports suivants dans le Security Group :

  * `22/TCP` (SSH)
  * `8080/TCP` (NodePort)
  * `80/TCP` (Ingress)

Connexion SSH :

```bash
ssh ubuntu@<IP_PUBLIQUE_EC2>
```

---

### 1.2 Installer Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
```

Vérification :

```bash
docker version
```

---

### 1.3 Installer kubectl

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Vérification :

```bash
kubectl version --client
```

---

### 1.4 Installer Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Vérification :

```bash
minikube version
```

---

## 2. Récupération du projet

Cloner le dépôt GitHub :

```bash
git clone https://github.com/donorassa667/petclinic-kubernetes.git
cd petclinic-kubernetes
```

---

## 3. Démarrage du cluster Kubernetes

Démarrer Minikube avec Docker comme driver :

```bash
minikube start --driver=docker --ports=8080:30080
```

Activer les addons nécessaires :

```bash
minikube addons enable ingress
minikube addons enable metrics-server
```

Vérification :

```bash
kubectl get nodes
```

---

## 4. Déploiement automatisé

Le projet inclut des scripts facilitant le déploiement.

### 4.1 Lancer le script de déploiement

```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```

Ce script effectue automatiquement :

* La construction de l’image Docker PetClinic
* La création du namespace Kubernetes
* Le déploiement de MySQL (StatefulSet + PVC)
* Le déploiement de PetClinic (Deployment)
* La création des Services et de l’Ingress

---

## 5. Vérification du déploiement

### 5.1 Vérifier les pods

```bash
kubectl get pods -n petclinic
```

Tous les pods doivent être en état **Running**.

---

### 5.2 Vérifier les services

```bash
kubectl get svc -n petclinic
```

---

### 5.3 Vérifier l’Ingress

```bash
kubectl get ingress -n petclinic
```

---

## 6. Accès à l’application

### 6.1 Configuration du fichier hosts (machine locale)

Ajouter l’entrée suivante :

```text
<IP_PUBLIQUE_EC2> petclinic.local
```

### 6.2 Accès via navigateur

Ouvrir :

```
http://petclinic.local
```

---

## 7. Validation fonctionnelle

### 7.1 Tester l’application

* Accéder à l’interface web
* Créer un propriétaire et un animal

---

### 7.2 Tester la persistance des données

Supprimer le pod MySQL :

```bash
kubectl delete pod mysql-0 -n petclinic
```

Après redémarrage, vérifier que les données sont toujours présentes.

---

### 7.3 Tester la résilience

Supprimer un pod applicatif :

```bash
kubectl delete pod -l app=petclinic -n petclinic
```

Kubernetes recrée automatiquement le pod.

---

## 8. Monitoring et logs

### 8.1 Consulter les métriques

```bash
kubectl top pods -n petclinic
kubectl top nodes
```

---

### 8.2 Consulter les logs

```bash
kubectl logs -l app=petclinic -n petclinic --tail=50
kubectl logs mysql-0 -n petclinic
```

---

## 9. Nettoyage de l’environnement

Pour supprimer toutes les ressources déployées :

```bash
./scripts/cleanup.sh
```

---

## 10. Conclusion

Ce guide permet de déployer intégralement l’application Spring PetClinic sur Kubernetes, avec persistance, haute disponibilité, autoscaling et monitoring. Il constitue une base réutilisable pour des projets DevOps ou des déploiements applicatifs plus avancés.
