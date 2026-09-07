#!/bin/bash

# ===========================================
# Vibe-Agents Deployment Script
# ===========================================
# This script automates the deployment process
# ===========================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
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

check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "All dependencies are installed"
}

check_env_file() {
    print_info "Checking environment configuration..."
    
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        cp .env.example .env
        print_warning "Please edit .env file with your production values before continuing"
        print_warning "Press Enter after you've updated the .env file..."
        read -r
    fi
    
    print_success "Environment configuration ready"
}

build_images() {
    print_info "Building Docker images..."
    
    docker-compose build --no-cache
    
    print_success "Docker images built successfully"
}

start_services() {
    print_info "Starting services..."
    
    docker-compose up -d
    
    print_success "Services started"
}

wait_for_health() {
    print_info "Waiting for services to be healthy..."
    
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        backend_healthy=$(docker inspect --format='{{.State.Health.Status}}' vibe-agents-backend 2>/dev/null || echo "starting")
        frontend_healthy=$(docker inspect --format='{{.State.Health.Status}}' vibe-agents-frontend 2>/dev/null || echo "starting")
        
        if [[ "$backend_healthy" == "healthy" && "$frontend_healthy" == "healthy" ]]; then
            print_success "All services are healthy!"
            return 0
        fi
        
        echo -ne "\rAttempt $attempt/$max_attempts - Backend: $backend_healthy, Frontend: $frontend_healthy"
        sleep 5
        ((attempt++))
    done
    
    print_warning "Timeout waiting for services. Check logs with: docker-compose logs"
    return 1
}

show_status() {
    print_info "Service Status:"
    docker-compose ps
}

show_logs() {
    print_info "Showing recent logs (last 50 lines)..."
    docker-compose logs --tail=50
}

deploy() {
    local mode="${1:-full}"
    
    print_info "Starting deployment in '$mode' mode..."
    echo ""
    
    case $mode in
        "build")
            check_dependencies
            check_env_file
            build_images
            ;;
        "start")
            start_services
            wait_for_health
            show_status
            ;;
        "restart")
            print_info "Restarting services..."
            docker-compose restart
            wait_for_health
            show_status
            ;;
        "stop")
            print_info "Stopping all services..."
            docker-compose down
            print_success "Services stopped"
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "full"|*)
            check_dependencies
            check_env_file
            build_images
            start_services
            wait_for_health
            show_status
            print_success "Deployment completed successfully!"
            echo ""
            print_info "Access points:"
            echo "  Frontend: http://localhost:3000"
            echo "  Backend API: http://localhost:8000"
            echo "  API Docs: http://localhost:8000/docs"
            echo ""
            print_info "To view logs: ./deploy.sh logs"
            print_info "To stop services: ./deploy.sh stop"
            ;;
    esac
}

# Show help
show_help() {
    echo "Vibe-Agents Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  full     - Complete deployment (default)"
    echo "  build    - Build Docker images only"
    echo "  start    - Start services only"
    echo "  restart  - Restart running services"
    echo "  stop     - Stop all services"
    echo "  status   - Show service status"
    echo "  logs     - Show recent logs"
    echo "  help     - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh           # Full deployment"
    echo "  ./deploy.sh build     # Build only"
    echo "  ./deploy.sh logs      # View logs"
}

# Main script
case "${1:-full}" in
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        deploy "$1"
        ;;
esac
