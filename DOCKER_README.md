# FoodyBuddy Docker Setup

This guide covers running the FoodyBuddy microservices using Docker and Docker Compose.

## 🐳 Quick Start

### Using the Docker Script (Recommended)
```bash
# Start all services (default environment)
./scripts/docker-run.sh

# Start development environment with hot reloading
./scripts/docker-run.sh dev up

# Start production environment
./scripts/docker-run.sh prod up

# Stop all services
./scripts/docker-run.sh down

# View logs
./scripts/docker-run.sh logs

# Check service status
./scripts/docker-run.sh status
```

### Using Docker Compose Directly
```bash
# Default environment
docker-compose up --build

# Development environment
docker-compose -f docker-compose.dev.yml up --build

# Production environment
docker-compose -f docker-compose.prod.yml up --build
```

## 📁 Docker Files Structure

```
foody-buddy-app/
├── docker-compose.prod.yml     # Production environment
├── docker-compose.dev.yml      # Development environment
├── docker-run.sh              # Docker management script
├── foodybuddy-gateway/
│   ├── Dockerfile             # Production image
│   └── Dockerfile.dev         # Development image
├── foodybuddy-orders/
│   ├── Dockerfile             # Production image
│   └── Dockerfile.dev         # Development image
├── foodybuddy-payments/
│   ├── Dockerfile             # Production image
│   └── Dockerfile.dev         # Development image
└── foodybuddy-web/
    ├── Dockerfile             # Production image
    └── Dockerfile.dev         # Development image
```

## 🏗️ Environments

### Production Environment (`docker-compose.prod.yml`)
- **Purpose**: Standard environment for testing and development
- **Features**: 
  - Multi-stage builds for optimized images
  - Health checks for all services
  - Proper service dependencies
  - Restart policies
- **Use Case**: General development and testing

### Development Environment (`docker-compose.dev.yml`)
- **Purpose**: Development with hot reloading
- **Features**:
  - Volume mounting for live code changes
  - Development Dockerfiles
  - Hot reloading for all services
  - Faster startup times
- **Use Case**: Active development with code changes

### Production Environment (`docker-compose.prod.yml`)
- **Purpose**: Production deployment
- **Features**:
  - Optimized for performance
  - Resource limits and reservations
  - Persistent data volumes
  - Production configurations
  - Always restart policy
- **Use Case**: Production deployment

## 🚀 Services

### Service Architecture
```
┌─────────────────┐    ┌─────────────────┐
│   Web Frontend  │    │   API Gateway   │
│   (Port 3000)   │◄───┤   (Port 8080)   │
│   (Next.js)     │    │   (Spring Boot) │
└─────────────────┘    └─────────────────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
            ┌───────▼───┐ ┌─────▼─────┐ ┌───▼──────┐
            │  Orders   │ │ Payments  │ │   ...    │
            │ (Port 8081)│ │(Port 8082)│ │          │
            │ (Spring)  │ │ (Spring)  │ │          │
            └───────────┘ └───────────┘ └──────────┘
```

### Service Details

#### 🌐 Web Frontend (foodybuddy-web)
- **Port**: 3000
- **Technology**: Next.js with React
- **Health Check**: `http://localhost:3000/api/health`
- **Environment Variables**:
  - `NODE_ENV`: production/development
  - `NEXT_PUBLIC_API_URL`: API gateway URL

#### 🚪 API Gateway (foodybuddy-gateway)
- **Port**: 8080
- **Technology**: Spring Boot with Spring Cloud Gateway
- **Health Check**: `http://localhost:8080/actuator/health`
- **Routes**:
  - `/api/orders/**` → Orders Service
  - `/api/payments/**` → Payments Service

#### 📦 Orders Service (foodybuddy-orders)
- **Port**: 8081
- **Technology**: Spring Boot
- **Health Check**: `http://localhost:8081/actuator/health`
- **Database**: H2 (in-memory for dev, file-based for prod)

#### 💳 Payments Service (foodybuddy-payments)
- **Port**: 8082
- **Technology**: Spring Boot
- **Health Check**: `http://localhost:8082/actuator/health`
- **Database**: H2 (in-memory for dev, file-based for prod)

## 🛠️ Docker Management Script

The `docker-run.sh` script provides easy management of Docker services:

### Usage
```bash
./scripts/docker-run.sh [ENVIRONMENT] [COMMAND]
```

### Environments
- `dev` - Development environment
- `prod` - Production environment
- `default` - Standard environment (default)

### Commands
- `up` - Start all services (default)
- `down` - Stop all services
- `build` - Build all images
- `logs` - Show logs for all services
- `status` - Show status of all services
- `clean` - Clean up containers, images, and volumes

