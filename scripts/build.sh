#!/bin/bash
# scripts/build.sh
# Construit l'image Docker de PetClinic dans l'environnement Minikube

set -e

# Chemin racine du projet (un niveau au-dessus de /scripts)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKERFILE_DIR="$PROJECT_ROOT/docker"
IMAGE_NAME="petclinic:1.0"

echo "🔄 [1/4] Configuration de Docker pour Minikube..."
eval $(minikube docker-env)

echo "🔄 [2/4] Vérification du Dockerfile..."
if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
  echo "❌ ERREUR : Dockerfile non trouvé dans $DOCKERFILE_DIR/"
  exit 1
fi

echo "🔄 [3/4] Construction de l'image Docker..."
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_DIR/Dockerfile" "$PROJECT_ROOT"

echo "✅ [4/4] Redémarrage des pods PetClinic..."
kubectl delete pod -l app=petclinic -n petclinic --ignore-not-found

echo ""
echo "🎉 Build terminé ! Nouvelle image : $IMAGE_NAME"
echo "👀 Suivre : kubectl get pods -n petclinic -w"