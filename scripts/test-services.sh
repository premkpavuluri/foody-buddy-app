#!/bin/bash

# Test script to check if all services are ready

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
    echo "🧪 FoodyBuddy Services Tester"
    echo ""
    echo "DESCRIPTION:"
    echo "  Tests the availability and functionality of all FoodyBuddy services."
    echo "  Checks service health endpoints and performs a test checkout."
    echo ""
    echo "USAGE:"
    echo "  $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message and exit"
    echo "  --health       Only check service health (no checkout test)"
    echo "  --checkout     Only test checkout functionality"
    echo "  --verbose      Show detailed output"
    echo ""
    echo "SERVICES TESTED:"
    echo "  📦 Orders Service    - Port 8081 (Spring Boot)"
    echo "  💳 Payments Service  - Port 8082 (Spring Boot)"
    echo "  🚪 Gateway Service   - Port 8080 (Spring Boot)"
    echo "  🌐 Web Frontend      - Port 3000 (Next.js)"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                    # Test all services and checkout"
    echo "  $0 --health           # Only check service health"
    echo "  $0 --checkout         # Only test checkout"
    echo "  $0 --verbose          # Show detailed output"
    echo ""
    echo "SERVICES AVAILABLE AT:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🚪 Gateway:  http://localhost:8080"
    echo "  📦 Orders:   http://localhost:8081"
    echo "  💳 Payments: http://localhost:8082"
    echo ""
    echo "TROUBLESHOOTING:"
    echo "  - Ensure all services are running before testing"
    echo "  - Check service logs if tests fail"
    echo "  - Verify ports are not blocked by firewall"
    echo "  - Use '--verbose' for detailed error information"
}

# Parse command line arguments
VERBOSE=false
HEALTH_ONLY=false
CHECKOUT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --health)
            HEALTH_ONLY=true
            shift
            ;;
        --checkout)
            CHECKOUT_ONLY=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to test service health
test_service_health() {
    local service_name=$1
    local port=$2
    local endpoint=$3
    
    echo -n "$service_name ($port): "
    if curl -s $endpoint > /dev/null 2>&1; then
        print_success "Ready"
        return 0
    else
        print_error "Not ready"
        if [ "$VERBOSE" = true ]; then
            echo "  Trying: curl -s $endpoint"
            curl -s $endpoint 2>&1 | head -3
        fi
        return 1
    fi
}

# Function to test checkout
test_checkout() {
    print_status "Testing checkout endpoint..."
    
    local checkout_data='{
        "items": [
            {
                "itemId": "1",
                "itemName": "Test Item",
                "quantity": 1,
                "price": 10.99
            }
        ],
        "totalAmount": 10.99,
        "paymentMethod": "CREDIT_CARD",
        "cardNumber": "1234567890123456",
        "cardHolderName": "Test User",
        "expiryDate": "12/25",
        "cvv": "123",
        "userId": "user-123"
    }'
    
    local response=$(curl -s -X POST http://localhost:8080/api/gateway/checkout \
        -H "Content-Type: application/json" \
        -d "$checkout_data" 2>/dev/null)
    
    if [ $? -eq 0 ] && echo "$response" | jq . > /dev/null 2>&1; then
        local success=$(echo "$response" | jq -r '.success // false')
        if [ "$success" = "true" ]; then
            print_success "Checkout test passed!"
            if [ "$VERBOSE" = true ]; then
                echo "Response:"
                echo "$response" | jq .
            fi
        else
            print_error "Checkout test failed!"
            if [ "$VERBOSE" = true ]; then
                echo "Response:"
                echo "$response" | jq .
            fi
        fi
    else
        print_error "Checkout test failed - service not responding"
        if [ "$VERBOSE" = true ]; then
            echo "Raw response: $response"
        fi
    fi
}

# Main test execution
if [ "$CHECKOUT_ONLY" = false ]; then
    print_status "Testing service availability..."
    echo ""
    
    # Test Orders Service
    test_service_health "Orders Service" "8081" "http://localhost:8081/actuator/health"
    
    # Test Payments Service
    test_service_health "Payments Service" "8082" "http://localhost:8082/actuator/health"
    
    # Test Gateway Service
    test_service_health "Gateway Service" "8080" "http://localhost:8080/actuator/health"
    
    # Test Web Frontend
    test_service_health "Web Frontend" "3000" "http://localhost:3000"
    
    echo ""
fi

if [ "$HEALTH_ONLY" = false ]; then
    test_checkout
fi

echo ""
print_status "Test completed!"
