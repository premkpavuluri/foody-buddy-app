#!/bin/bash

# Deploy NGINX Ingress Controller and Foody Buddy Ingress
# This script deploys the minimal ingress setup

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_ROOT/k8s"

echo "🚀 Deploying NGINX Ingress Controller..."
echo "📁 Using k8s directory: $K8S_DIR"

# Create ingress-nginx namespace
kubectl apply -f "$K8S_DIR/ingress-nginx-namespace.yaml"

# Deploy NGINX Ingress Controller
kubectl apply -f "$K8S_DIR/ingress-nginx-controller.yaml"

# Wait for ingress controller to be ready
echo "⏳ Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app=ingress-nginx \
  --timeout=300s

echo "✅ NGINX Ingress Controller is ready!"

# Deploy Foody Buddy Ingress
echo "🌐 Deploying Foody Buddy Ingress..."
kubectl apply -f "$K8S_DIR/foodybuddy-ingress.yaml"

echo "✅ Foody Buddy Ingress deployed!"

# Get the external IP
echo "📍 Getting external IP..."
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$EXTERNAL_IP" ]; then
    echo "⚠️  External IP not available yet. This might be a local cluster."
    echo "   For local development, you can use:"
    echo "   - http://localhost (if using port-forward)"
    echo "   - http://foodybuddy.local (if you add it to /etc/hosts)"
else
    echo "🌍 External IP: $EXTERNAL_IP"
    echo "   Access your app at: http://$EXTERNAL_IP"
fi

echo ""
echo "🎉 Ingress setup complete!"
echo ""
echo "To access your application:"
echo "1. Add to /etc/hosts: $EXTERNAL_IP foodybuddy.local"
echo "2. Visit: http://foodybuddy.local"
echo ""
echo "Or use port-forward for local testing:"
echo "kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80"
echo "Then visit: http://localhost:8080"
