#!/bin/bash

# Render Deployment Script for Vibe-Agents Backend
# This script helps you deploy your FastAPI backend to Render.com

set -e

echo "🚀 Vibe-Agents Backend - Render Deployment"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if render.yaml exists
if [ ! -f "server/render.yaml" ]; then
    echo -e "${RED}❌ Error: server/render.yaml not found${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Render Deployment Steps:${NC}"
echo ""
echo "Render.com doesn't have a CLI for direct deployment, but you can deploy easily via their web dashboard:"
echo ""
echo -e "${YELLOW}Step 1: Prepare Your Repository${NC}"
echo "   ✅ Your code is already configured with render.yaml"
echo "   ✅ requirements.txt includes all dependencies"
echo "   ✅ App structure is Render-compatible"
echo ""

echo -e "${YELLOW}Step 2: Push to GitHub/GitLab${NC}"
read -p "Is your code pushed to Git? (y/n): " pushed
if [ "$pushed" != "y" ] && [ "$pushed" != "Y" ]; then
    git add -A
    git commit -m "Prepare for Render deployment"
    git push
    echo -e "${GREEN}✅ Code pushed successfully${NC}"
fi
echo ""

echo -e "${YELLOW}Step 3: Deploy on Render Dashboard${NC}"
echo ""
echo "1. Go to https://render.com and sign up/login"
echo "2. Click 'New +' → 'Web Service'"
echo "3. Connect your Git repository"
echo "4. Configure the service:"
echo "   - Name: vibe-agents-api (or your choice)"
echo "   - Region: Choose closest to your users"
echo "   - Branch: main (or your deployment branch)"
echo "   - Root Directory: server"
echo "   - Runtime: Python 3"
echo "   - Build Command: pip install -r requirements.txt"
echo "   - Start Command: gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:\$PORT"
echo ""
echo "5. Add Environment Variables:"
echo "   - ANTHROPIC_API_KEY: your_anthropic_key"
echo "   - MU_API_KEY: your_mu_api_key"
echo "   - ALLOWED_ORIGINS: https://your-vercel-app.vercel.app,http://localhost:3000"
echo "   - LOG_LEVEL: INFO"
echo ""
echo "6. Choose Instance Type:"
echo "   - Free tier available (with limitations)"
echo "   - Standard: \$7/month (recommended for production)"
echo ""
echo "7. Click 'Create Web Service'"
echo ""

echo -e "${YELLOW}Step 4: Monitor Deployment${NC}"
echo "Render will automatically build and deploy your application."
echo "You'll see the deployment logs in the dashboard."
echo "Once deployed, you'll get a URL like: https://vibe-agents-api.onrender.com"
echo ""

echo -e "${BLUE}📝 Alternative: Using Render API${NC}"
echo "For automated deployments, you can use Render's API:"
echo "https://api.render.com/v1/services"
echo ""

echo -e "${GREEN}✅ Configuration Files Ready:${NC}"
echo "   - server/render.yaml ✅"
echo "   - server/requirements.txt ✅"
echo "   - server/app/main.py ✅"
echo ""

echo -e "${YELLOW}📖 Next Steps After Deployment:${NC}"
echo "1. Copy your Render backend URL"
echo "2. Update .env in client/ with NEXT_PUBLIC_API_URL"
echo "3. Deploy frontend to Vercel: ./deploy-vercel.sh"
echo "4. Update ALLOWED_ORIGINS in Render with your Vercel URL"
echo "5. Test your full application!"
echo ""

echo -e "${BLUE}💡 Tips:${NC}"
echo "- Free instances spin down after 15 minutes of inactivity"
echo "- First request after spin-down takes ~30 seconds to wake up"
echo "- Use health check endpoint: /api/health"
echo "- Check logs in Render dashboard for debugging"
echo ""

read -p "Open Render dashboard now? (y/n): " open_dashboard
if [ "$open_dashboard" == "y" ] || [ "$open_dashboard" == "Y" ]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open https://dashboard.render.com
    elif command -v open &> /dev/null; then
        open https://dashboard.render.com
    else
        echo "Please visit: https://dashboard.render.com"
    fi
fi

echo ""
echo -e "${GREEN}🎉 Ready to deploy on Render!${NC}"
