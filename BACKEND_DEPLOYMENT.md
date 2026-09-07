# 🚀 Backend Deployment Guide

This guide covers deploying the Vibe-Agents backend to various cloud platforms.

## 📋 Prerequisites

- Git repository pushed to GitHub/GitLab
- Docker installed (for local testing)
- Account on chosen deployment platform

## 🎯 Quick Deploy

Run the interactive deployment script:

```bash
./deploy-backend.sh
```

This script supports:
- **Railway** (Recommended - easiest setup)
- **Render** (Free tier available)
- **Fly.io** (Global distribution)

---

## 🛤️ Railway Deployment (Recommended)

### Why Railway?
- One-click deployments
- Automatic HTTPS
- Built-in database support
- Generous free tier
- Simple environment variable management

### Steps

#### 1. Install Railway CLI
```bash
npm install -g @railway/cli
```

#### 2. Login to Railway
```bash
railway login
```

#### 3. Initialize Project
```bash
cd server
railway init
```

#### 4. Deploy
```bash
railway up
```

#### 5. Set Environment Variables
```bash
railway variables set ANTHROPIC_API_KEY=your_key_here
railway variables set ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
```

#### 6. Add Custom Domain (Optional)
```bash
railway domain vibe-agents-api.railway.app
```

### Configuration Files

The `railway.json` file is already configured:

```json
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
```

---

## 🎨 Render Deployment

### Why Render?
- Free tier for hobby projects
- Automatic deployments from Git
- Managed PostgreSQL
- Simple UI

### Steps

#### 1. Create Web Service
1. Go to [render.com](https://render.com)
2. Click **New +** → **Web Service**
3. Connect your GitHub repository

#### 2. Configure Service
- **Name**: `vibe-agents-api`
- **Region**: Choose closest to users
- **Branch**: `main`
- **Root Directory**: `server`
- **Runtime**: `Docker`
- **Build Command**: (leave empty)
- **Start Command**: (handled by Dockerfile)

#### 3. Environment Variables
Add these in the Render dashboard:
```
ANTHROPIC_API_KEY=your_key_here
ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
LOG_LEVEL=info
```

#### 4. Deploy
Click **Create Web Service** - Render will build and deploy automatically.

---

## 🪂 Fly.io Deployment

### Why Fly.io?
- Global edge deployment
- Low latency
- Auto-scaling
- Free allowance included

### Steps

#### 1. Install Fly CLI
```bash
curl -L https://fly.io/install.sh | sh
export PATH="$HOME/.fly/bin:$PATH"
```

#### 2. Login
```bash
fly auth login
```

#### 3. Create App
```bash
cd server
fly launch --name vibe-agents-api
```

#### 4. Deploy
```bash
fly deploy
```

#### 5. Set Secrets
```bash
fly secrets set ANTHROPIC_API_KEY=your_key_here
fly secrets set ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
```

#### 6. Open App
```bash
fly open
```

### Configuration

The `fly.toml` file is pre-configured with:
- Health checks
- Auto-scaling
- HTTPS enforcement
- Graceful shutdowns

---

## 🔍 Testing Deployment

### Health Check
```bash
curl https://your-backend-url.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "version": "1.0.0"
}
```

### API Test
```bash
curl -X POST https://your-backend-url.com/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello"}'
```

---

## 🔐 Security Checklist

- [ ] All API keys stored as environment variables
- [ ] CORS configured with specific origins
- [ ] HTTPS enabled (automatic on all platforms)
- [ ] Rate limiting configured
- [ ] Health endpoints monitored
- [ ] Logs reviewed for sensitive data

---

## 📊 Monitoring

### Railway
- Dashboard shows real-time logs
- Metrics available in project view
- Alerts via email/webhook

### Render
- Logs in dashboard
- Metrics tab for CPU/memory
- Alerting via integrations

### Fly.io
```bash
fly logs --app vibe-agents-api
fly status --app vibe-agents-api
```

---

## 🔄 CI/CD Setup

All platforms support automatic deployments:

1. **Push to main branch** → Auto deploy
2. **Pull requests** → Preview deployments (Railway/Render)
3. **Rollback** → One-click in dashboard

---

## 💰 Cost Estimates

| Platform | Free Tier | Paid Starting | Notes |
|----------|-----------|---------------|-------|
| Railway  | $5/month  | $5/month      | Easy scaling |
| Render   | Free      | $7/month      | Hobby friendly |
| Fly.io   | Free allowance | ~$2/month | Pay per use |

---

## 🆘 Troubleshooting

### Build Fails
- Check Dockerfile syntax
- Verify requirements.txt is complete
- Review build logs in dashboard

### Runtime Errors
- Check environment variables are set
- Review application logs
- Test health endpoint

### CORS Errors
- Ensure `ALLOWED_ORIGINS` includes frontend URL
- Check for trailing slashes in URLs
- Verify protocol (http vs https)

### Database Connection Issues
- Verify connection string format
- Check network access rules
- Ensure SSL mode is configured

---

## 📞 Support

- **Railway**: [docs.railway.app](https://docs.railway.app)
- **Render**: [render.com/docs](https://render.com/docs)
- **Fly.io**: [fly.io/docs](https://fly.io/docs)

---

## ✅ Next Steps

After backend deployment:

1. ✅ Copy the backend URL
2. 🚀 Run `./deploy-vercel.sh` for frontend
3. 🔗 Update backend CORS with frontend URL
4. 🧪 Test end-to-end functionality

---

**Happy Deploying! 🎉**
