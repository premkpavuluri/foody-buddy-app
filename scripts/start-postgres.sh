#!/bin/bash

# Foody Buddy Application Startup Script with PostgreSQL
# This script starts the application with PostgreSQL databases

set -e

echo "🚀 Starting Foody Buddy Application with PostgreSQL..."

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker and try again."
        exit 1
    fi
    echo "✅ Docker is running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi
    echo "✅ Docker Compose is available"
}

# Function to clean up existing containers and volumes
cleanup() {
    echo "🧹 Cleaning up existing containers and volumes..."
    docker-compose down -v --remove-orphans 2>/dev/null || true
    docker system prune -f
}

# Function to start the application
start_app() {
    local environment=${1:-dev}
    
    echo "📦 Starting Foody Buddy Application in $environment mode..."
    
    case $environment in
        "dev")
            echo "🔧 Starting development environment with hot reload..."
            docker-compose -f docker-compose.dev.yml up --build
            ;;
        "prod")
            echo "🏭 Starting production environment..."
            docker-compose -f docker-compose.prod.yml up --build -d
            ;;
        "local")
            echo "🏠 Starting local environment..."
            docker-compose up --build -d
            ;;
        *)
            echo "❌ Invalid environment. Use: dev, prod, or local"
            exit 1
            ;;
    esac
}

# Function to show application status
show_status() {
    echo "📊 Application Status:"
    echo "====================="
    
    # Check if containers are running
    if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(foodybuddy|postgres)"; then
        echo ""
        echo "🌐 Application URLs:"
        echo "  Web App:     http://localhost:3000"
        echo "  Gateway:     http://localhost:8080"
        echo "  Orders API:  http://localhost:8081"
        echo "  Payments API: http://localhost:8082"
        echo ""
        echo "🗄️  Database URLs:"
        echo "  Single DB:   localhost:5432 (foodybuddy)"
        echo "  Schemas:     gateway, orders, payments"
    else
        echo "❌ No containers are running"
    fi
}

# Function to show logs
show_logs() {
    local service=${1:-all}
    
    if [ "$service" = "all" ]; then
        echo "📋 Showing logs for all services..."
        docker-compose logs -f
    elif [ "$service" = "db" ] || [ "$service" = "postgres" ]; then
        echo "📋 Showing logs for PostgreSQL database..."
        docker-compose logs -f postgres
    else
        echo "📋 Showing logs for $service service..."
        docker-compose logs -f $service
    fi
}

# Function to stop the application
stop_app() {
    echo "🛑 Stopping Foody Buddy Application..."
    docker-compose down
    echo "✅ Application stopped"
}

# Function to show help
show_help() {
    echo "Foody Buddy Application Startup Script"
    echo "======================================"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start [env]    Start the application (dev|prod|local)"
    echo "  stop           Stop the application"
    echo "  status         Show application status"
    echo "  logs [service] Show logs (all|gateway|orders|payments|web|postgres)"
    echo "  cleanup        Clean up containers and volumes"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start dev     # Start development environment"
    echo "  $0 start prod    # Start production environment"
    echo "  $0 logs gateway  # Show gateway logs"
    echo "  $0 logs postgres # Show database logs"
    echo "  $0 status        # Show application status"
}

# Main script logic
main() {
    case ${1:-help} in
        "start")
            check_docker
            check_docker_compose
            start_app ${2:-dev}
            ;;
        "stop")
            stop_app
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs ${2:-all}
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"
