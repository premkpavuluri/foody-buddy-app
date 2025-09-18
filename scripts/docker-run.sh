#!/bin/bash

# FoodyBuddy Docker Services Runner Script
# Runs all services using Docker Compose

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

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if images exist
check_images_exist() {
    local compose_file=$1
    local environment=$2
    local missing_images=()
    
    # Get all service names from compose file
    local services=$(docker-compose -f $compose_file config --services 2>/dev/null)
    
    for service in $services; do
        # Skip postgres as it uses a public image
        if [ "$service" = "postgres" ]; then
            continue
        fi
        
        # Map service names to our naming convention
        local service_name=""
        case $service in
            foodybuddy-web)
                service_name="web"
                ;;
            foodybuddy-gateway)
                service_name="gateway"
                ;;
            foodybuddy-orders)
                service_name="orders"
                ;;
            foodybuddy-payments)
                service_name="payments"
                ;;
            *)
                service_name="$service"
                ;;
        esac
        
        # Check for the new pattern: foodybuddy.{env}.{service}:latest
        local actual_image_name="foodybuddy.${environment}.${service_name}:latest"
        if ! docker image inspect "$actual_image_name" > /dev/null 2>&1; then
            missing_images+=("$service")
        fi
    done
    
    echo "${missing_images[@]}"
}

# Function to show usage
show_usage() {
    echo "🍕 FoodyBuddy Docker Services Runner"
    echo ""
    echo "DESCRIPTION:"
    echo "  Manages FoodyBuddy microservices using Docker and Docker Compose."
    echo "  Supports multiple environments with different configurations."
    echo ""
    echo "USAGE:"
    echo "  $0 [ENVIRONMENT] [COMMAND] [OPTIONS]"
    echo ""
    echo "ENVIRONMENTS:"
    echo "  dev     - Development environment with hot reloading"
    echo "  prod    - Production environment with optimizations"
    echo "  default - Standard environment (default)"
    echo ""
    echo "COMMANDS:"
    echo "  up      - Start all services (default)"
    echo "  down    - Stop all services"
    echo "  build   - Build all images"
    echo "  logs    - Show logs for all services"
    echo "  status  - Show status of all services"
    echo "  clean   - Clean up containers, images, and volumes"
    echo "  -h, --help - Show this help message"
    echo ""
    echo "OPTIONS:"
    echo "  --build - Build images when starting services"
    echo "           (Images are automatically built if missing)"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 dev up         # Start development environment (build if needed)"
    echo "  $0 dev up --build # Build and start development environment"
    echo "  $0 prod build     # Build production images"
    echo "  $0 down           # Stop all services"
    echo "  $0 dev logs       # View development logs"
    echo "  $0 prod status    # Check production status"
    echo "  $0 clean          # Clean up everything"
    echo ""
    echo "SERVICES:"
    echo "  📦 Orders Service    - Port 8081 (Spring Boot)"
    echo "  💳 Payments Service  - Port 8082 (Spring Boot)"
    echo "  🚪 Gateway Service   - Port 8080 (Spring Boot)"
    echo "  🌐 Web Frontend      - Port 3000 (Next.js)"
    echo ""
    echo "SERVICES AVAILABLE AT:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🚪 Gateway:  http://localhost:8080"
    echo "  📦 Orders:   http://localhost:8081"
    echo "  💳 Payments: http://localhost:8082"
    echo ""
    echo "ENVIRONMENT DIFFERENCES:"
    echo "  Development (dev):"
    echo "    - Hot reloading enabled"
    echo "    - Volume mounting for live code changes"
    echo "    - Development Dockerfiles"
    echo "    - Faster startup times"
    echo ""
    echo "  Production (prod):"
    echo "    - Optimized for performance"
    echo "    - Resource limits and reservations"
    echo "    - Persistent data volumes"
    echo "    - Production configurations"
    echo ""
    echo "  Default:"
    echo "    - Standard environment"
    echo "    - Health checks enabled"
    echo "    - Service dependencies"
    echo "    - Restart policies"
    echo ""
    echo "TROUBLESHOOTING:"
    echo "  - Use 'docker-compose logs [service]' for specific service logs"
    echo "  - Use 'docker ps' to see running containers"
    echo "  - Use 'docker system prune' to clean up Docker resources"
    echo "  - Check Docker Desktop is running"
    echo "  - Ensure ports are not in use by other applications"
}

# Main function
main() {
    local environment=${1:-"default"}
    local command=${2:-"up"}
    local force_build=false
    
    # Handle help commands
    if [[ "$environment" == "-h" || "$environment" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    if [[ "$command" == "-h" || "$command" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Check for --build flag in any position
    for arg in "$@"; do
        if [[ "$arg" == "--build" ]]; then
            force_build=true
            break
        fi
    done
    
    # Validate environment
    case $environment in
        dev|prod|default)
            ;;
        *)
            print_error "Invalid environment: $environment"
            show_usage
            exit 1
            ;;
    esac
    
    # Validate command
    case $command in
        up|down|build|logs|status|clean)
            ;;
        *)
            print_error "Invalid command: $command"
            show_usage
            exit 1
            ;;
    esac
    
    # Check Docker
    check_docker
    
    # Set compose file based on environment
    local compose_file="docker-compose.prod.yml"
    if [ "$environment" = "dev" ]; then
        compose_file="docker-compose.dev.yml"
    elif [ "$environment" = "prod" ]; then
        compose_file="docker-compose.prod.yml"
    fi
    
    print_status "Using environment: $environment"
    print_status "Using compose file: $compose_file"
    
    # Execute command
    case $command in
        up)
            print_status "🍕 Starting FoodyBuddy services with Docker..."
            
            # Check if images exist or if --build flag is provided
            if [ "$force_build" = true ]; then
                print_status "Building all images..."
                docker-compose -f $compose_file build
            else
                # Check for missing images
                local missing_images=($(check_images_exist $compose_file $environment))
                if [ ${#missing_images[@]} -gt 0 ]; then
                    print_warning "Missing images detected: ${missing_images[*]}"
                    print_status "Building missing images..."
                    docker-compose -f $compose_file build
                else
                    print_status "All images found, starting services..."
                fi
            fi
            
            # Start services
            docker-compose -f $compose_file up -d
            print_success "All services started!"
            echo ""
            echo "Services available at:"
            echo "  🌐 Frontend: http://localhost:3000"
            echo "  🚪 Gateway:  http://localhost:8080"
            echo "  📦 Orders:   http://localhost:8081"
            echo "  💳 Payments: http://localhost:8082"
            echo ""
            print_status "Use '$0 $environment logs' to view logs"
            print_status "Use '$0 $environment down' to stop services"
            ;;
        down)
            print_status "Stopping all services..."
            docker-compose -f $compose_file down
            print_success "All services stopped!"
            ;;
        build)
            print_status "Building all images..."
            docker-compose -f $compose_file build --no-cache
            print_success "All images built!"
            ;;
        logs)
            print_status "Showing logs for all services..."
            docker-compose -f $compose_file logs -f
            ;;
        status)
            print_status "Service status:"
            docker-compose -f $compose_file ps
            ;;
        clean)
            print_warning "This will remove all containers, images, and volumes. Are you sure? (y/N)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                print_status "Cleaning up Docker resources..."
                docker-compose -f $compose_file down -v --rmi all
                docker system prune -f
                print_success "Cleanup completed!"
            else
                print_status "Cleanup cancelled."
            fi
            ;;
    esac
}

# Run main function
main "$@"
