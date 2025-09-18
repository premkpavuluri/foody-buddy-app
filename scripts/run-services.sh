#!/bin/bash

# FoodyBuddy Services Runner Script
# Runs all services using Gradle (Java services) and Yarn (Web frontend)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show help
show_help() {
    echo "🍕 FoodyBuddy Services Runner"
    echo ""
    echo "DESCRIPTION:"
    echo "  Runs all FoodyBuddy microservices locally using Gradle and Yarn."
    echo "  Services run in the background with comprehensive logging and process management."
    echo ""
    echo "USAGE:"
    echo "  $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message and exit"
    echo "  --status       Show status of running services"
    echo "  --logs         Show logs for all services"
    echo "  --stop         Stop all running services"
    echo "  --restart      Restart all services"
    echo "  --clean        Clean up logs and stop all services"
    echo ""
    echo "SERVICES:"
    echo "  📦 Orders Service    - Port 8081 (Gradle)"
    echo "  💳 Payments Service  - Port 8082 (Gradle)"
    echo "  🚪 Gateway Service   - Port 8080 (Gradle)"
    echo "  🌐 Web Frontend      - Port 3000 (Yarn)"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                    # Start all services"
    echo "  $0 --status           # Check service status"
    echo "  $0 --logs             # View service logs"
    echo "  $0 --stop             # Stop all services"
    echo "  $0 --restart          # Restart all services"
    echo ""
    echo "LOGS:"
    echo "  Service logs are saved to the 'logs/' directory:"
    echo "  - logs/gateway.log"
    echo "  - logs/orders.log"
    echo "  - logs/payments.log"
    echo "  - logs/web.log"
    echo ""
    echo "SERVICES AVAILABLE AT:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🚪 Gateway:  http://localhost:8080"
    echo "  📦 Orders:   http://localhost:8081"
    echo "  💳 Payments: http://localhost:8082"
    echo ""
    echo "TROUBLESHOOTING:"
    echo "  - If services won't start, check logs in 'logs/' directory"
    echo "  - Ensure ports 3000, 8080, 8081, 8082 are available"
    echo "  - Verify Java, Gradle, Node.js, and Yarn are installed"
    echo "  - Use '--clean' to reset everything"
    echo ""
    echo "Press Ctrl+C to stop all services while running"
}

