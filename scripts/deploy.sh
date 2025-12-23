#!/bin/bash
# scripts/deploy.sh
# Déploiement complet de Spring PetClinic sur Minikube

set -e  # Arrêter en cas d'erreur

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

echo "🚀 Démarrage du déploiement PetClinic..."

# 1. Construire l'image (optionnel mais recommandé)
echo "🔄 Construction de l'image Docker..."
"$SCRIPT_DIR/build.sh"

# 2. Namespace
echo "📦 Création du namespace..."
kubectl apply -f "$PROJECT_ROOT/kubernetes/namespace.yaml"

# 3. MySQL (Secret, PVC, StatefulSet)
echo "🛢️  Déploiement de MySQL..."
kubectl apply -f "$PROJECT_ROOT/kubernetes/mysql/"

# Attendre que mysql-0 soit prêt
echo "⏳ Attente que MySQL soit prêt (jusqu'à 60s)..."
kubectl wait --for=condition=ready pod/mysql-0 -n petclinic --timeout=60s

# 4. PetClinic (ConfigMap, Deployment, Service)
echo "🚀 Déploiement de l'application PetClinic..."
kubectl apply -f "$PROJECT_ROOT/kubernetes/petclinic/"

# 5. Ingress
echo "🌐 Configuration de l'Ingress..."
kubectl apply -f "$PROJECT_ROOT/kubernetes/ingress/petclinic-ingress.yaml"

echo ""
echo "✅ Déploiement terminé avec succès !"
echo ""
echo "🔗 Accès à l'application :"
echo "   - Via Ingress (recommandé) : http://petclinic.local"
echo "     → Pense à ajouter l'IP de ton EC2 dans ton fichier /etc/hosts"
echo "   - Via NodePort (backup)    : http://<EC2_PUBLIC_IP>:30080"
echo ""
echo "📊 Outils utiles :"
echo "   - Voir les pods     : kubectl get pods -n petclinic"
echo "   - Voir l'Ingress    : kubectl get ingress -n petclinic"
echo "   - HPA (si activé)   : kubectl get hpa -n petclinic"