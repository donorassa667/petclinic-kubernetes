#!/bin/bash
# scripts/cleanup.sh
kubectl delete namespace petclinic --ignore-not-found
echo "🧹 Namespace 'petclinic' supprimé."