# 🚀 Render Deployment Guide for Vibe-Agents Backend

This guide walks you through deploying your Vibe-Agents FastAPI backend to Render.com.

## ✅ Prerequisites

- Git repository with your code pushed to GitHub or GitLab
- Render.com account (free tier available)
- API keys ready:
  - Anthropic API Key
  - MuAPI Key (if using MuAPI features)

## 📋 Quick Start (5 Minutes)

### Option 1: Interactive Script (Recommended)

Run the deployment script from your project root:

```bash
./deploy-render.sh
```

The script will:
- Verify your configuration files
- Help you push code to Git if needed
- Guide you through the Render dashboard setup
- Open the Render dashboard automatically

### Option 2: Manual Deployment

Follow these steps:

#### Step 1: Push Code to Git

```bash
git add -A
git commit -m "Prepare for Render deployment"
git push origin main
```

#### Step 2: Create Web Service on Render

1. **Go to [Render Dashboard](https://dashboard.render.com)**
2. Click **"New +"** → **"Web Service"**
3. **Connect your repository:**
   - Choose your Git provider (GitHub/GitLab)
   - Select your repository
   - Click **"Connect"**

#### Step 3: Configure Service Settings

| Setting | Value |
|---------|-------|
| **Name** | `vibe-agents-api` (or your choice) |
| **Region** | Choose closest to your users |
| **Branch** | `main` (or your deployment branch) |
| **Root Directory** | `server` |
| **Runtime** | `Python 3` |
| **Build Command** | `pip install -r requirements.txt` |
| **Start Command** | `gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT` |

#### Step 4: Add Environment Variables

Click **"Advanced"** → **"Add Environment Variable"** for each:

| Key | Value | Notes |
|-----|-------|-------|
| `ANTHROPIC_API_KEY` | `your_anthropic_key` | Required |
| `MU_API_KEY` | `your_mu_api_key` | Required for MuAPI features |
| `ALLOWED_ORIGINS` | `https://your-vercel-app.vercel.app,http://localhost:3000` | Comma-separated URLs |
| `LOG_LEVEL` | `INFO` | Optional, default: INFO |

⚠️ **Important:** Add your Vercel frontend URL to `ALLOWED_ORIGINS` after deploying frontend!

#### Step 5: Choose Instance Type

- **Free Tier**: Available with limitations (spins down after 15 min inactivity)
- **Standard**: $7/month (recommended for production)
- **Pro**: Higher performance options available

#### Step 6: Deploy

Click **"Create Web Service"**

Render will automatically:
- Build your application
- Install dependencies
- Start the server
- Display deployment logs

## 🔍 Configuration Files

Your repository includes these Render-specific files:

### `server/render.yaml`

```yaml
{
  "services": [
    {
      "type": "web",
      "name": "vibe-agents-api",
      "env": "python",
      "buildCommand": "pip install -r requirements.txt",
      "startCommand": "gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT",
      "healthCheckPath": "/api/health",
      "envVars": [
        {
          "key": "ANTHROPIC_API_KEY",
          "sync": false
        },
        {
          "key": "MU_API_KEY",
          "sync": false
        },
        {
          "key": "ALLOWED_ORIGINS",
          "sync": false
        },
        {
          "key": "LOG_LEVEL",
          "value": "INFO"
        }
      ]
    }
  ]
}
```

### `server/requirements.txt`

Includes all necessary dependencies:
- fastapi==0.109.0
- uvicorn[standard]==0.27.0
- httpx==0.26.0
- python-dotenv==1.0.0
- pydantic==2.5.3
- gunicorn (for production)

## ✅ Verify Deployment

### 1. Check Service Status

In Render dashboard, verify:
- ✅ Build succeeded
- ✅ Health checks passing
- ✅ No errors in logs

### 2. Test Endpoints

Your backend URL will be: `https://vibe-agents-api.onrender.com`

**Test root endpoint:**
```bash
curl https://your-app.onrender.com/
```

Expected response:
```json
{
  "message": "Welcome to Vibe-Agents API",
  "version": "1.0.0",
  "status": "running"
}
```

**Test health check:**
```bash
curl https://your-app.onrender.com/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "checks": {
    "server": "ok",
    "muapi_connection": "ok",
    "environment": "ok"
  }
}
```

## 🔗 Connect Frontend (Next Steps)

After backend deployment:

### 1. Copy Backend URL

From Render dashboard, copy your service URL:
```
https://vibe-agents-api.onrender.com
```

### 2. Deploy Frontend to Vercel

```bash
./deploy-vercel.sh
```

When prompted, enter your Render backend URL.

### 3. Update CORS on Render

1. Go to Render dashboard
2. Navigate to your service
3. Click **"Environment"** tab
4. Update `ALLOWED_ORIGINS`:
   ```
   https://your-vercel-app.vercel.app,http://localhost:3000
   ```
5. Click **"Save Changes"**

Render will automatically redeploy with new CORS settings.

### 4. Test Full Application

Visit your Vercel frontend URL and test agent functionality.

## 💡 Tips & Best Practices

### Free Tier Considerations

- **Spin-down**: Free instances sleep after 15 minutes of inactivity
- **Wake-up time**: First request after spin-down takes ~30 seconds
- **Solution**: Upgrade to Standard ($7/mo) for production use

### Monitoring

- **Logs**: View real-time logs in Render dashboard
- **Metrics**: Monitor CPU, memory, and request counts
- **Alerts**: Set up email notifications for failures

### Security

- ✅ All traffic uses HTTPS automatically
- ✅ Environment variables encrypted at rest
- ✅ CORS properly configured
- ✅ API keys never exposed in frontend

### Performance

- Use appropriate instance type for your traffic
- Enable auto-scaling for variable loads
- Consider Render's PostgreSQL for database needs

## 🐛 Troubleshooting

### Build Fails

**Symptom**: Build error in Render logs

**Solutions**:
1. Check `requirements.txt` syntax
2. Verify Python version compatibility
3. Review build logs for specific errors
4. Ensure `server/` directory structure is correct

### Service Won't Start

**Symptom**: Service starts then immediately stops

**Solutions**:
1. Check start command syntax
2. Verify all environment variables are set
3. Review application logs for startup errors
4. Test locally with same environment variables

### CORS Errors

**Symptom**: Frontend can't connect to backend

**Solutions**:
1. Add frontend URL to `ALLOWED_ORIGINS`
2. Include both http and https variants if needed
3. Restart service after updating environment variables
4. Check browser console for specific CORS error messages

### Health Check Fails

**Symptom**: `/api/health` returns error

**Solutions**:
1. Verify `ANTHROPIC_API_KEY` is set correctly
2. Check MuAPI connectivity
3. Review application logs for details
4. Test health endpoint manually via curl

## 📞 Support

- **Render Docs**: https://render.com/docs
- **Community**: https://community.render.com
- **Status**: https://status.render.com

## 🎉 Success!

Once deployed, your Vibe-Agents backend will be:
- ✅ Accessible via HTTPS
- ✅ Auto-scaling based on demand
- ✅ Monitored with built-in logging
- ✅ Ready for production traffic

**Next**: Deploy your frontend to Vercel following `VERCEL_DEPLOYMENT.md`
