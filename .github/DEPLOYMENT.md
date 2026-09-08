# Internal Deployment Reference Guide

This guide is for Anubis Studios team members. It provides quick reference, best practices, and internal procedures for deploying Vibe-Agents.

**User-facing deployment docs:** See [DEPLOYMENT_SETUP.md](../DEPLOYMENT_SETUP.md)

## 🎯 Quick Reference

### Deploy Frontend to Vercel
```bash
./deploy-vercel.sh
# Follow prompts to connect GitHub and configure environment
```

### Deploy Backend to Railway
```bash
cd server
railway login
railway init
railway up
railway variables set MUAPI_BASE_URL=https://api.muapi.ai
railway variables set MU_API_KEY=$ACTUAL_KEY
railway variables set ALLOWED_ORIGINS=https://your-vercel-domain.vercel.app
```

### Deploy Backend to Render
```bash
# Use GitHub UI:
# 1. Go to https://dashboard.render.com
# 2. Connect repo → Select open-ai-agents-hub
# 3. Create Web Service in server/ directory
# 4. Add environment variables in dashboard
# 5. Deploy
```

---

## 🔐 Secrets Management

### Required API Keys

| Key | Source | Who Has | Rotation |
|-----|--------|---------|----------|
| `MU_API_KEY` | MuAPI Dashboard | DevOps Lead | Quarterly |
| `VERCEL_TOKEN` | Vercel Settings | DevOps Lead | Yearly |
| `RAILWAY_TOKEN` | Railway Settings | DevOps Lead | Yearly |

### Where to Store

- ❌ **Never** commit `.env` files
- ✅ Store in platform dashboards (Vercel, Railway, Render)
- ✅ Use `.env.example` for templates only
- ✅ Document access procedures in team wiki

---

## 📋 Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing locally: `npm run build:app && cd server && pytest`
- [ ] No console errors or warnings
- [ ] Recent git commits with clear messages
- [ ] All environment variables documented in `.env.example`

### Backend Preparation
```bash
cd server
pip install -r requirements.txt
python -m pytest
```

### Frontend Preparation
```bash
cd client
npm install
npm run build
# Check: .next/ directory exists
# Check: No build warnings
```

### Configuration Verification
- [ ] `MUAPI_BASE_URL` points to production endpoint
- [ ] `MU_API_KEY` is valid and active
- [ ] `ALLOWED_ORIGINS` includes all frontend domains
- [ ] `LOG_LEVEL` set to `INFO` (not DEBUG)
- [ ] `NEXT_PUBLIC_API_URL` points to backend URL

---

## 🚀 Deployment Procedures

### Standard Deployment Flow

```
1. Update CHANGELOG.md with changes
2. Tag commit: git tag v1.2.3
3. Push: git push origin main --tags
4. Deploy Frontend (Vercel) - automated via GitHub
5. Deploy Backend (Railway) - automated or manual
6. Verify health checks
7. Test full stack
8. Announce in team channel
```

### Automated Deployments (GitHub Actions)

**Frontend:** Automatic on push to `main` (via Vercel integration)
**Backend:** Manual trigger via Railway CLI or dashboard

### Manual Verification After Deploy

```bash
# Backend Health Check
curl -s https://your-backend-url/api/health | jq .

# Frontend Accessibility
curl -s https://your-frontend-url/ | grep -i "vibe-agents"

# Check logs
railway logs
# or
fly logs
```

---

## 🔗 Platform URLs

| Platform | Team Dashboard | Docs |
|----------|----------------|------|
| **Vercel** | https://vercel.com/anubis-studios | vercel.com/docs |
| **Railway** | https://railway.app | railway.app/docs |
| **Render** | https://dashboard.render.com | render.com/docs |
| **Fly.io** | https://fly.io/dashboard | fly.io/docs |

---

## 🐛 Common Issues & Solutions

### Frontend Won't Deploy

**Error:** "Build failed - missing dependencies"
```bash
cd client
npm install --legacy-peer-deps
npm run build
```

