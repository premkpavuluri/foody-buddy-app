-- Initialize schemas for Foody Buddy application
-- This script runs when the PostgreSQL container starts for the first time

-- Create schemas for each service
CREATE SCHEMA IF NOT EXISTS gateway;
CREATE SCHEMA IF NOT EXISTS orders;
CREATE SCHEMA IF NOT EXISTS payments;

-- Grant permissions to the main user
GRANT ALL PRIVILEGES ON SCHEMA gateway TO foodybuddy_user;
GRANT ALL PRIVILEGES ON SCHEMA orders TO foodybuddy_user;
GRANT ALL PRIVILEGES ON SCHEMA payments TO foodybuddy_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA gateway GRANT ALL ON TABLES TO foodybuddy_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA orders GRANT ALL ON TABLES TO foodybuddy_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA payments GRANT ALL ON TABLES TO foodybuddy_user;

-- Create some example tables (optional - Spring Boot will create them automatically)
-- Gateway schema tables
CREATE TABLE IF NOT EXISTS gateway.users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders schema tables
CREATE TABLE IF NOT EXISTS orders.orders (
    id BIGSERIAL PRIMARY KEY,
    order_id VARCHAR(255) NOT NULL,
    total DOUBLE PRECISION NOT NULL,
    status VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders.order_items (
    id BIGSERIAL PRIMARY KEY,
    item_id VARCHAR(255) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    price DOUBLE PRECISION NOT NULL,
    order_id BIGINT,
    FOREIGN KEY (order_id) REFERENCES orders.orders(id)
);

-- Payments schema tables
CREATE TABLE IF NOT EXISTS payments.payments (
    id BIGSERIAL PRIMARY KEY,
    payment_id VARCHAR(255) NOT NULL UNIQUE,
    order_id VARCHAR(255) NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    status VARCHAR(50),
    method VARCHAR(50),
    transaction_id VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Gateway schema tables
CREATE TABLE IF NOT EXISTS gateway.gateway_orders (
    id BIGSERIAL PRIMARY KEY,
    order_id VARCHAR(255) UNIQUE NOT NULL,
    payment_id VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    user_id VARCHAR(255),
    total_amount DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_gateway_users_username ON gateway.users(username);
CREATE INDEX IF NOT EXISTS idx_gateway_orders_order_id ON gateway.gateway_orders(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_id ON orders.orders(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_items_order_id ON orders.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_id ON payments.payments(payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments.payments(order_id);

-- Insert some sample data (optional)
INSERT INTO gateway.users (username, email) VALUES 
    ('admin', 'admin@foodybuddy.com'),
    ('user1', 'user1@foodybuddy.com')
ON CONFLICT (username) DO NOTHING;

-- Show the created schemas
SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('gateway', 'orders', 'payments');
