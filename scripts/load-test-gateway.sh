#!/bin/bash

# Load Testing Script for Gateway HPA
# This script generates load to trigger HPA scaling and monitors the results

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="foodybuddy"
GATEWAY_SERVICE="foodybuddy-gateway"
GATEWAY_PORT="8080"
TEST_DURATION=${1:-120}  # Default 120 seconds
CONCURRENT_USERS=${2:-20}  # Default 20 concurrent users

echo -e "${BLUE}🚀 Starting Gateway Load Test${NC}"
echo -e "${YELLOW}Duration: ${TEST_DURATION} seconds${NC}"
echo -e "${YELLOW}Concurrent Users: ${CONCURRENT_USERS}${NC}"
echo ""

# Function to get gateway service URL
get_gateway_url() {
    if kubectl get service $GATEWAY_SERVICE -n $NAMESPACE &>/dev/null; then
        SERVICE_IP=$(kubectl get service $GATEWAY_SERVICE -n $NAMESPACE -o jsonpath='{.spec.clusterIP}')
        echo "http://${SERVICE_IP}:${GATEWAY_PORT}"
    else
        echo -e "${RED}❌ Gateway service not found in namespace $NAMESPACE${NC}"
        exit 1
    fi
}

# Function to run intensive load test
run_intensive_test() {
    local gateway_url=$1
    local duration=$2
    local users=$3
    
    echo -e "${GREEN}📊 Starting load test against: ${gateway_url}${NC}"
    echo -e "${YELLOW}Testing endpoints with high frequency:${NC}"
    echo "  - GET /actuator/health (every 0.05s)"
    echo "  - GET /actuator/info (every 0.1s)"
    echo "  - GET /actuator/metrics (every 0.2s)"
    echo ""
    
    # Create a more intensive worker script
    cat > /tmp/intensive_worker.sh << EOF
#!/bin/bash
gateway_url=\$1
worker_id=\$2
end_time=\$((\$(date +%s) + ${duration}))

echo "Intensive Worker \${worker_id} starting..."

while [ \$(date +%s) -lt \$end_time ]; do
    # Very frequent health checks
    for i in {1..5}; do
        curl -s -o /dev/null -w "Worker \${worker_id} - Health \${i}: %{http_code} - %{time_total}s\n" "\${gateway_url}/actuator/health" &
    done
    
    # Frequent info requests
    for i in {1..3}; do
        curl -s -o /dev/null -w "Worker \${worker_id} - Info \${i}: %{http_code} - %{time_total}s\n" "\${gateway_url}/actuator/info" &
    done
    
    # CPU-intensive metrics requests
    curl -s -o /dev/null -w "Worker \${worker_id} - Metrics: %{http_code} - %{time_total}s\n" "\${gateway_url}/actuator/metrics" &
    
    # Very short delay for maximum load
    sleep 0.05
done

echo "Intensive Worker \${worker_id} finished"
EOF
    
    chmod +x /tmp/intensive_worker.sh
    
    # Start concurrent workers
    echo -e "${BLUE}🔥 Starting ${users} concurrent workers...${NC}"
    for i in $(seq 1 $users); do
        /tmp/intensive_worker.sh "$gateway_url" "$i" &
    done
    
    # Wait for all workers to complete
    wait
    
    # Cleanup
    rm -f /tmp/intensive_worker.sh
    
    echo -e "${GREEN}✅ Load test completed!${NC}"
}

# Function to monitor HPA during test
monitor_hpa() {
    echo -e "${BLUE}📈 Monitoring HPA status...${NC}"
    echo ""
    
    # Monitor for the duration of the test
    for i in $(seq 1 $TEST_DURATION); do
        echo -e "${YELLOW}--- Time: ${i}s ---${NC}"
        kubectl get hpa $GATEWAY_SERVICE-hpa -n $NAMESPACE --no-headers | while read line; do
            echo "HPA: $line"
        done
        
        pod_count=$(kubectl get pods -n $NAMESPACE -l app=$GATEWAY_SERVICE --no-headers | wc -l | tr -d ' ')
        echo "Pods: $pod_count"
        
        # Show resource usage
        kubectl top pods -n $NAMESPACE -l app=$GATEWAY_SERVICE --no-headers | head -3
        
        if [ $i -lt $TEST_DURATION ]; then
            sleep 1
        fi
    done
}

# Main execution
main() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Get gateway URL
    gateway_url=$(get_gateway_url)
    if [ -z "$gateway_url" ]; then
        exit 1
    fi
    
    echo -e "${GREEN}✅ Gateway URL: ${gateway_url}${NC}"
    echo ""
    
    # Show initial state
    echo -e "${BLUE}📊 Initial HPA Status:${NC}"
    kubectl get hpa $GATEWAY_SERVICE-hpa -n $NAMESPACE
    echo ""
    echo -e "${BLUE}📊 Initial Pod Status:${NC}"
    kubectl get pods -n $NAMESPACE -l app=$GATEWAY_SERVICE
    echo ""
    
    # Start monitoring in background
    monitor_hpa &
    monitor_pid=$!
    
    # Run the intensive load test
    run_intensive_test "$gateway_url" "$TEST_DURATION" "$CONCURRENT_USERS"
    
    # Wait a bit for metrics to stabilize
    echo -e "${YELLOW}⏳ Waiting for metrics to stabilize...${NC}"
    sleep 15
    
    # Kill monitoring
    kill $monitor_pid 2>/dev/null || true
    
    echo ""
    echo -e "${GREEN}📊 Final HPA Status:${NC}"
    kubectl get hpa $GATEWAY_SERVICE-hpa -n $NAMESPACE
    echo ""
    echo -e "${GREEN}📊 Final Pod Status:${NC}"
    kubectl get pods -n $NAMESPACE -l app=$GATEWAY_SERVICE
    echo ""
    echo -e "${GREEN}📊 Final Pod Resource Usage:${NC}"
    kubectl top pods -n $NAMESPACE -l app=$GATEWAY_SERVICE
    echo ""
    echo -e "${GREEN}📊 HPA Events:${NC}"
    kubectl describe hpa $GATEWAY_SERVICE-hpa -n $NAMESPACE | grep -A 10 "Events:"
}

# Run main function
main "$@"
