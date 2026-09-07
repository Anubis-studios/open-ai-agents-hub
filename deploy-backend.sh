#!/bin/bash

# Vibe-Agents Backend Deployment Script
# Supports: Railway, Render, Fly.io

set -e

echo "🚀 Vibe-Agents Backend Deployment"
echo "================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running in correct directory
if [ ! -f "server/requirements.txt" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Select deployment platform
echo "Select deployment platform:"
echo "1) Railway (Recommended - Easy setup)"
echo "2) Render (Free tier available)"
echo "3) Fly.io (Global distribution)"
echo ""
read -p "Choose option (1-3): " platform_choice

case $platform_choice in
    1)
        PLATFORM="railway"
        ;;
    2)
        PLATFORM="render"
        ;;
    3)
        PLATFORM="flyio"
        ;;
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac

echo ""
print_info "Deploying to $PLATFORM..."
echo ""

# Deploy to Railway
if [ "$PLATFORM" = "railway" ]; then
    print_info "Checking Railway CLI..."
    if ! command -v railway &> /dev/null; then
        print_warning "Railway CLI not found. Installing..."
        npm install -g @railway/cli
    fi
    
    print_info "Logging into Railway..."
    railway login
    
    print_info "Initializing Railway project..."
    cd server
    if [ ! -f "railway.json" ]; then
        print_info "Creating railway.json configuration..."
        cat > railway.json << 'EOF'
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "startCommand": "uvicorn main:app --host 0.0.0.0 --port $PORT",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 100,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF
    fi
    
    print_info "Deploying to Railway..."
    railway up
    
    print_info "Getting deployment URL..."
    DEPLOY_URL=$(railway domain | grep -o 'https://[^ ]*')
    
    cd ..
    
    print_success "Backend deployed successfully!"
    echo ""
    echo "📍 Deployment URL: $DEPLOY_URL"
    echo "🔗 Health check: $DEPLOY_URL/health"
    echo ""
    print_info "Save this URL for frontend deployment:"
    echo "   export BACKEND_URL=$DEPLOY_URL"
    echo ""
    
    # Update .env.example with the new URL
    if [ -f "server/.env.example" ]; then
        sed -i.bak "s|BACKEND_URL=.*|BACKEND_URL=$DEPLOY_URL|" server/.env.example
        rm server/.env.example.bak 2>/dev/null || true
    fi
fi

# Deploy to Render
if [ "$PLATFORM" = "render" ]; then
    print_info "Render deployment requires manual setup via dashboard"
    echo ""
    print_info "Steps to deploy on Render:"
    echo "1. Go to https://render.com and sign up/login"
    echo "2. Click 'New +' → 'Web Service'"
    echo "3. Connect your GitHub repository"
    echo "4. Configure:"
    echo "   - Name: vibe-agents-api"
    echo "   - Region: Choose closest to your users"
    echo "   - Branch: main"
    echo "   - Root Directory: server"
    echo "   - Runtime: Docker"
    echo "   - Build Command: (leave empty for Docker)"
    echo "   - Start Command: (handled by Dockerfile)"
    echo "5. Add environment variables from .env.example"
    echo "6. Click 'Create Web Service'"
    echo ""
    print_info "Once deployed, copy the URL and save it for frontend deployment"
fi

# Deploy to Fly.io
if [ "$PLATFORM" = "flyio" ]; then
    print_info "Checking Fly.io CLI..."
    if ! command -v fly &> /dev/null; then
        print_warning "Fly.io CLI not found. Installing..."
        curl -L https://fly.io/install.sh | sh
        export PATH="$HOME/.fly/bin:$PATH"
    fi
    
    print_info "Logging into Fly.io..."
    fly auth login
    
    print_info "Creating fly.toml configuration..."
    cd server
    if [ ! -f "fly.toml" ]; then
        cat > fly.toml << 'EOF'
app = "vibe-agents-api"
primary_region = "iad"

[build]
  dockerfile = "Dockerfile"

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
  
  [http_service.concurrency]
    type = "connections"
    hard_limit = 250
    soft_limit = 200

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 512

[checks]
  [checks.health]
    path = "/health"
    interval = "10s"
    timeout = "5s"
    grace_period = "30s"
EOF
    fi
    
    print_info "Deploying to Fly.io..."
    fly deploy --app vibe-agents-api
    
    print_info "Opening app in browser..."
    fly open --app vibe-agents-api
    
    cd ..
    
    DEPLOY_URL="https://vibe-agents-api.fly.dev"
    
    print_success "Backend deployed successfully!"
    echo ""
    echo "📍 Deployment URL: $DEPLOY_URL"
    echo "🔗 Health check: $DEPLOY_URL/health"
    echo ""
fi

echo ""
print_success "Backend deployment complete!"
echo ""
print_info "Next steps:"
echo "1. Test the health endpoint: curl $DEPLOY_URL/health"
echo "2. Save the backend URL for frontend deployment"
echo "3. Run ./deploy-vercel.sh to deploy the frontend"
echo ""
print_info "Documentation: See VERCEL_DEPLOYMENT.md for complete guide"
