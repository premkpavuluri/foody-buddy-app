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
CREATE TABLE IF NOT EXISTS orders.order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments schema tables
CREATE TABLE IF NOT EXISTS payments.transactions (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_gateway_users_username ON gateway.users(username);
CREATE INDEX IF NOT EXISTS idx_orders_items_order_id ON orders.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_transactions_order_id ON payments.transactions(order_id);

-- Insert some sample data (optional)
INSERT INTO gateway.users (username, email) VALUES 
    ('admin', 'admin@foodybuddy.com'),
    ('user1', 'user1@foodybuddy.com')
ON CONFLICT (username) DO NOTHING;

-- Show the created schemas
SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('gateway', 'orders', 'payments');
