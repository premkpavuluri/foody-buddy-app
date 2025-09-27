# FoodyBuddy - Microservices Food Delivery Application

A comprehensive microservices application demonstrating modern architecture patterns for food delivery services. Built with Next.js frontend and Spring Boot microservices, featuring orchestrated service communication and real-time order tracking.

## 📚 Documentation Index

- **[🐳 Docker Setup](DOCKER_README.md)** - Complete Docker and Docker Compose guide
- **[🛠️ Scripts Guide](SCRIPTS_README.md)** - Service runner scripts and automation
- **[☸️ Kubernetes Setup](k8s/)** - Complete Kubernetes deployment guide
- **[🌐 Ingress Setup](INGRESS_SETUP.md)** - NGINX Ingress configuration
- **[📋 Project Tasks](TODO.md)** - Current development tasks and progress

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              FOODY BUDDY ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │    │   Gateway   │    │   Orders    │    │  Payments   │
│  (Next.js)  │    │(Orchestrator)│    │  Service    │    │  Service    │
│             │    │             │    │             │    │             │
│ • Cart      │    │ • Brain of  │    │ • Order     │    │ • Payment   │
│ • Payment   │    │   the App   │    │   Management│    │   Processing│
│ • Orders    │    │ • Orchestrates│   │ • Status   │    │ • Transaction│
│ • Menu      │    │   Services  │    │   Tracking  │    │   Management│
│             │    │ • Minimal   │    │ • Callbacks │    │ • Rollback  │
│             │    │   Storage   │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## 🚀 Services

### **foodybuddy-web** (Frontend)
- **Technology**: Next.js 14, React, TypeScript, Tailwind CSS
- **Features**: Menu browsing, cart management, payment processing, order tracking
- **Port**: 3000

### **foodybuddy-gateway** (API Gateway & Orchestrator)
- **Technology**: Spring Boot, Spring Cloud Gateway
- **Role**: Central orchestration service - the "brain" of the application
- **Features**: 
  - Service orchestration and coordination
  - Minimal data storage (orderId, paymentId, transactionId, status)
  - Order status update callbacks
  - Error handling and rollback management
- **Port**: 8080

### **foodybuddy-orders** (Order Management)
- **Technology**: Spring Boot, JPA, PostgreSQL
- **Features**:
  - Order creation and management
  - Order status tracking (PENDING → CONFIRMED → PREPARING → READY → DELIVERED)
  - Real-time status updates via gateway callbacks
  - Order history and details
- **Port**: 8081

### **foodybuddy-payments** (Payment Processing)
- **Technology**: Spring Boot, JPA, PostgreSQL
- **Features**:
  - Payment processing and validation
  - Transaction management
  - Payment rollback capabilities
  - Payment history tracking
- **Port**: 8082

## 🔄 Application Flow

### **Complete Order Processing Flow:**

1. **User Selection**: User browses menu and adds items to cart
2. **Checkout Initiation**: User clicks "Proceed to Checkout"
3. **Payment Page**: Redirect to dedicated payment page
4. **Order Creation**: Gateway creates order via Order Service
5. **Payment Processing**: Gateway processes payment via Payment Service
6. **Order Confirmation**: Gateway updates order status to CONFIRMED
7. **Data Storage**: Gateway stores minimal order data (orderId, paymentId, transactionId)
8. **Success Response**: User redirected to Orders page
9. **Real-time Updates**: Order status updates via callback mechanism
10. **UI Updates**: Frontend polls gateway for latest order status

### **Order Status Lifecycle:**
```
PENDING → CONFIRMED → PREPARING → READY → OUT_FOR_DELIVERY → DELIVERED
    ↓
CANCELLED (at any stage)
```

### **Service Communication Pattern:**
- **Frontend ↔ Gateway**: All user interactions
- **Gateway ↔ Orders**: Order management operations
- **Gateway ↔ Payments**: Payment processing
- **Orders → Gateway**: Status update callbacks
- **Gateway → Frontend**: Real-time status updates

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Java 17+
- Node.js 18+
- Gradle 8.5+

### Option 1: Docker (Recommended)
```bash
# Start all services with Docker Compose
docker-compose up --build

# Or use the Docker management script
./scripts/docker-run.sh
```

### Option 2: Local Development
```bash
# Run all services locally with Gradle/Yarn
./scripts/run-services.sh

# Or run each service individually
./scripts/dev-local.sh
```

### Option 3: Kubernetes
```bash
# Deploy to Kubernetes
./scripts/deploy-to-foodybuddy.sh

# Set up Ingress
./scripts/deploy-ingress.sh
```

### Access the Application
- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **Orders Service**: http://localhost:8081
- **Payments Service**: http://localhost:8082

## 📋 API Endpoints

### Gateway (Port 8080)
- `POST /api/gateway/checkout` - Process complete checkout flow
- `GET /api/gateway/orders/{orderId}` - Get order details
- `GET /api/gateway/orders` - Get all orders for user
- `POST /api/gateway/orders/status` - Order status update callback

### Orders Service (Port 8081)
- `POST /api/orders` - Create new order
- `GET /api/orders/{orderId}` - Get order by ID
- `PUT /api/orders/{orderId}/status` - Update order status
- `GET /api/orders` - Get all orders

