#!/bin/bash

echo "🧹 Cleaning up default namespace..."

# Switch to default namespace
kubectl config set-context --current --namespace=default

echo "📊 Current objects in default namespace:"
kubectl get all

echo ""
echo "⚠️  WARNING: This will delete ALL Foody Buddy objects from default namespace!"
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# Delete in correct order (deployments first, then services, then statefulset)
echo "🗑️  Deleting deployments..."
kubectl delete deployment foodybuddy-gateway foodybuddy-orders foodybuddy-payments foodybuddy-web

echo "🗑️  Deleting services..."
kubectl delete service foodybuddy-gateway foodybuddy-orders foodybuddy-payments foodybuddy-web-service

echo "🗑️  Deleting PostgreSQL..."
kubectl delete statefulset postgres-database
kubectl delete service postgres-db-service

echo "🗑️  Deleting any remaining pods..."
kubectl delete pods -l app=foodybuddy-gateway
kubectl delete pods -l app=foodybuddy-orders
kubectl delete pods -l app=foodybuddy-payments
kubectl delete pods -l app=foodybuddy-web
kubectl delete pods -l app=postgres-database

echo "✅ Cleanup completed!"
echo "📊 Remaining objects in default namespace:"
kubectl get all