# Function to check if a port is in use
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Function to kill processes on specific ports
kill_port() {
    local port=$1
    if port_in_use $port; then
        print_warning "Port $port is in use. Attempting to free it..."
        lsof -ti :$port | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

# Function to run a service in background
run_service() {
    local service_name=$1
    local service_dir=$2
    local command=$3
    local port=$4
    
    print_status "Starting $service_name..."
    
    cd "$service_dir"
    
    # Kill any existing process on the port
    kill_port $port
    
    # Run the service in background
    nohup $command > "${PROJECT_ROOT}/logs/${service_name}.log" 2>&1 &
    local pid=$!
    echo $pid > "${PROJECT_ROOT}/logs/${service_name}.pid"
    
    # Wait a moment and check if the process is still running
    sleep 3
    if kill -0 $pid 2>/dev/null; then
        print_success "$service_name started successfully (PID: $pid, Port: $port)"
    else
        print_error "$service_name failed to start. Check logs/${service_name}.log for details."
        return 1
    fi
    
    cd - > /dev/null
}

# Function to cleanup on exit
cleanup() {
    print_status "Shutting down all services..."
    
    # Kill all services
    for service in gateway orders payments web; do
        if [ -f "${PROJECT_ROOT}/logs/${service}.pid" ]; then
            local pid=$(cat "${PROJECT_ROOT}/logs/${service}.pid")
            if kill -0 $pid 2>/dev/null; then
                print_status "Stopping $service (PID: $pid)..."
                kill $pid 2>/dev/null || true
            fi
            rm -f "${PROJECT_ROOT}/logs/${service}.pid"
        fi
    done
    
    # Kill any remaining processes on our ports
    kill_port 8080  # Gateway
    kill_port 8081  # Orders
    kill_port 8082  # Payments
    kill_port 3000  # Web
    
    print_success "All services stopped."
    exit 0
}

# Set project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Function to show service status
show_status() {
    print_status "Service Status:"
    echo ""
    
    for service in gateway orders payments web; do
        if [ -f "${PROJECT_ROOT}/logs/${service}.pid" ]; then
            local pid=$(cat "${PROJECT_ROOT}/logs/${service}.pid")
            if kill -0 $pid 2>/dev/null; then
                print_success "$service is running (PID: $pid)"
            else
                print_error "$service is not running (stale PID file)"
            fi
        else
            print_error "$service is not running"
        fi
    done
    
    echo ""
    print_status "Port Status:"
    for port in 3000 8080 8081 8082; do
        if port_in_use $port; then
            print_success "Port $port is in use"
        else
            print_error "Port $port is free"
        fi
    done
}

# Function to show logs
show_logs() {
    print_status "Showing logs for all services..."
    echo ""
    
    for service in gateway orders payments web; do
        if [ -f "${PROJECT_ROOT}/logs/${service}.log" ]; then
            echo "=== $service logs ==="
            tail -20 "${PROJECT_ROOT}/logs/${service}.log"
            echo ""
        else
            print_error "No logs found for $service"
        fi
    done
}

# Function to stop services
stop_services() {
    print_status "Stopping all services..."
    cleanup
}

# Function to restart services
restart_services() {
    print_status "Restarting all services..."
    stop_services
    sleep 2
    main
}

# Function to clean up
clean_services() {
    print_status "Cleaning up logs and stopping services..."
    stop_services
    rm -rf "${PROJECT_ROOT}/logs"
    print_success "Cleanup completed!"
}

# Main execution
main() {
    # Parse command line arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        --status)
            show_status
            exit 0
            ;;
        --logs)
            show_logs
            exit 0
            ;;
        --stop)
            stop_services
            exit 0
            ;;
        --restart)
            restart_services
            exit 0
            ;;
        --clean)
            clean_services
            exit 0
            ;;
        "")
            # No arguments, continue with normal execution
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
    
    print_status "🍕 Starting FoodyBuddy Microservices..."
    
    # Check prerequisites
    if ! command_exists java; then
        print_error "Java is not installed. Please install Java 17 or higher."
        exit 1
    fi
    
    if ! command_exists gradle; then
        print_error "Gradle is not installed. Please install Gradle."
        exit 1
    fi
    
    if ! command_exists yarn; then
        print_error "Yarn is not installed. Please install Yarn."
        exit 1
    fi
    
    if ! command_exists node; then
        print_error "Node.js is not installed. Please install Node.js."
        exit 1
    fi
    
    # Create logs directory
    mkdir -p "${PROJECT_ROOT}/logs"
    
    # Clean up any existing processes
    print_status "Cleaning up any existing processes..."
    kill_port 8080
    kill_port 8081
    kill_port 8082
    kill_port 3000
    
    # Start Java services with Gradle
    print_status "Building and starting Java services..."
    
    # Start Orders service
    run_service "orders" "foodybuddy-orders" "./gradlew bootRun" 8081
    
    # Start Payments service
    run_service "payments" "foodybuddy-payments" "./gradlew bootRun" 8082
    
    # Wait a bit for the backend services to start
    print_status "Waiting for backend services to initialize..."
    sleep 10
    
    # Start Gateway service
    run_service "gateway" "foodybuddy-gateway" "./gradlew bootRun" 8080
    
    # Wait for gateway to start
    print_status "Waiting for gateway to initialize..."
    sleep 5
    
    # Start Web frontend with Yarn
    print_status "Installing web dependencies and starting frontend..."
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "foodybuddy-web/node_modules" ]; then
        print_status "Installing web dependencies..."
        cd foodybuddy-web
        yarn install
        cd - > /dev/null
    fi
    
    # Start the web service
    run_service "web" "foodybuddy-web" "yarn dev" 3000
    
    # Display service information
    echo ""
    print_success "🎉 All services are running!"
    echo ""
    echo "Services available at:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🚪 Gateway:  http://localhost:8080"
    echo "  📦 Orders:   http://localhost:8081"
    echo "  💳 Payments: http://localhost:8082"
    echo ""
    echo "Logs are available in the 'logs/' directory:"
    echo "  - logs/gateway.log"
    echo "  - logs/orders.log"
    echo "  - logs/payments.log"
    echo "  - logs/web.log"
    echo ""
    print_status "Press Ctrl+C to stop all services"
    
    # Keep the script running and wait for interrupt
    while true; do
        sleep 1
    done
}

# Run main function
main "$@"