### Payments Service (Port 8082)
- `POST /api/payments/process` - Process payment
- `GET /api/payments/{paymentId}` - Get payment details
- `POST /api/payments/{paymentId}/refund` - Refund payment

## 🎯 Key Features

- **🛒 Shopping Cart**: Add/remove items, quantity management
- **💳 Payment Processing**: Secure payment with multiple methods
- **📦 Order Management**: Complete order lifecycle tracking
- **🔄 Real-time Updates**: Live order status updates
- **🏗️ Microservices**: Scalable, maintainable architecture
- **🐳 Containerized**: Docker-ready for production deployment
- **☸️ Kubernetes Ready**: Complete K8s deployment manifests
- **📱 Responsive UI**: Modern, mobile-friendly interface

## 🏗️ Architecture Benefits

- **Scalability**: Each service can scale independently
- **Maintainability**: Clear separation of concerns
- **Reliability**: Fault isolation and error handling
- **Flexibility**: Easy to add new features and services
- **Performance**: Optimized service communication
- **Monitoring**: Centralized orchestration for better observability

## 📁 Project Structure

```
foody-buddy-app/
├── foodybuddy-web/              # Next.js Frontend
├── foodybuddy-gateway/          # Spring Boot Gateway/Orchestrator
├── foodybuddy-orders/           # Spring Boot Orders Service
├── foodybuddy-payments/         # Spring Boot Payments Service
├── k8s/                         # Kubernetes manifests
│   ├── NETWORK_ARCHITECTURE.md  # Network architecture docs
│   └── *.yaml                   # K8s deployment files
├── scripts/                     # Automation scripts
│   └── README.md                # Scripts documentation
├── docker-compose.prod.yml      # Production orchestration
├── docker-compose.dev.yml       # Development orchestration
├── DOCKER_README.md             # Docker documentation
├── SCRIPTS_README.md            # Scripts documentation
├── INGRESS_SETUP.md             # Kubernetes Ingress setup
└── TODO.md                      # Project tasks and progress
```

## 🔧 Development

### Individual Service Development

Each service can be run independently:

```bash
# Frontend
cd foodybuddy-web
npm install
npm run dev

# Gateway
cd foodybuddy-gateway
./gradlew bootRun

# Orders Service
cd foodybuddy-orders
./gradlew bootRun

# Payments Service
cd foodybuddy-payments
./gradlew bootRun
```

### Build Process

#### Backend Services (Gateway, Orders, Payments)
```bash
# Build JAR artifacts first
cd foodybuddy-gateway && ./gradlew clean build -x test
cd foodybuddy-orders && ./gradlew clean build -x test  
cd foodybuddy-payments && ./gradlew clean build -x test

# Build Docker images
docker build -t foodybuddy.prod.gateway:latest .
docker build -t foodybuddy.prod.orders:latest .
docker build -t foodybuddy.prod.payments:latest .
```

#### Web Service
```bash
# Build Next.js application first
cd foodybuddy-web && yarn build

# Build Docker image
docker build -t foodybuddy.prod.web:latest .
```

#### Automated Build (Recommended)
```bash
# Build all services and Docker images
./scripts/docker-run.sh prod build --build-services

# Or just build Docker images (if artifacts exist)
./scripts/docker-run.sh prod build
```

## 🗄️ Database

The application uses PostgreSQL with schema-based separation:

- **Single Database**: `foodybuddy`
- **Schema Separation**: `gateway`, `orders`, `payments`
- **Current Setup**: Single PostgreSQL database with schema-based separation

## 🚀 Deployment Options

### 1. Docker Compose
- **Development**: `docker-compose -f docker-compose.dev.yml up`
- **Production**: `docker-compose -f docker-compose.prod.yml up`
- **Documentation**: [DOCKER_README.md](DOCKER_README.md)

### 2. Kubernetes
- **Deployment**: `./scripts/deploy-to-foodybuddy.sh`
- **Ingress**: `./scripts/deploy-ingress.sh`
- **Documentation**: [k8s/](k8s/) directory

### 3. Local Development
- **All Services**: `./scripts/run-services.sh`
- **Individual Services**: `./scripts/dev-local.sh`
- **Documentation**: [SCRIPTS_README.md](SCRIPTS_README.md)

## 🔧 Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check port usage
lsof -i :3000 :8080 :8081 :8082

# Kill processes on specific ports
lsof -ti :8080 | xargs kill -9
```

#### Service Dependencies
Services start in this order:
1. Orders Service (8081)
2. Payments Service (8082)
3. Gateway Service (8080) - waits for backend services
4. Web Frontend (3000) - waits for gateway

#### Docker Issues
```bash
# Clean Docker environment
docker system prune -f
docker-compose down --volumes

# Rebuild everything
docker-compose build --no-cache
```

#### Kubernetes Issues
```bash
# Check pod status
kubectl get pods -n foodybuddy

# Check service status
kubectl get services -n foodybuddy

# View logs
kubectl logs -f deployment/foodybuddy-web -n foodybuddy
```

## 📚 Additional Resources

- **[Docker Documentation](https://docs.docker.com/compose/)**
- **[Kubernetes Documentation](https://kubernetes.io/docs/)**
- **[Spring Boot Docker Guide](https://spring.io/guides/gs/spring-boot-docker/)**
- **[Next.js Docker Guide](https://nextjs.org/docs/deployment#docker-image)**

---

**Happy Coding! 🚀**