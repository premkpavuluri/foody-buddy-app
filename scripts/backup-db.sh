#!/bin/bash

echo "🗄️  Creating PostgreSQL backup..."

# Get the PostgreSQL pod name
POD_NAME=$(kubectl get pods -n default -l app=postgres-database -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "❌ No PostgreSQL pod found in default namespace"
    exit 1
fi

echo "📦 Found PostgreSQL pod: $POD_NAME"

# Create backup directory
mkdir -p k8s/backup

# Export all databases
echo "💾 Exporting all databases..."
kubectl exec -n default $POD_NAME -- pg_dumpall -U foodybuddy_user > k8s/backup/postgres-backup-$(date +%Y%m%d-%H%M%S).sql

# Export specific databases (if you have them)
echo "💾 Exporting individual databases..."
kubectl exec -n default $POD_NAME -- psql -U foodybuddy_user -c "\l" | grep -v "template\|postgres" | awk 'NR>3 {print $1}' | grep -v "^$" | while read db; do
    if [ ! -z "$db" ]; then
        echo "📊 Exporting database: $db"
        kubectl exec -n default $POD_NAME -- pg_dump -U foodybuddy_user $db > k8s/backup/$db-$(date +%Y%m%d-%H%M%S).sql
    fi
done

echo "✅ Backup completed! Check k8s/backup/ directory"
ls -la k8s/backup/
