#!/bin/bash
# scripts/restart-minikube.sh
# Redémarre Minikube avec configuration optimisée pour Ingress + NodePort

set -e

echo "🔄 [1/5] Suppression du cluster Minikube existant..."
minikube delete

echo "🔄 [2/5] Démarrage de Minikube avec ports 80 (Ingress) et 8080 (NodePort)..."
minikube start --driver=docker --ports=80:80 --ports=8080:30080

echo "🔄 [3/5] Activation des addons nécessaires..."
minikube addons enable ingress
minikube addons enable metrics-server

echo "⏳ Attente que l'Ingress Controller soit prêt (max 2 min)..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "🔄 [4/5] Redéploiement de l'application..."
cd "$(dirname "$0")/.."
./scripts/deploy.sh

echo ""
echo "✅ [5/5] Minikube redémarré et application déployée !"
echo ""
echo "🔗 Accès à l'application :"
echo "   - Via Ingress (recommandé) : http://petclinic.local"
echo "   - Via NodePort (backup)    : http://$(curl -s ifconfig.me):8080"
echo ""
echo "📌 N'oubliez pas de mettre à jour /etc/hosts sur votre machine locale :"
echo "      $(curl -s ifconfig.me) petclinic.local"
echo ""
echo "📊 Vérifiez l'Ingress : kubectl get ingress -n petclinic"