# 🚀 Vibe-Agents Deployment Setup Guide

Complete guide for deploying Vibe-Agents frontend and backend to production environments.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Development Setup](#development-setup)
- [Frontend Deployment (Vercel)](#frontend-deployment-vercel)
- [Backend Deployment](#backend-deployment)
- [Environment Configuration](#environment-configuration)
- [Post-Deployment](#post-deployment)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Option 1: Local Development (Docker Compose)
```bash
# Clone and setup
git clone https://github.com/Anubis-studios/open-ai-agents-hub.git
cd open-ai-agents-hub

# Configure environment
cp .env.example .env
# Edit .env with your API keys

# Deploy everything with one command
./deploy.sh

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

### Option 2: Production (Vercel + Railway)
```bash
# Deploy frontend to Vercel
./deploy-vercel.sh

# Deploy backend to Railway
cd server
railway login
railway init
railway up
```

---

## Development Setup

### Prerequisites
- **Node.js 18+** and **npm 9+**
- **Python 3.9+** and **pip**
- **Docker 20.10+** and **Docker Compose 2.0+** (for local Docker deployment)

### Setup Without Docker

#### Backend
```bash
cd server
pip install -r requirements.txt
export MUAPI_BASE_URL=https://api.muapi.ai
export MU_API_KEY=your_api_key_here
export ALLOWED_ORIGINS=http://localhost:3000
export LOG_LEVEL=INFO
uvicorn app.main:app --reload
# Backend runs on http://localhost:8000
```

#### Frontend
```bash
cd client
npm install
export NEXT_PUBLIC_API_URL=http://localhost:8000
npm run dev
# Frontend runs on http://localhost:3000
```

#### Shared Library (Optional)
```bash
cd packages/agents
npm run build
# Output: dist/ directory with compiled components
```

---

## Frontend Deployment (Vercel)

### Automated Deployment
```bash
./deploy-vercel.sh
```

Follow the prompts to:
1. Connect your GitHub repository
2. Set environment variables
3. Configure build settings

### Manual Deployment Steps

#### 1. Push Code to GitHub
```bash
git add -A
git commit -m "Prepare for Vercel deployment"
git push origin main
```

#### 2. Create Project on Vercel
1. Go to [vercel.com](https://vercel.com)
2. Click **Add New** → **Project**
3. Import your GitHub repository
4. Click **Import**

#### 3. Configure Project Settings

| Setting | Value |
|---------|-------|
| **Framework Preset** | Next.js |
| **Root Directory** | `client` |
| **Node Version** | 18.x or higher |
| **Build Command** | `npm run build` (auto-detected) |
| **Output Directory** | `.next` (auto-detected) |

#### 4. Add Environment Variables

Click **Environment Variables** and add:

```
NEXT_PUBLIC_API_URL=http://localhost:8000     # Update after backend deployment
NODE_ENV=production
```

#### 5. Deploy
Click **Deploy** — Vercel will build and deploy automatically.

#### 6. Get Your Frontend URL
```
https://your-project-name.vercel.app
```

---

## Backend Deployment

Choose one platform:

### Option A: Railway (Recommended - Easiest)

#### Prerequisites
- Railway account at [railway.app](https://railway.app)
- Railway CLI: `npm install -g @railway/cli`

#### Steps

##### 1. Login to Railway
```bash
railway login
```

##### 2. Initialize Project
```bash
cd server
railway init
```

##### 3. Create Service
When prompted, select **Python** and create a new project.

##### 4. Deploy
```bash
railway up
```

Railway will:
- Detect Python environment
- Install dependencies
- Build and deploy automatically
- Assign a public URL

##### 5. Configure Environment Variables
```bash
# Set variables one by one
railway variables set MUAPI_BASE_URL=https://api.muapi.ai
railway variables set MU_API_KEY=your_mu_api_key_here
railway variables set ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
railway variables set LOG_LEVEL=INFO

# Or use Railway dashboard:
# 1. Go to project → Variables
# 2. Add each environment variable
# 3. Deploy runs automatically
```

##### 6. Get Your Backend URL
```
https://your-project-name.railway.app
```

---

### Option B: Render.com

#### Prerequisites
- Render account at [render.com](https://render.com)

#### Steps

##### 1. Create Web Service
1. Go to [dashboard.render.com](https://dashboard.render.com)
2. Click **New +** → **Web Service**
3. Connect your GitHub repository

##### 2. Configure Service

| Setting | Value |
|---------|-------|
| **Name** | `vibe-agents-api` |
| **Environment** | `Python 3` |
| **Build Command** | `pip install -r requirements.txt` |
| **Start Command** | `gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT` |
| **Root Directory** | `server` |

##### 3. Add Environment Variables
Click **Advanced** → **Add Environment Variable**:

```
MUAPI_BASE_URL=https://api.muapi.ai
MU_API_KEY=your_mu_api_key_here
ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
LOG_LEVEL=INFO
```

##### 4. Choose Instance Type
- **Free**: Limited with spin-down after 15 min inactivity
- **Standard**: $7/month (recommended for production)

##### 5. Deploy
Click **Create Web Service** — Render will build and deploy.

##### 6. Get Your Backend URL
```
https://vibe-agents-api.onrender.com
```

---

### Option C: Fly.io (Global Distribution)

#### Prerequisites
- Fly.io account at [fly.io](https://fly.io)
- Fly CLI: `curl -L https://fly.io/install.sh | sh`

#### Steps

##### 1. Install CLI
```bash
curl -L https://fly.io/install.sh | sh
export PATH="$HOME/.fly/bin:$PATH"
```

##### 2. Login
```bash
fly auth login
```

##### 3. Launch App
```bash
cd server
fly launch --name vibe-agents-api
# Choose region closest to your users
```

##### 4. Configure Environment Variables
```bash
fly secrets set MUAPI_BASE_URL=https://api.muapi.ai
fly secrets set MU_API_KEY=your_mu_api_key_here
fly secrets set ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
fly secrets set LOG_LEVEL=INFO
```

##### 5. Deploy
```bash
fly deploy
```

##### 6. Get Your Backend URL
```
https://vibe-agents-api.fly.dev
```

---

## Environment Configuration

### Backend Environment Variables

Create `server/.env` with:

```bash
# API Configuration
MUAPI_BASE_URL=https://api.muapi.ai
MU_API_KEY=your_mu_api_key_here

# Server Configuration
HOST=0.0.0.0
PORT=8000

# CORS (production: add your Vercel domain)
ALLOWED_ORIGINS=http://localhost:3000,https://your-app.vercel.app

# Request Timeouts (seconds)
DEFAULT_TIMEOUT=30
CHAT_TIMEOUT=60
IMAGE_GEN_TIMEOUT=120

# Logging
LOG_LEVEL=INFO
```

### Frontend Environment Variables

Create `.env.local` in the `client` directory (or set in Vercel dashboard):

```bash
NEXT_PUBLIC_API_URL=http://localhost:8000
NODE_ENV=production
```

### Root Environment Variables

Create `.env` in project root for Docker Compose:

```bash
# Backend Configuration
ENVIRONMENT=production
API_URL=http://localhost:8000
ALLOWED_ORIGINS=http://localhost:3000
REQUEST_TIMEOUT=30
LOG_LEVEL=info

# Frontend Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000
NODE_ENV=production
```

---

## Post-Deployment

### 1. Test Backend Health
```bash
# Test root endpoint
curl https://your-backend-url/

# Expected response:
# {
#   "message": "Welcome to Vibe-Agents API",
#   "version": "1.0.0",
#   "status": "running"
# }

# Test health check
curl https://your-backend-url/api/health

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "2024-01-01T00:00:00Z",
#   "checks": {
#     "server": "ok",
#     "muapi_connection": "ok",
#     "environment": "ok"
#   }
# }
```

### 2. Test Frontend
1. Visit your Vercel URL: `https://your-app.vercel.app`
2. Click "Browse Agent Library"
3. Verify data loads from backend

### 3. Update CORS on Backend

After frontend is deployed, update backend CORS:

**Railway:**
```bash
railway variables set ALLOWED_ORIGINS=https://your-app.vercel.app,http://localhost:3000
# Redeploys automatically
```

**Render:**
1. Dashboard → Service → Environment
2. Update `ALLOWED_ORIGINS`
3. Click "Save Changes" (triggers redeploy)

**Fly.io:**
```bash
fly secrets set ALLOWED_ORIGINS=https://your-app.vercel.app,http://localhost:3000
fly deploy
```

### 4. Verify Full Stack

1. Go to frontend URL
2. Open browser DevTools → Network tab
3. Click "Browse Agent Library"
4. Verify API requests succeed (200 status)

---

## Troubleshooting

### Frontend Issues

#### Build Fails on Vercel
**Problem:** Build error during Vercel deployment

**Solutions:**
1. Check `client/package.json` for syntax errors
2. Verify `NEXT_PUBLIC_API_URL` is set in Vercel dashboard
3. Ensure `client` directory exists
4. Check build logs in Vercel dashboard

#### Cannot Connect to Backend
**Problem:** Frontend shows "Failed to fetch agent data"

**Solutions:**
1. Check browser console for CORS errors
2. Verify `NEXT_PUBLIC_API_URL` points to correct backend
3. Check backend is running: `curl https://backend-url/api/health`
4. Add frontend URL to backend `ALLOWED_ORIGINS`
5. Wait 1-2 minutes if you just updated CORS (deployment delay)

### Backend Issues

#### Build Fails on Deployment Platform

**Railway/Render:**
```bash
# Check locally first
cd server
pip install -r requirements.txt
python -m pytest  # if tests exist
```

**Render specific:**
- Ensure `Dockerfile.server` is present
- Check Python version compatibility (3.9+)

**Fly.io:**
```bash
# Check fly.toml configuration
fly status
fly logs  # View deployment logs
```

#### Service Won't Start

**Solutions:**
1. Verify `MU_API_KEY` is set
2. Check logs for startup errors
3. Ensure `ALLOWED_ORIGINS` doesn't have trailing slashes
4. Test locally with same environment variables:
   ```bash
   cd server
   export MU_API_KEY=your_key
   uvicorn app.main:app --reload
   ```

#### Health Check Fails
**Problem:** `/api/health` returns error

**Solutions:**
1. Verify `MU_API_KEY` is correct and active
2. Check `MUAPI_BASE_URL` is accessible
3. Review backend logs for connection errors
4. Test MuAPI connectivity:
   ```bash
   curl -H "Authorization: Bearer $MU_API_KEY" \
     https://api.muapi.ai/agents/skills
   ```

#### CORS Errors

**Problem:** Browser blocks requests with CORS error

**Solutions:**
1. Add frontend URL to `ALLOWED_ORIGINS` (no trailing slash):
   ```
   https://your-app.vercel.app,http://localhost:3000
   ```
2. Include both `http://` and `https://` variants if needed
3. Redeploy backend after updating environment variables
4. Check backend logs for CORS violations

### Common Errors

#### 504 Gateway Timeout
- Check `DEFAULT_TIMEOUT`, `CHAT_TIMEOUT`, or `IMAGE_GEN_TIMEOUT` values
- Increase timeout in environment variables if operations are legitimately slow

#### 503 Service Unavailable
- Backend can't connect to MuAPI
- Verify `MUAPI_BASE_URL` and `MU_API_KEY`
- Check MuAPI service status

#### 502 Bad Gateway
- Upstream MuAPI service error
- Check MuAPI service health
- Review backend logs for proxy errors

### Monitoring

#### View Logs

**Railway:**
```bash
railway logs
```

**Render:**
- Dashboard → Service → Logs tab (real-time)

**Fly.io:**
```bash
fly logs
fly logs -n 100  # Last 100 lines
```

#### CPU/Memory Usage

**Railway:**
- Dashboard → Metrics tab

**Render:**
- Dashboard → Metrics tab

**Fly.io:**
```bash
fly status
fly apps open  # Opens dashboard
```

---

## Security Checklist

- [ ] `MU_API_KEY` is kept secret (never committed to Git)
- [ ] `ALLOWED_ORIGINS` is restricted to your domain
- [ ] Backend uses HTTPS (automatic on all platforms)
- [ ] Environment variables are configured in platform dashboard (not .env files)
- [ ] `.env` files are in `.gitignore`
- [ ] No hardcoded API keys in code or configuration files

---

## Next Steps

1. **Monitor**: Set up alerts for 5xx errors or downtime
2. **Scale**: If traffic increases, upgrade instance type on your platform
3. **Backup**: Configure database backups if adding persistence
4. **Updates**: Plan for regular dependency updates and security patches

---

## Support

- **Vercel Docs**: [vercel.com/docs](https://vercel.com/docs)
- **Railway Docs**: [railway.app/docs](https://railway.app/docs)
- **Render Docs**: [render.com/docs](https://render.com/docs)
- **Fly.io Docs**: [fly.io/docs](https://fly.io/docs)

---

**Ready to deploy?** Follow the Quick Start section above! 🎉