### Examples
```bash
# Start development environment
./scripts/docker-run.sh dev up

# Build production images
./scripts/docker-run.sh prod build

# View logs
./scripts/docker-run.sh logs

# Stop all services
./scripts/docker-run.sh down

# Clean up everything
./scripts/docker-run.sh clean
```

## 🔧 Dockerfile Features

### Production Dockerfiles
- **Multi-stage builds** for smaller image sizes
- **Non-root users** for security
- **Health checks** for service monitoring
- **Optimized JVM settings** for Java services
- **Security best practices**

### Development Dockerfiles
- **Volume mounting** for live code changes
- **Development tools** included
- **Faster builds** with minimal layers
- **Hot reloading** support

## 📊 Health Checks

All services include health checks:

### Java Services (Spring Boot)
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:PORT/actuator/health || exit 1
```

### Web Frontend (Next.js)
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1
```

## 🔒 Security Features

### Container Security
- **Non-root users** in all containers
- **Minimal base images** (alpine/openjdk-slim)
- **No unnecessary packages** in production images
- **Proper file permissions**

### Network Security
- **Isolated networks** for service communication
- **Internal service discovery** using container names
- **No external database exposure**

## 📈 Performance Optimizations

### Image Optimizations
- **Multi-stage builds** reduce final image size
- **Layer caching** for faster builds
- **Minimal runtime images** (JRE instead of JDK)
- **Alpine Linux** for smaller base images

### Runtime Optimizations
- **JVM tuning** with G1GC
- **Memory limits** and reservations
- **Resource constraints** in production
- **Efficient container startup**

## 🗄️ Data Persistence

### Development
- **In-memory H2 databases** for fast development
- **Volume mounting** for code changes
- **No persistent data** (resets on restart)

### Production
- **File-based H2 databases** with persistent volumes
- **Data volumes** for orders and payments
- **Backup strategies** for data persistence

## 🐛 Troubleshooting

### Common Issues

#### Services won't start
```bash
# Check Docker status
docker-compose ps

# View logs
docker-compose logs [service-name]

# Check health status
docker-compose exec [service-name] curl localhost:PORT/actuator/health
```

#### Port conflicts
```bash
# Check port usage
lsof -i :3000
lsof -i :8080
lsof -i :8081
lsof -i :8082

# Stop conflicting services
docker-compose down
```

#### Build failures
```bash
# Clean build
docker-compose build --no-cache

# Remove unused images
docker system prune -f
```

#### Memory issues
```bash
# Check resource usage
docker stats

# Increase Docker memory limits in Docker Desktop
```

### Debugging Commands

```bash
# Enter a running container
docker-compose exec [service-name] /bin/bash

# View container logs
docker-compose logs -f [service-name]

# Check service health
curl http://localhost:PORT/actuator/health

# Monitor resource usage
docker stats
```

## 🔄 Development Workflow

### 1. Start Development Environment
```bash
./scripts/docker-run.sh dev up
```

### 2. Make Code Changes
- Code changes are automatically reflected due to volume mounting
- Java services will auto-reload with Spring Boot DevTools
- Web frontend will hot-reload with Next.js

### 3. View Logs
```bash
./scripts/docker-run.sh dev logs
```

### 4. Stop Services
```bash
./scripts/docker-run.sh dev down
```

## 🚀 Production Deployment

### 1. Build Production Images
```bash
./scripts/docker-run.sh prod build
```

### 2. Start Production Services
```bash
./scripts/docker-run.sh prod up
```

### 3. Monitor Services
```bash
./scripts/docker-run.sh prod status
./scripts/docker-run.sh prod logs
```

### 4. Scale Services (if needed)
```bash
docker-compose -f docker-compose.prod.yml up --scale foodybuddy-orders=2
```

## 📝 Environment Variables

### Web Frontend
- `NODE_ENV`: production/development
- `NEXT_PUBLIC_API_URL`: API gateway URL

### Java Services
- `SPRING_PROFILES_ACTIVE`: dev/prod/docker
- `SPRING_DATASOURCE_URL`: Database connection URL
- `SPRING_H2_CONSOLE_ENABLED`: Enable H2 console

### Gateway Service
- `SPRING_CLOUD_GATEWAY_ROUTES`: Service routing configuration

## 🔧 Customization

### Adding New Services
1. Create service directory
2. Add Dockerfile and Dockerfile.dev
3. Update docker-compose files
4. Add service to docker-run.sh script

### Modifying Ports
1. Update Dockerfile EXPOSE directive
2. Update docker-compose port mapping
3. Update health check URLs
4. Update service discovery URLs

### Adding Environment Variables
1. Add to docker-compose environment section
2. Update Dockerfile if needed
3. Update documentation

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Spring Boot Docker Guide](https://spring.io/guides/gs/spring-boot-docker/)
- [Next.js Docker Guide](https://nextjs.org/docs/deployment#docker-image)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
