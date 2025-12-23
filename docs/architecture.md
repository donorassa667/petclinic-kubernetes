# Architecture du déploiement PetClinic sur Kubernetes

## 1. Diagramme d’architecture

![Architecture du déploiement PetClinic](architecture.svg)


---

## 2. Justification des choix techniques

### Docker
Docker est utilisé pour packager l’application Spring Boot et garantir la portabilité de l’environnement d’exécution.

### Kubernetes
Kubernetes permet :
- Le déploiement automatisé
- La gestion des réplicas
- La résilience (self-healing)
- La montée en charge

### Deployment pour PetClinic
L’application PetClinic est stateless, ce qui justifie l’utilisation d’un **Deployment** avec plusieurs réplicas.

### StatefulSet pour MySQL
MySQL nécessite :
- Une identité réseau stable
- Une persistance des données

Le **StatefulSet** est donc le choix approprié.

### PersistentVolumeClaim
Le PVC permet de conserver les données même en cas de redémarrage du pod MySQL.

### Service NodePort
Le service NodePort permet un accès simple à l’application depuis l’extérieur sans Ingress.

---

## 3. Description des composants Kubernetes

### Namespace
Permet d’isoler les ressources liées au projet PetClinic.

### Deployment (PetClinic)
- Gère les pods applicatifs
- Assure la haute disponibilité
- Redémarre automatiquement les pods en cas de panne

### StatefulSet (MySQL)
- Gère la base de données
- Assure la persistance et la stabilité réseau

### Services
- **ClusterIP** : communication interne
- **NodePort** : exposition externe de l’application

### ConfigMap et Secret
- ConfigMap : paramètres applicatifs
- Secret : identifiants MySQL
