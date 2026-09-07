# Vercel Deployment Guide for Vibe-Agents

This guide explains how to deploy the Vibe-Agents application to Vercel.

## Architecture Note

Vibe-Agents consists of two parts:
1. **Frontend** (Next.js) - Can be deployed directly to Vercel
2. **Backend** (FastAPI/Python) - Must be deployed separately (e.g., Railway, Render, AWS, or Vercel as Serverless Functions)

## Option 1: Frontend Only on Vercel (Recommended)

### Prerequisites
- Backend API deployed and accessible via URL
- Vercel account (free tier available)
- Vercel CLI installed (`npm i -g vercel`)

### Step 1: Deploy Backend First

Deploy the backend (`/server` directory) to a platform that supports Python/FastAPI:

**Recommended Platforms:**
- **Railway.app** (easiest)
- **Render.com** 
- **Fly.io**
- **AWS Lambda** with API Gateway
- **Google Cloud Run**

Example for Railway:
```bash
cd server
# Connect to Railway
railway login
railway init
railway up
```

Note your backend URL (e.g., `https://vibe-agents-api.railway.app`)

### Step 2: Configure Frontend for Vercel

1. Create `.env.local` in the client directory:
```bash
cd client
cp .env.example .env.local
```

2. Update `NEXT_PUBLIC_API_URL` in `.env.local`:
```
NEXT_PUBLIC_API_URL=https://your-backend-url.railway.app
```

### Step 3: Deploy to Vercel

**Via CLI:**
```bash
cd client
vercel login
vercel --prod
```

**Via Vercel Dashboard:**
1. Go to [vercel.com](https://vercel.com)
2. Click "Add New Project"
3. Import your GitHub repository
4. Set Framework Preset: **Next.js**
5. Configure Build Settings:
   - Root Directory: `client`
   - Build Command: `npm run build`
   - Output Directory: `.next`
6. Add Environment Variables:
   - `NEXT_PUBLIC_API_URL`: Your backend API URL
7. Click "Deploy"

### Step 4: Configure Environment Variables in Vercel

In Vercel Dashboard → Project Settings → Environment Variables:

| Variable | Value | Environment |
|----------|-------|-------------|
| `NEXT_PUBLIC_API_URL` | `https://your-backend-url.com` | Production |
| `NEXT_PUBLIC_ENABLE_ANALYTICS` | `true` | Production (optional) |

### Step 5: Update CORS on Backend

Ensure your backend allows the Vercel domain:

In your backend `.env`:
```
ALLOWED_ORIGINS=http://localhost:3000,https://your-app.vercel.app
```

Redeploy backend after updating CORS settings.

## Option 2: Full Stack on Vercel (Advanced)

Convert the FastAPI backend to Vercel Serverless Functions:

### Step 1: Restructure for Vercel Functions

```
vercel-functions/
  api/
    index.py          # Main entry point
    routers/
      agent_proxy.py
    utils/
      agent_helper.py
```

### Step 2: Create `api/index.py`

```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import os

app = FastAPI()

@app.get("/api/{path:path}")
async def handler(request: Request, path: str):
    # Import and delegate to routers
    from app.routers.agent_proxy import router as proxy_router
    # Implementation needed
    pass

@app.get("/")
async def root():
    return {"message": "Vibe-Agents API on Vercel"}
```

### Step 3: Update `vercel.json`

```json
{
  "version": 2,
  "functions": {
    "vercel-functions/api/*.py": {
      "runtime": "@vercel/python@3"
    }
  },
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/vercel-functions/api/index.py"
    }
  ]
}
```

⚠️ **Note**: This approach requires significant refactoring and may have limitations with async operations and external dependencies.

## Recommended Deployment Strategy

**Best Practice**: Deploy frontend to Vercel and backend to a dedicated platform:

```
┌─────────────────┐         ┌──────────────────┐
│   Vercel        │         │   Railway/Render │
│   (Frontend)    │ ──────▶ │   (Backend API)  │
│   Next.js       │  HTTPS  │   FastAPI        │
│   Port 443      │         │   Port 443       │
└─────────────────┘         └──────────────────┘
                                    │
                                    ▼
                            ┌──────────────────┐
                            │   MuAPI          │
                            │   (External)     │
                            └──────────────────┘
```

## Environment Variables Checklist

### Frontend (Vercel)
- [ ] `NEXT_PUBLIC_API_URL` - Backend API URL
- [ ] `NEXT_PUBLIC_ENABLE_ANALYTICS` - Optional
- [ ] `NEXT_PUBLIC_ENABLE_ERROR_REPORTING` - Optional

### Backend (Railway/Render/etc.)
- [ ] `MU_API_KEY` - Your MuAPI authentication key
- [ ] `ALLOWED_ORIGINS` - Comma-separated list including Vercel domain
- [ ] `LOG_LEVEL` - INFO/WARNING/ERROR
- [ ] `REQUEST_TIMEOUT` - Timeout in seconds

## Testing Deployment

1. **Local Testing**:
   ```bash
   cd client
   npm run dev
   # Test with NEXT_PUBLIC_API_URL pointing to production backend
   ```

2. **Preview Deployment**:
   ```bash
   vercel
   # Opens preview URL for testing
   ```

3. **Production Deployment**:
   ```bash
   vercel --prod
   ```

4. **Verify**:
   - Visit your Vercel URL
   - Test agent functionality
   - Check browser console for errors
   - Verify API calls succeed (check Network tab)

## Troubleshooting

### CORS Errors
- Ensure backend `ALLOWED_ORIGINS` includes your Vercel domain
- Check that requests include proper headers

### API Connection Failed
- Verify `NEXT_PUBLIC_API_URL` is correct and accessible
- Ensure backend is running and healthy
- Check backend logs for errors

### Build Failures
- Ensure all dependencies are in `package.json`
- Check Node.js version compatibility
- Review build logs in Vercel dashboard

### Runtime Errors
- Enable error reporting
- Check Vercel Function logs
- Verify environment variables are set correctly

## Monitoring

- **Vercel Analytics**: Enable in dashboard
- **Vercel Logs**: View in dashboard → Deployments → Logs
- **Backend Logs**: Check your hosting platform's logging
- **Error Tracking**: Consider Sentry or similar

## Cost Optimization

- Vercel Free Tier: 100GB bandwidth/month
- Use ISR (Incremental Static Regeneration) where possible
- Optimize images with Next.js Image component
- Monitor function execution time

## Security Best Practices

- Never commit `.env` files
- Use Vercel's encrypted environment variables
- Enable Vercel's security headers (configured in `vercel.json`)
- Implement rate limiting on backend
- Validate all API inputs

## Support

- Vercel Documentation: https://vercel.com/docs
- Next.js Documentation: https://nextjs.org/docs
- Community: Vercel Discord, GitHub Discussions
