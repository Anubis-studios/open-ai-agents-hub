# Deployment Guide for Vibe-Agents

This guide covers multiple deployment options for production environments.

## Table of Contents
- [Quick Start with Docker Compose](#quick-start-with-docker-compose)
- [Manual Deployment](#manual-deployment)
- [Cloud Platform Deployments](#cloud-platform-deployments)
- [Environment Configuration](#environment-configuration)
- [Monitoring & Maintenance](#monitoring--maintenance)

---

## Quick Start with Docker Compose

### Prerequisites
- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- Git

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd vibe-agents
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your production values
   nano .env
   ```

3. **Build and start services**
   ```bash
   docker-compose up -d --build
   ```

4. **Verify deployment**
   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

6. **Stop services**
   ```bash
   docker-compose down
   ```

---

## Manual Deployment

### Backend Deployment

1. **Install dependencies**
   ```bash
   cd server
   pip install -r requirements.txt
   ```

2. **Set environment variables**
   ```bash
   export ENVIRONMENT=production
   export API_URL=https://your-domain.com/api
   export ALLOWED_ORIGINS=https://your-frontend.com
   export REQUEST_TIMEOUT=30
   export LOG_LEVEL=info
   ```

3. **Run with production settings**
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
   ```

4. **Optional: Use Gunicorn for production**
   ```bash
   pip install gunicorn
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
   ```

### Frontend Deployment

1. **Install dependencies**
   ```bash
   cd client
   npm ci
   ```

2. **Set environment variables**
   ```bash
   export NEXT_PUBLIC_API_URL=https://your-api-domain.com
   ```

3. **Build the application**
   ```bash
   npm run build
   ```

4. **Start production server**
   ```bash
   npm start
   ```

---

## Cloud Platform Deployments

### AWS Deployment

#### Using ECS/Fargate

1. **Create ECR repositories**
   ```bash
   aws ecr create-repository --repository-name vibe-agents-backend
   aws ecr create-repository --repository-name vibe-agents-frontend
   ```

2. **Build and push images**
   ```bash
   # Backend
   docker build -f Dockerfile.server -t <account-id>.dkr.ecr.<region>.amazonaws.com/vibe-agents-backend:latest .
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/vibe-agents-backend:latest

   # Frontend
   docker build -f Dockerfile.client -t <account-id>.dkr.ecr.<region>.amazonaws.com/vibe-agents-frontend:latest .
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/vibe-agents-frontend:latest
   ```

3. **Deploy to ECS** using the provided task definitions or Terraform scripts

### Google Cloud Platform

#### Using Cloud Run

1. **Enable required APIs**
   ```bash
   gcloud services enable run.googleapis.com containerregistry.googleapis.com
   ```

2. **Build and deploy backend**
   ```bash
   gcloud builds submit --tag gcr.io/<project-id>/vibe-agents-backend -f Dockerfile.server
   gcloud run deploy vibe-agents-backend \
     --image gcr.io/<project-id>/vibe-agents-backend \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

3. **Build and deploy frontend**
   ```bash
   gcloud builds submit --tag gcr.io/<project-id>/vibe-agents-frontend -f Dockerfile.client
   gcloud run deploy vibe-agents-frontend \
     --image gcr.io/<project-id>/vibe-agents-frontend \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

### Heroku Deployment

1. **Install Heroku CLI and login**
   ```bash
   heroku login
   ```

2. **Create apps**
   ```bash
   heroku create vibe-agents-backend
   heroku create vibe-agents-frontend
   ```

3. **Deploy backend**
   ```bash
   cd server
   heroku stack:set container -a vibe-agents-backend
   git subtree push --prefix server heroku main
   ```

4. **Deploy frontend**
   ```bash
   cd client
   heroku stack:set container -a vibe-agents-frontend
   git subtree push --prefix client heroku main
   ```

---

## Environment Configuration

### Required Environment Variables

#### Backend (.env)
```bash
# Application
ENVIRONMENT=production
LOG_LEVEL=info

# API Configuration
API_URL=https://your-api-domain.com
ALLOWED_ORIGINS=https://your-frontend.com,https://www.your-frontend.com

# Timeouts
REQUEST_TIMEOUT=30

# Optional: Database (if added later)
DATABASE_URL=postgresql://user:password@host:5432/dbname

# Optional: Redis (if added later)
REDIS_URL=redis://localhost:6379
```

#### Frontend (.env.local)
```bash
# API Configuration
NEXT_PUBLIC_API_URL=https://your-api-domain.com

# Application
NODE_ENV=production
```

### Security Best Practices

1. **Never commit `.env` files** - Already in `.gitignore`
2. **Use secrets management** in production (AWS Secrets Manager, GCP Secret Manager, etc.)
3. **Rotate API keys regularly**
4. **Enable HTTPS** in production
5. **Configure CORS properly** for your domains only

---

## Monitoring & Maintenance

### Health Checks

- Backend: `GET /health`
- Frontend: `GET /`

### Logging

Logs are configured with structured JSON format in production:

```bash
# View backend logs
docker-compose logs backend
kubectl logs -l app=vibe-agents-backend

# View frontend logs
docker-compose logs frontend
kubectl logs -l app=vibe-agents-frontend
```

### Scaling

#### Docker Compose
```bash
docker-compose up -d --scale backend=3
```

#### Kubernetes
```bash
kubectl scale deployment vibe-agents-backend --replicas=3
kubectl autoscale deployment vibe-agents-backend --min=2 --max=10 --cpu-percent=80
```

### Updates

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Rebuild and restart**
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

3. **Zero-downtime deployment** (Kubernetes)
   ```bash
   kubectl rollout restart deployment/vibe-agents-backend
   kubectl rollout restart deployment/vibe-agents-frontend
   ```

### Backup & Recovery

1. **Database backups** (if applicable)
2. **Configuration backups**
3. **Document rollback procedures**

---

## Troubleshooting

### Common Issues

**Backend won't start:**
- Check environment variables are set correctly
- Verify port 8000 is not in use
- Review logs: `docker-compose logs backend`

**Frontend can't connect to backend:**
- Verify `NEXT_PUBLIC_API_URL` is correct
- Check CORS settings in backend
- Ensure both services are on the same network

**Health checks failing:**
- Wait for application startup (check `start_period` in healthcheck)
- Verify the health endpoint is accessible
- Check resource limits (memory/CPU)

### Getting Help

- Check logs: `docker-compose logs -f`
- Review documentation in `/docs`
- Open an issue on GitHub

---

## Production Checklist

- [ ] Environment variables configured
- [ ] HTTPS enabled
- [ ] CORS restricted to production domains
- [ ] Database backups configured (if applicable)
- [ ] Monitoring and alerting set up
- [ ] Log aggregation configured
- [ ] Auto-scaling policies defined
- [ ] Disaster recovery plan documented
- [ ] Security scan completed
- [ ] Load testing performed
- [ ] Documentation updated

---

For additional support, refer to:
- [DEVELOPMENT.md](./DEVELOPMENT.md) - Development setup
- [CHANGELOG.md](./CHANGELOG.md) - Version history
- [IMPROVEMENTS_SUMMARY.md](./IMPROVEMENTS_SUMMARY.md) - Recent improvements
