# Foody Buddy Network Architecture

## Complete Microservices Communication Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │───▶│   Gateway   │◀───│   Orders    │    │  Payments   │
│  (Next.js)  │    │(Orchestrator)│    │  Service    │    │  Service    │
│             │    │             │    │             │    │             │
│ • Cart      │    │ • Brain of  │    │ • Order     │    │ • Payment   │
│ • Payment   │    │   the App   │    │   Management│    │   Processing│
│ • Orders    │    │ • Orchestrates│   │ • Status   │    │ • Transaction│
│ • Menu      │    │   Services  │    │   Tracking  │    │   Management│
│             │    │ • Minimal   │    │ • Callbacks │    │ • Rollback  │
│             │    │   Storage   │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                           │                   │                   │
                           └───────────────────┼───────────────────┘
                                               ▼
                                    ┌─────────────────┐
                                    │   PostgreSQL    │
                                    │   Database      │
                                    │                 │
                                    │ • Gateway data  │
                                    │ • Orders data   │
                                    │ • Payments data │
                                    └─────────────────┘
```

## Network Policy Traffic Flow Matrix

| From → To | Status | Purpose | Security Level |
|-----------|--------|---------|----------------|
| **Frontend → Gateway** | ✅ **ALLOWED** | API calls | ✅ Secure |
| **Frontend → Orders** | ❌ **BLOCKED** | Direct access | ✅ Secure |
| **Frontend → Payments** | ❌ **BLOCKED** | Direct access | ✅ Secure |
| **Frontend → Database** | ❌ **BLOCKED** | Direct access | ✅ Secure |
| **Gateway → Orders** | ✅ **ALLOWED** | Order management | ✅ Secure |
| **Gateway → Payments** | ✅ **ALLOWED** | Payment processing | ✅ Secure |
| **Gateway → Database** | ✅ **ALLOWED** | Data storage | ✅ Secure |
| **Orders → Gateway** | ✅ **ALLOWED** | Status callbacks | ✅ Secure |
| **Orders → Database** | ✅ **ALLOWED** | Data storage | ✅ Secure |
| **Payments → Gateway** | ❌ **BLOCKED** | No callbacks needed | ✅ Secure |
| **Payments → Database** | ✅ **ALLOWED** | Data storage | ✅ Secure |

## Network Policies Implemented

### 1. **Frontend Egress Policy** (`web-frontend-egress-policy`)
- **Purpose**: Control what frontend can access
- **Allows**: Frontend → Gateway (8080), DNS (53), Ingress (80/443), System pods
- **Blocks**: Direct access to Orders, Payments, Database

### 2. **Gateway Ingress Policy** (`gateway-ingress-policy`)
- **Purpose**: Control what can access gateway
- **Allows**: Frontend, Orders (callbacks), Ingress Controller, System pods
- **Blocks**: Direct access from Payments, other services

### 3. **Orders Ingress Policy** (`orders-ingress-policy`)
- **Purpose**: Control what can access orders service
- **Allows**: Gateway only, System pods
- **Blocks**: Direct access from Frontend, Payments, other services

### 4. **Payments Ingress Policy** (`payments-ingress-policy`)
- **Purpose**: Control what can access payments service
- **Allows**: Gateway only, System pods
- **Blocks**: Direct access from Frontend, Orders, other services

### 5. **Database Ingress Policy** (`postgres-database-network-policy`)
- **Purpose**: Control what can access database
- **Allows**: Gateway, Orders, Payments, System pods
- **Blocks**: Direct access from Frontend, other services

## Security Benefits

1. **Defense in Depth** - Multiple layers of network security
2. **Principle of Least Privilege** - Each service has minimal required access
3. **Microservices Isolation** - Clear service boundaries
4. **Bidirectional Communication** - Orders can send status callbacks to Gateway
5. **Complete Frontend Isolation** - Frontend cannot bypass the API
6. **Service-Centric Security** - Each service protects itself

## Ports Used

- **Frontend (Web)**: 3000
- **Gateway**: 8080
- **Orders**: 8081
- **Payments**: 8082
- **PostgreSQL**: 5432
- **DNS**: 53 (UDP/TCP)
- **Ingress**: 80 (HTTP), 443 (HTTPS)
