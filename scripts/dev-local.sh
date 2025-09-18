#!/bin/bash

# Quick Development Script for FoodyBuddy
# Simple script to run services in separate terminals

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

# Function to show help
show_help() {
    echo "🍕 FoodyBuddy Development Runner"
    echo ""
    echo "DESCRIPTION:"
    echo "  Opens each FoodyBuddy service in a separate terminal window for easy debugging."
    echo "  Perfect for development with live code changes and individual service monitoring."
    echo ""
    echo "USAGE:"
    echo "  $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message and exit"
    echo "  --status       Show status of running services"
    echo "  --stop         Stop all running services"
    echo "  --restart      Restart all services"
    echo ""
    echo "SERVICES:"
    echo "  📦 Orders Service    - Port 8081 (Gradle)"
    echo "  💳 Payments Service  - Port 8082 (Gradle)"
    echo "  🚪 Gateway Service   - Port 8080 (Gradle)"
    echo "  🌐 Web Frontend      - Port 3000 (Yarn)"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                    # Start all services in separate terminals"
    echo "  $0 --status           # Check service status"
    echo "  $0 --stop             # Stop all services"
    echo "  $0 --restart          # Restart all services"
    echo ""
    echo "FEATURES:"
    echo "  - Each service runs in its own terminal window"
    echo "  - Easy to see individual service logs"
    echo "  - Perfect for development and debugging"
    echo "  - Hot reloading for all services"
    echo "  - Cross-platform terminal support"
    echo ""
    echo "SERVICES AVAILABLE AT:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🚪 Gateway:  http://localhost:8080"
    echo "  📦 Orders:   http://localhost:8081"
    echo "  💳 Payments: http://localhost:8082"
    echo ""
    echo "TROUBLESHOOTING:"
    echo "  - Close individual terminal windows to stop services"
    echo "  - Press Ctrl+C in each terminal to stop individual services"
    echo "  - Ensure ports 3000, 8080, 8081, 8082 are available"
    echo "  - Verify Java, Gradle, Node.js, and Yarn are installed"
}

# Function to check if a port is in use
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Function to show service status
show_status() {
    print_status "Service Status:"
    echo ""
    
    for port in 3000 8080 8081 8082; do
        if port_in_use $port; then
            case $port in
                3000) print_success "Web Frontend is running on port $port" ;;
                8080) print_success "Gateway Service is running on port $port" ;;
                8081) print_success "Orders Service is running on port $port" ;;
                8082) print_success "Payments Service is running on port $port" ;;
            esac
        else
            case $port in
                3000) print_error "Web Frontend is not running on port $port" ;;
                8080) print_error "Gateway Service is not running on port $port" ;;
                8081) print_error "Orders Service is not running on port $port" ;;
                8082) print_error "Payments Service is not running on port $port" ;;
            esac
        fi
    done
}

# Function to stop services
stop_services() {
    print_status "Stopping all services..."
    
    # Kill processes on our ports
    for port in 3000 8080 8081 8082; do
        if port_in_use $port; then
            print_status "Stopping service on port $port..."
            lsof -ti :$port | xargs kill -9 2>/dev/null || true
        fi
    done
    
    print_success "All services stopped!"
}

# Function to restart services
restart_services() {
    print_status "Restarting all services..."
    stop_services
    sleep 2
    main
}

# Main function
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
        --stop)
            stop_services
            exit 0
            ;;
        --restart)
            restart_services
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

    # Check if we're on macOS (for open command)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        TERMINAL_CMD="open -a Terminal"
    else
        TERMINAL_CMD="gnome-terminal"
    fi

    print_status "🍕 Starting FoodyBuddy services in separate terminals..."

    # Create logs directory
    mkdir -p logs

    # Function to run service in new terminal
    run_in_terminal() {
        local service_name=$1
        local service_dir=$2
        local command=$3
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            osascript -e "tell application \"Terminal\" to do script \"cd '$(pwd)/$service_dir' && $command\""
        else
            $TERMINAL_CMD -- bash -c "cd '$(pwd)/$service_dir' && $command; exec bash"
        fi
    }

    # Start Orders service
    print_status "Starting Orders service..."
    run_in_terminal "Orders" "foodybuddy-orders" "./gradlew bootRun"

    # Start Payments service
    print_status "Starting Payments service..."
    run_in_terminal "Payments" "foodybuddy-payments" "./gradlew bootRun"

    # Wait a moment
    sleep 3

    # Start Gateway service
    print_status "Starting Gateway service..."
    run_in_terminal "Gateway" "foodybuddy-gateway" "./gradlew bootRun"

    # Wait a moment
    sleep 3

    # Start Web service
    print_status "Starting Web service..."
    run_in_terminal "Web" "foodybuddy-web" "yarn dev"

    print_success "All services started in separate terminals!"
    echo ""
    echo "Services will be available at:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🚪 Gateway:  http://localhost:8080"
    echo "  📦 Orders:   http://localhost:8081"
    echo "  💳 Payments: http://localhost:8082"
    echo ""
    echo "To stop services, close the respective terminal windows or press Ctrl+C in each."
}

# Run main function
main "$@"
