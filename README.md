# Vibe-Agents

A modern, production-ready full-stack application for AI agent management and visualization.

## 🚀 Quick Start

### Prerequisites
- Docker (20.10+)
- Docker Compose (2.0+)
- OR Node.js 18+ and Python 3.9+ for manual deployment

### Option 1: Docker Deployment (Recommended for Local Development)
```bash
./deploy.sh
```

That's it! Your application will be running at:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

### Option 2: Vercel Deployment (Recommended for Production)
```bash
# Deploy frontend to Vercel
./deploy-vercel.sh

# Deploy backend to Railway/Render (see VERCEL_DEPLOYMENT.md)
```

Your application will be running at:
- **Frontend**: https://your-app.vercel.app
- **Backend API**: https://your-api.railway.app

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [Development](#development)
- [Configuration](#configuration)
- [Documentation](#documentation)

## ✨ Features

### Backend (FastAPI)
- 🔒 Environment-based configuration with Pydantic validation
- 🛡️ CORS protection with configurable origins
- ⏱️ Configurable request timeouts
- 📊 Structured JSON logging
- 🏥 Health check endpoints
- 📚 Auto-generated API documentation (Swagger/OpenAPI)

### Frontend (Next.js 16 + React 19)
- ⚡ Server-side rendering for optimal performance
- 🎨 Modern UI with Tailwind CSS v4
- 🔄 Real-time data fetching with loading states
- 📱 Responsive design
- 🎯 Error handling and user feedback

### DevOps
- 🐳 Docker containerization for both services
- 🔄 Docker Compose orchestration
- 🏥 Built-in health checks
- 📝 Comprehensive deployment scripts
- ☁️ Cloud-ready (AWS, GCP, Heroku)

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐
│   Next.js 16    │────▶│   FastAPI 0.109  │
│   Frontend      │     │   Backend        │
│   Port: 3000    │     │   Port: 8000     │
└─────────────────┘     └──────────────────┘
```

## 🛠️ Development

See [DEVELOPMENT.md](./DEVELOPMENT.md) for detailed setup instructions.

### Quick Development Setup

```bash
# Backend
cd server
pip install -r requirements.txt
uvicorn app.main:app --reload

# Frontend (in another terminal)
cd client
npm install
npm run dev
```

## 🚢 Deployment Options

### Option 1: Docker Compose (Local Development)

```bash
# Configure environment
cp .env.example .env
nano .env  # Edit with your values

# Deploy
./deploy.sh

# View status
./deploy.sh status

# View logs
./deploy.sh logs

# Stop
./deploy.sh stop
```

### Option 2: Vercel + Railway/Render (Production)

**Frontend on Vercel:**
```bash
./deploy-vercel.sh
```

**Backend on Railway (recommended):**
```bash
cd server
railway login
railway init
railway up
```

See [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md) for:
- Complete Vercel deployment guide
- Backend deployment options
- Environment configuration
- CORS setup
- Troubleshooting

### Option 3: Manual Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for:
- Manual deployment steps
- Cloud platform guides (AWS, GCP, Heroku)
- Production checklist
- Monitoring & maintenance

## ⚙️ Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Backend
ENVIRONMENT=production
API_URL=http://localhost:8000
ALLOWED_ORIGINS=http://localhost:3000
REQUEST_TIMEOUT=30
LOG_LEVEL=info

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8000
```

See `.env.example` for all available options.

## 📚 Documentation

- **[VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md)** - Vercel deployment guide (NEW!)
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Complete deployment guide
- **[DEVELOPMENT.md](./DEVELOPMENT.md)** - Development setup and workflows
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history and changes
- **[IMPROVEMENTS_SUMMARY.md](./IMPROVEMENTS_SUMMARY.md)** - Recent improvements

## 🧪 Testing

```bash
# Backend tests
cd server
pytest

# Frontend tests
cd client
npm test
```

## 📊 Monitoring

### Health Checks
- Backend: `GET http://localhost:8000/health`
- Frontend: `GET http://localhost:3000/`

### Logs
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
```

## 🔒 Security

- ✅ Environment variables for sensitive configuration
- ✅ CORS protection
- ✅ Input validation with Pydantic
- ✅ Non-root Docker containers
- ✅ Health checks for service monitoring

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

- Check [DEPLOYMENT.md](./DEPLOYMENT.md) for troubleshooting
- Review logs: `./deploy.sh logs`
- Open an issue on GitHub

---

**Ready to deploy?** 
- For local development: Run `./deploy.sh` 🐳
- For production: Run `./deploy-vercel.sh` and deploy backend to Railway ☁️
