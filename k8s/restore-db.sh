#!/bin/bash

echo "🔄 Restoring PostgreSQL data to new namespace..."

# Get the latest backup file
BACKUP_FILE=$(ls -t k8s/backup/postgres-backup-*.sql | head -1)

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ No backup file found in k8s/backup/"
    exit 1
fi

echo "📦 Using backup file: $BACKUP_FILE"

# Get the PostgreSQL pod name in foodybuddy namespace
POD_NAME=$(kubectl get pods -n foodybuddy -l app=postgres-database -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "❌ No PostgreSQL pod found in foodybuddy namespace"
    echo "Make sure PostgreSQL is deployed first"
    exit 1
fi

echo "📦 Found PostgreSQL pod: $POD_NAME"

# Copy backup to pod
echo "📋 Copying backup to pod..."
kubectl cp $BACKUP_FILE foodybuddy/$POD_NAME:/tmp/backup.sql

# Restore the backup
echo "🔄 Restoring database..."
kubectl exec -n foodybuddy $POD_NAME -- psql -U foodybuddy_user -d foodybuddy -f /tmp/backup.sql

echo "✅ Database restore completed!"
echo "🧹 Cleaning up temporary files..."
kubectl exec -n foodybuddy $POD_NAME -- rm /tmp/backup.sql

echo "🎉 Migration completed successfully!"
