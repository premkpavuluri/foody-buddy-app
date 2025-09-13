# Single Database Migration Guide

This document outlines the migration from multiple PostgreSQL databases to a single database with separate schemas for the Foody Buddy application.

## Overview

The application has been migrated from multiple databases (one per service) to a single PostgreSQL database with schema-based separation:

- **Single Database**: `foodybuddy` 
- **Schema Separation**: `gateway`, `orders`, `payments`
- **Single Connection**: All services connect to the same database instance
- **Data Isolation**: Each service operates within its own schema

## Database Architecture

### Before (Multi-Database)
```
postgres-gateway:5432  → gatewaydb
postgres-orders:5433   → ordersdb  
postgres-payments:5434 → paymentsdb
```

### After (Single Database with Schemas)
```
postgres:5432 → foodybuddy
├── gateway schema
├── orders schema
└── payments schema
```

## Configuration Changes

### 1. Database Connection URLs

**Before:**
```yaml
# Gateway
url: jdbc:postgresql://localhost:5432/gatewaydb

# Orders  
url: jdbc:postgresql://localhost:5433/ordersdb

# Payments
url: jdbc:postgresql://localhost:5434/paymentsdb
```

**After:**
```yaml
# Gateway
url: jdbc:postgresql://localhost:5432/foodybuddy?currentSchema=gateway

# Orders
url: jdbc:postgresql://localhost:5432/foodybuddy?currentSchema=orders

# Payments
url: jdbc:postgresql://localhost:5432/foodybuddy?currentSchema=payments
```

### 2. Hibernate Configuration

**Before:**
```yaml
jpa:
  properties:
    hibernate:
      dialect: org.hibernate.dialect.PostgreSQLDialect
```

**After:**
```yaml
jpa:
  properties:
    hibernate:
      dialect: org.hibernate.dialect.PostgreSQLDialect
      default_schema: gateway  # or orders, payments
```

### 3. Docker Compose Changes

**Before:**
```yaml
services:
  postgres-gateway:
    image: postgres:15
    environment:
      POSTGRES_DB: gatewaydb
      POSTGRES_USER: gateway_user
      POSTGRES_PASSWORD: gateway_password
    ports:
      - "5432:5432"
  
  postgres-orders:
    image: postgres:15
    environment:
      POSTGRES_DB: ordersdb
      POSTGRES_USER: orders_user
      POSTGRES_PASSWORD: orders_password
    ports:
      - "5433:5432"
      
  postgres-payments:
    image: postgres:15
    environment:
      POSTGRES_DB: paymentsdb
      POSTGRES_USER: payments_user
      POSTGRES_PASSWORD: payments_password
    ports:
      - "5434:5432"
```

**After:**
```yaml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: foodybuddy
      POSTGRES_USER: foodybuddy_user
      POSTGRES_PASSWORD: foodybuddy_password
    ports:
      - "5432:5432"
    volumes:
      - ./init-schemas.sql:/docker-entrypoint-initdb.d/init-schemas.sql
```

## Schema Initialization

The `init-schemas.sql` script automatically creates the required schemas:

```sql
-- Create schemas for each service
CREATE SCHEMA IF NOT EXISTS gateway;
CREATE SCHEMA IF NOT EXISTS orders;
CREATE SCHEMA IF NOT EXISTS payments;

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA gateway TO foodybuddy_user;
GRANT ALL PRIVILEGES ON SCHEMA orders TO foodybuddy_user;
GRANT ALL PRIVILEGES ON SCHEMA payments TO foodybuddy_user;
```

## Quick Start

### Development Environment

```bash
# Start development environment
./start-postgres.sh start dev

# Or using docker-compose directly
docker-compose -f docker-compose.dev.yml up --build
```

### Production Environment

```bash
# Start production environment
./start-postgres.sh start prod

# Or using docker-compose directly
docker-compose -f docker-compose.prod.yml up --build -d
```

### Local Environment (Default)

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

### Single Database Connection

```bash
# Connect to the single database
psql -h localhost -p 5432 -U foodybuddy_user -d foodybuddy

# List all schemas
\dn

# Switch to a specific schema
SET search_path TO gateway;
SET search_path TO orders;
SET search_path TO payments;
```

