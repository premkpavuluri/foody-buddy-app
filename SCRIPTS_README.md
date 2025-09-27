# FoodyBuddy Service Runner Scripts

This directory contains scripts to run all FoodyBuddy microservices locally using Gradle (for Java services) and Yarn (for the web frontend).

> **📚 Main Documentation**: See [README.md](README.md) for complete project overview and quick start.

## Available Scripts

### 1. `run-services.sh`
**Main production script** - Runs all services in the background with proper logging and process management.

**Features:**
- ✅ Runs all services in background
- ✅ Automatic port cleanup
- ✅ Process management with PID tracking
- ✅ Comprehensive logging to `logs/` directory
- ✅ Graceful shutdown on Ctrl+C
- ✅ Prerequisites checking
- ✅ Colored output for better readability

**Usage:**
```bash
./scripts/run-services.sh
```

**Services started:**
- **Orders Service**: Port 8081 (Gradle)
- **Payments Service**: Port 8082 (Gradle)  
- **Gateway Service**: Port 8080 (Gradle)
- **Web Frontend**: Port 3000 (Yarn)

### 2. `dev-local.sh`
**Development script** - Opens each service in a separate terminal window for easy debugging.

**Features:**
- ✅ Each service runs in its own terminal
- ✅ Easy to see individual service logs
- ✅ Perfect for development and debugging
- ✅ Linux/macOS terminal support

**Usage:**
```bash
./scripts/dev-local.sh
```


## Prerequisites

Before running any script, ensure you have:

### Required Software
- **Java 17+** - For Spring Boot services
- **Gradle** - For building Java services
- **Node.js** - For the web frontend
- **Yarn** - For managing web dependencies

### Installation Commands

**macOS (using Homebrew):**
```bash
brew install openjdk@17 gradle node yarn
```

**Ubuntu/Debian:**
```bash
# Java
sudo apt update
sudo apt install openjdk-17-jdk

# Gradle
sudo apt install gradle

# Node.js and Yarn
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g yarn
```


## Service Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Web Frontend  │    │   API Gateway   │
│   (Port 3000)   │◄───┤   (Port 8080)   │
│   (Yarn/Next.js)│    │   (Gradle)      │
└─────────────────┘    └─────────────────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
            ┌───────▼───┐ ┌─────▼─────┐ ┌───▼──────┐
            │  Orders   │ │ Payments  │ │   ...    │
            │ (Port 8081)│ │(Port 8082)│ │          │
            │ (Gradle)  │ │ (Gradle)  │ │          │
            └───────────┘ └───────────┘ └──────────┘
```

## Logs and Debugging

### Log Files
When using `run-services.sh`, logs are saved to the `logs/` directory:
- `logs/gateway.log` - Gateway service logs
- `logs/orders.log` - Orders service logs  
- `logs/payments.log` - Payments service logs
- `logs/web.log` - Web frontend logs

### Process Management
- PID files are stored in `logs/` directory for process tracking
- Use `ps aux | grep java` to see running Java processes
- Use `lsof -i :PORT` to check if a port is in use

### Common Issues

**Port already in use:**
```bash
# Kill process on specific port
lsof -ti :8080 | xargs kill -9
```

**Service won't start:**
- Check logs in `logs/` directory
- Ensure all prerequisites are installed
- Verify no other services are using the ports

**Gradle build issues:**
```bash
# Clean and rebuild
cd foodybuddy-gateway
./gradlew clean build
```

**Yarn issues:**
```bash
# Clear cache and reinstall
cd foodybuddy-web
yarn cache clean
rm -rf node_modules
yarn install
```

## Stopping Services

### Using run-services.sh
- Press `Ctrl+C` to gracefully stop all services
- The script will automatically clean up processes and ports

### Using dev-local.sh
- Close individual terminal windows
- Or press `Ctrl+C` in each terminal

### Manual cleanup
```bash
# Kill all Java processes
pkill -f "gradle bootRun"

# Kill all Node processes
pkill -f "yarn dev"

# Kill processes on specific ports
lsof -ti :8080 :8081 :8082 :3000 | xargs kill -9
```

## Development Workflow

1. **Start all services:**
   ```bash
   ./scripts/run-services.sh
   ```

2. **Access the application:**
   - Frontend: http://localhost:3000
   - API Gateway: http://localhost:8080

3. **Make changes:**
   - Java services will auto-reload with Spring Boot DevTools
   - Web frontend will hot-reload with Next.js

4. **Stop services:**
   - Press `Ctrl+C` in the terminal running the script

## Troubleshooting

### Service Dependencies
Services start in this order to handle dependencies:
1. Orders Service (8081)
2. Payments Service (8082)  
3. Gateway Service (8080) - waits for backend services
4. Web Frontend (3000) - waits for gateway

### Memory Issues
If you encounter memory issues, you can adjust JVM settings in the Gradle build files:
```gradle
bootRun {
    jvmArgs = [
        '-Xmx512m',
        '-Xms256m',
        '-XX:+UseG1GC'
    ]
}
```

### Network Issues
- Ensure ports 3000, 8080, 8081, and 8082 are available
- Check firewall settings
- Verify no other applications are using these ports
