# Ingress Setup Guide

> **📚 Main Documentation**: See [README.md](README.md) for complete project overview and quick start.

## Quick Start

1. **Deploy Ingress Controller and Ingress:**
   ```bash
   ./scripts/deploy-ingress.sh
   ```

2. **For Local Development - Add DNS Entry:**
   ```bash
   # Get the external IP
   kubectl get service ingress-nginx-controller -n ingress-nginx
   
   # Add to /etc/hosts (replace EXTERNAL_IP with actual IP)
   echo "EXTERNAL_IP foodybuddy.local" | sudo tee -a /etc/hosts
   ```

3. **Access Your Application:**
   - http://foodybuddy.local
   - http://localhost (if using port-forward)

## Port Forward for Local Testing

If you don't want to modify /etc/hosts:

```bash
# Port forward the ingress controller
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80

# Then access: http://localhost:8080
```

## What This Setup Does

- **NGINX Ingress Controller**: Routes external traffic to your web service
- **Web Service**: Changed from LoadBalancer to ClusterIP (internal only)
- **Gateway Service**: Changed from LoadBalancer to ClusterIP (internal only)
- **Ingress Resource**: Routes traffic from ingress controller to web service

## Architecture

```
Internet → NGINX Ingress Controller → Web Service (BFF) → Gateway Service → Backend Services
```

- Only the web service is exposed through ingress
- Gateway and backend services are internal only
- Web service acts as BFF (Backend for Frontend)

## Troubleshooting

1. **Check ingress controller status:**
   ```bash
   kubectl get pods -n ingress-nginx
   kubectl get service -n ingress-nginx
   ```

2. **Check ingress resource:**
   ```bash
   kubectl get ingress -n foodybuddy
   kubectl describe ingress foodybuddy-ingress -n foodybuddy
   ```

3. **Check web service:**
   ```bash
   kubectl get service -n foodybuddy
   kubectl get pods -n foodybuddy
   ```
