# Scripts Directory

This directory contains all shell scripts for the Foody Buddy application.

## 📁 Scripts Overview

### Development Scripts
- `dev.sh` - Main development script
- `dev-local.sh` - Local development setup
- `docker-run.sh` - Docker services management
- `run-services.sh` - Service runner
- `start-postgres.sh` - PostgreSQL startup
- `test-services.sh` - Service testing

### Kubernetes Scripts
- `backup-db.sh` - PostgreSQL backup utility
- `cleanup-default.sh` - Clean default namespace
- `deploy-to-foodybuddy.sh` - Deploy to foodybuddy namespace
- `restore-db.sh` - Restore PostgreSQL data

## 🚀 Usage

All scripts are executable and can be run from the project root:

```bash
# Development
./scripts/dev.sh
./scripts/docker-run.sh

# Kubernetes
./scripts/backup-db.sh
./scripts/deploy-to-foodybuddy.sh
```

## 📋 Script Dependencies

- Scripts assume they're run from the project root directory
- All paths are relative to the project root
- Kubernetes scripts require `kubectl` to be configured
- Docker scripts require Docker and Docker Compose

## 🔧 Configuration

Scripts use the following directory structure:
- `k8s/` - Kubernetes manifests
- `k8s/backup/` - Database backups
- `scripts/` - All shell scripts
- `docker-compose.prod.yml` - Production compose
- `docker-compose.dev.yml` - Development compose
