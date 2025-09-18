#!/bin/bash

echo "🚀 Deploying to foodybuddy namespace..."

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Set context to foodybuddy namespace
kubectl config set-context --current --namespace=foodybuddy

# Deploy in correct order
echo "🗄️  Deploying PostgreSQL..."
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/postgres-statefulset.yaml

# Wait for database to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres-database --timeout=300s

echo "🔗 Deploying services..."
kubectl apply -f k8s/gateway-service.yaml
kubectl apply -f k8s/orders-service.yaml
kubectl apply -f k8s/payments-service.yaml
kubectl apply -f k8s/web-service.yaml

echo "🚀 Deploying applications..."
kubectl apply -f k8s/gateway-deploy.yaml
kubectl apply -f k8s/orders-deploy.yaml
kubectl apply -f k8s/payments-deploy.yaml
kubectl apply -f k8s/web-deploy.yaml

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available deployment/foodybuddy-gateway --timeout=300s
kubectl wait --for=condition=available deployment/foodybuddy-orders --timeout=300s
kubectl wait --for=condition=available deployment/foodybuddy-payments --timeout=300s
kubectl wait --for=condition=available deployment/foodybuddy-web --timeout=300s

echo "✅ Deployment completed!"
echo "📊 Status:"
kubectl get all

echo ""
echo "🌐 External access:"
kubectl get services --field-selector spec.type=LoadBalancer