**Error:** "Environment variable not found"
- Check Vercel dashboard → Settings → Environment Variables
- Ensure `NEXT_PUBLIC_` prefix for public vars
- Redeploy after adding variables

### Backend Won't Start

**Railway/Render:**
```bash
# Check logs
railway logs
# Check environment variables are set
railway variables list
# Redeploy after changes
railway up
```

**Connection Error to MuAPI:**
```bash
# Test MuAPI connectivity
curl -H "Authorization: Bearer $MU_API_KEY" \
  https://api.muapi.ai/agents/skills
# If fails, check API key validity
```

### CORS Errors After Deploy

```bash
# Add both domains (with and without www)
ALLOWED_ORIGINS=https://app.example.com,https://www.example.com

# Redeploy backend
railway variables set ALLOWED_ORIGINS="..."
railway up
```

---

## 📊 Monitoring & Maintenance

### Weekly Checks
- [ ] Check uptime status on platform dashboards
- [ ] Review error logs for patterns
- [ ] Verify health checks passing

### Monthly Checks
- [ ] Review dependency updates
- [ ] Check for security vulnerabilities: `npm audit`, `pip audit`
- [ ] Update documentation if features changed
- [ ] Test disaster recovery procedures

### Quarterly Tasks
- [ ] Rotate API keys (MU_API_KEY)
- [ ] Update CHANGELOG with planned improvements
- [ ] Review and update deployment procedures
- [ ] Conduct security audit

---

## 🔄 Rollback Procedures

### If Deployment Breaks Production

#### Quick Rollback (Railway/Render)
1. Go to platform dashboard
2. Select service
3. Click "Deployments"
4. Click previous stable version → "Redeploy"

#### Git Rollback
```bash
# Identify last stable commit
git log --oneline | head -20

# Revert to stable version
git revert HEAD
git push origin main

# Re-deploy
./deploy-vercel.sh
railway up
```

#### Emergency Fallback
- Vercel preview deployments: `https://your-pr-preview.vercel.app`
- Railway environments: Create staging environment
- DNS failover: Point to previous stable server

---

## 📈 Performance Optimization

### Backend Optimization
```bash
# Check current timeouts in environment
# Adjust if needed:
DEFAULT_TIMEOUT=30      # Most operations
CHAT_TIMEOUT=60         # Chat completions
IMAGE_GEN_TIMEOUT=120   # Image generation
```

### Frontend Optimization
- Run: `npm run build` and check bundle size
- Use Vercel Analytics: https://vercel.com/dashboard
- Check Core Web Vitals in Lighthouse

### Database (if added)
- Monitor connection pool
- Check query performance
- Set up backups (Railway/Render native support)

---

## 🎓 Team Training

### New Developers Should:
1. Read [DEPLOYMENT_SETUP.md](../DEPLOYMENT_SETUP.md)
2. Successfully run `./deploy.sh` locally
3. Deploy to staging (Vercel preview)
4. Understand `.env` configuration
5. Know how to read logs on platforms

### Checklist Before Production Access:
- [ ] Completed local deployment training
- [ ] Signed security agreement
- [ ] Received API key access (read-only initially)
- [ ] Pair-programmed first deployment
- [ ] Can troubleshoot common issues

---

## 📞 Support & Escalation

| Issue | Owner | Response Time |
|-------|-------|----------------|
| Feature request | Tech Lead | 2-5 days |
| Deployment failure | DevOps Lead | Immediate |
| API key rotation | Security Lead | Within 24h |
| Emergency rollback | DevOps Lead | 5-15 min |

---

## 🔗 Related Resources

- **Deployment Guide (Public):** [DEPLOYMENT_SETUP.md](../DEPLOYMENT_SETUP.md)
- **Development Guide:** [DEVELOPMENT.md](../DEVELOPMENT.md)
- **Change Log:** [CHANGELOG.md](../CHANGELOG.md)
- **Improvements Summary:** [IMPROVEMENTS_SUMMARY.md](../IMPROVEMENTS_SUMMARY.md)

---

**Last Updated:** September 2026  
**Next Review:** December 2026