### Using Docker

```bash
# Connect to the database
docker exec -it postgres-foodybuddy psql -U foodybuddy_user -d foodybuddy

# List schemas
\dn

# Query specific schema tables
SELECT * FROM gateway.users;
SELECT * FROM orders.order_items;
SELECT * FROM payments.transactions;
```

## Schema Management

### Viewing Schema Contents

```sql
-- List all tables in gateway schema
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'gateway';

-- List all tables in orders schema
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'orders';

-- List all tables in payments schema
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'payments';
```

### Cross-Schema Queries

```sql
-- Query across schemas (if needed)
SELECT g.username, o.order_id, p.amount
FROM gateway.users g
JOIN orders.order_items o ON g.id = o.user_id
JOIN payments.transactions p ON o.order_id = p.order_id;
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
./start-postgres.sh logs postgres

# Stop application
./start-postgres.sh stop

# Clean up everything
./start-postgres.sh cleanup
```

## Benefits of Single Database Approach

### 1. **Simplified Management**
- Single database instance to manage
- Single backup/restore process
- Reduced resource usage

### 2. **Better Performance**
- Shared connection pool
- Reduced network overhead
- Better query optimization

### 3. **Easier Development**
- Single database connection
- Simplified local development
- Easier debugging and monitoring

### 4. **Cost Effective**
- Single database instance
- Reduced infrastructure costs
- Lower maintenance overhead

### 5. **Cross-Service Queries**
- Possible to query across schemas
- Better data consistency
- Easier reporting and analytics

## Migration Benefits

1. **Resource Efficiency**: Single database instance instead of three
2. **Simplified Operations**: One database to backup, monitor, and maintain
3. **Better Performance**: Shared resources and connection pooling
4. **Easier Development**: Single connection string and database
5. **Cost Reduction**: Lower infrastructure and operational costs
6. **Schema Isolation**: Data remains logically separated by schemas

## Troubleshooting

### Common Issues

1. **Schema Not Found**: Ensure `init-schemas.sql` is properly mounted
2. **Permission Issues**: Check schema permissions in the init script
3. **Connection Issues**: Verify database is healthy and accessible
4. **Schema Conflicts**: Ensure each service uses its designated schema

### Health Checks

```bash
# Check database health
docker exec postgres-foodybuddy pg_isready -U foodybuddy_user -d foodybuddy

# Check schema existence
docker exec postgres-foodybuddy psql -U foodybuddy_user -d foodybuddy -c "\dn"

# Check service connectivity
docker-compose ps
```

### Logs

```bash
# Database logs
./start-postgres.sh logs postgres

# All service logs
./start-postgres.sh logs

# Specific service logs
./start-postgres.sh logs gateway
```

## Data Persistence

### Backup

```bash
# Backup entire database with all schemas
docker exec postgres-foodybuddy pg_dump -U foodybuddy_user foodybuddy > foodybuddy_backup.sql

# Backup specific schema
docker exec postgres-foodybuddy pg_dump -U foodybuddy_user -n gateway foodybuddy > gateway_backup.sql
```

### Restore

```bash
# Restore entire database
docker exec -i postgres-foodybuddy psql -U foodybuddy_user -d foodybuddy < foodybuddy_backup.sql

# Restore specific schema
docker exec -i postgres-foodybuddy psql -U foodybuddy_user -d foodybuddy < gateway_backup.sql
```

## Next Steps

1. **Monitoring**: Set up database monitoring for the single instance
2. **Backup Strategy**: Implement automated backup for the single database
3. **Security**: Review and update security policies for schema access
4. **Performance Tuning**: Optimize the single database for all services
5. **Documentation**: Update API documentation to reflect schema changes

## Support

For issues or questions:

1. Check the logs: `./start-postgres.sh logs`
2. Verify database health: `docker exec postgres-foodybuddy pg_isready`
3. Check schema existence: `docker exec postgres-foodybuddy psql -U foodybuddy_user -d foodybuddy -c "\dn"`
4. Review this documentation for common solutions
