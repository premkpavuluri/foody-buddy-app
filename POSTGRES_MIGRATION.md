# PostgreSQL Migration Guide

This document outlines the migration from H2 Database to PostgreSQL for the Foody Buddy application.

## Overview

The application has been migrated from H2 in-memory databases to PostgreSQL with the following architecture:

- **Database per Service**: Each microservice has its own dedicated PostgreSQL database
- **Development**: PostgreSQL containers with persistent volumes
- **Production**: PostgreSQL containers with persistent volumes and resource limits

## Database Configuration

### Service-Specific Databases

| Service | Database | Port | Username | Password |
|---------|----------|------|----------|----------|
| Gateway | `gatewaydb` | 5432 | `gateway_user` | `gateway_password` |
| Orders | `ordersdb` | 5433 | `orders_user` | `orders_password` |
| Payments | `paymentsdb` | 5434 | `payments_user` | `payments_password` |

### Development Environment

- **Ports**: 5432, 5433, 5434 (mapped to host)
- **Persistence**: Docker volumes for data persistence
- **Health Checks**: Enabled for all databases
- **Console Access**: Available through database clients

### Production Environment

- **Ports**: Internal only (not exposed to host)
- **Persistence**: Docker volumes with resource limits
- **Health Checks**: Enabled with retry logic
- **Security**: Environment variable passwords

## Quick Start

### Prerequisites

1. **Docker**: Version 20.10+ with Docker Compose
2. **Ports**: Ensure ports 3000, 8080-8082, 5432-5434 are available

### Development Setup

```bash
# Start development environment
./start-postgres.sh start dev

# Or using docker-compose directly
docker-compose -f docker-compose.dev.yml up --build
```

### Production Setup

```bash
# Start production environment
./start-postgres.sh start prod

# Or using docker-compose directly
docker-compose -f docker-compose.prod.yml up --build -d
```

### Local Setup (Default)

```bash
# Start local environment
./start-postgres.sh start local

# Or using docker-compose directly
docker-compose up --build -d
```

## Application URLs

Once started, the application will be available at:

- **Web Application**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **Orders Service**: http://localhost:8081
- **Payments Service**: http://localhost:8082

## Database Access

### Development Environment

Connect to databases using any PostgreSQL client:

```bash
# Gateway Database
psql -h localhost -p 5432 -U gateway_user -d gatewaydb

# Orders Database
psql -h localhost -p 5433 -U orders_user -d ordersdb

# Payments Database
psql -h localhost -p 5434 -U payments_user -d paymentsdb
```

### Using Docker

```bash
# Connect to Gateway database
docker exec -it postgres-gateway-dev psql -U gateway_user -d gatewaydb

# Connect to Orders database
docker exec -it postgres-orders-dev psql -U orders_user -d ordersdb

# Connect to Payments database
docker exec -it postgres-payments-dev psql -U payments_user -d paymentsdb
```

## Management Commands

### Using the Startup Script

```bash
# Show help
./start-postgres.sh help

# Start development environment
./start-postgres.sh start dev

# Start production environment
./start-postgres.sh start prod

# Show application status
./start-postgres.sh status

# Show logs for all services
./start-postgres.sh logs

# Show logs for specific service
./start-postgres.sh logs gateway

# Stop application
./start-postgres.sh stop

# Clean up everything
./start-postgres.sh cleanup
```

### Using Docker Compose

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild and start
docker-compose up --build -d
```

## Environment Variables

### Production Environment

Set these environment variables for production:

```bash
export POSTGRES_GATEWAY_PASSWORD="your_secure_gateway_password"
export POSTGRES_ORDERS_PASSWORD="your_secure_orders_password"
export POSTGRES_PAYMENTS_PASSWORD="your_secure_payments_password"
```

### Development Environment

Default passwords are used for development. Change them in the docker-compose files if needed.

## Data Persistence

### Volumes

Data is persisted in Docker volumes:

- `foodybuddy-postgres-gateway-dev` (Development)
- `foodybuddy-postgres-orders-dev` (Development)
- `foodybuddy-postgres-payments-dev` (Development)
- `foodybuddy-postgres-gateway-prod` (Production)
- `foodybuddy-postgres-orders-prod` (Production)
- `foodybuddy-postgres-payments-prod` (Production)

### Backup

To backup your data:

```bash
# Backup Gateway database
docker exec postgres-gateway-dev pg_dump -U gateway_user gatewaydb > gateway_backup.sql

# Backup Orders database
docker exec postgres-orders-dev pg_dump -U orders_user ordersdb > orders_backup.sql

# Backup Payments database
docker exec postgres-payments-dev pg_dump -U payments_user paymentsdb > payments_backup.sql
```

### Restore

To restore from backup:

```bash
# Restore Gateway database
docker exec -i postgres-gateway-dev psql -U gateway_user -d gatewaydb < gateway_backup.sql

# Restore Orders database
docker exec -i postgres-orders-dev psql -U orders_user -d ordersdb < orders_backup.sql

# Restore Payments database
docker exec -i postgres-payments-dev psql -U payments_user -d paymentsdb < payments_backup.sql
```

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure ports 3000, 8080-8082, 5432-5434 are available
2. **Permission Issues**: Run `chmod +x start-postgres.sh` to make script executable
3. **Database Connection Issues**: Check if PostgreSQL containers are healthy
4. **Memory Issues**: Ensure Docker has enough memory allocated

### Health Checks

Check service health:

```bash
# Check all services
docker-compose ps

# Check specific service logs
docker-compose logs gateway

# Check database connectivity
docker exec postgres-gateway-dev pg_isready -U gateway_user -d gatewaydb
```

### Logs

View logs for debugging:

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f gateway
docker-compose logs -f orders
docker-compose logs -f payments
docker-compose logs -f web
```

## Migration Benefits

1. **Data Persistence**: Data survives container restarts
2. **Better Performance**: PostgreSQL is optimized for production workloads
3. **Scalability**: Can handle higher concurrent loads
4. **Backup & Recovery**: Standard PostgreSQL backup tools
5. **Monitoring**: Better monitoring and observability
6. **Production Ready**: Suitable for production deployments

## Next Steps

1. **Monitoring**: Set up database monitoring (Prometheus, Grafana)
2. **Backup Strategy**: Implement automated backup schedules
3. **Security**: Use secrets management for production passwords
4. **Scaling**: Consider read replicas for high-traffic scenarios
5. **Migration Scripts**: Add Flyway/Liquibase for schema versioning

## Support

For issues or questions:

1. Check the logs: `./start-postgres.sh logs`
2. Verify Docker is running: `docker info`
3. Check port availability: `netstat -tulpn | grep :5432`
4. Review this documentation for common solutions
