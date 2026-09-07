# 🚀 Vibe-Agents Deployment Guide

## Backend Deployment (Railway)

Since the Railway CLI requires interactive browser authentication, follow these manual steps:

### Option 1: Railway Web Dashboard (Easiest)

1. **Go to [Railway](https://railway.com)** and sign up/login
2. **Create New Project** → "New Project" → "Deploy from GitHub repo"
3. **Connect your repository** containing the `/server` folder
4. **Add Environment Variables**:
   - `ANTHROPIC_API_KEY`: Your Anthropic API key
   - `ALLOWED_ORIGINS`: Your Vercel frontend URL (after frontend deployment)
   - `PORT`: 8000 (auto-detected)
5. **Deploy**: Railway will automatically detect `requirements.txt` and deploy

### Option 2: Railway CLI (Advanced)

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login (opens browser)
railway login

# Navigate to server directory
cd server

# Initialize project (select or create)
railway init

# Set environment variables
railway variables set ANTHROPIC_API_KEY=your_actual_key_here
railway variables set ALLOWED_ORIGINS="http://localhost:3000,https://your-vercel-url.vercel.app"

# Deploy
railway up
```

### Option 3: Render (Alternative)

1. Go to [Render](https://render.com)
2. Create "Web Service"
3. Connect your GitHub repo
4. Set build command: `pip install -r requirements.txt`
5. Set start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. Add environment variables in Render dashboard

### Option 4: Fly.io (Alternative)

```bash
flyctl launch --region iad
flyctl secrets set ANTHROPIC_API_KEY=your_key
flyctl deploy
```

---

## Frontend Deployment (Vercel)

After backend is deployed:

### Option 1: Vercel Web Dashboard

1. Go to [Vercel](https://vercel.com)
2. "Add New" → "Project"
3. Import your GitHub repository
4. Set **Root Directory** to `client`
5. Add Environment Variable:
   - `NEXT_PUBLIC_API_URL`: Your Railway backend URL (e.g., `https://your-app.railway.app`)
6. Click "Deploy"

### Option 2: Vercel CLI

```bash
cd client
npx vercel login
npx vercel --prod
```

---

## Post-Deployment Configuration

### Update Backend CORS

After deploying frontend to Vercel, update your backend's `ALLOWED_ORIGINS`:

```bash
railway variables set ALLOWED_ORIGINS="https://your-app.vercel.app"
```

Or via Railway dashboard: Settings → Variables → Edit `ALLOWED_ORIGINS`

### Test Your Deployment

1. Visit your Vercel URL
2. Try creating an agent
3. Check browser console for any CORS errors
4. Verify API calls are reaching your backend

---

## Troubleshooting

### CORS Errors
- Ensure backend `ALLOWED_ORIGINS` includes your Vercel domain
- Check for trailing slashes in URLs

### API Connection Issues
- Verify `NEXT_PUBLIC_API_URL` is set correctly in Vercel
- Check backend logs on Railway for errors

### Build Failures
- Review build logs in Vercel/Railway dashboard
- Ensure all dependencies are in `requirements.txt` or `package.json`

---

## Quick Reference

| Component | Platform | URL Pattern |
|-----------|----------|-------------|
| Backend | Railway | `https://*.railway.app` |
| Frontend | Vercel | `https://*.vercel.app` |

**Estimated Setup Time**: 10-15 minutes

**Cost**: 
- Railway: $5/month (includes $5 credit)
- Vercel: Free for hobby projects
