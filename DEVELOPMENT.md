# Vibe-Agents Development Scripts

## Development Commands

### Client (Frontend)
```bash
cd client
npm run dev        # Start development server on port 3000
npm run build      # Build for production
npm run start      # Start production server
npm run lint       # Run ESLint
```

### Server (Backend)
```bash
cd server

# Install dependencies
pip install -r requirements.txt

# Start development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Start production server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Agent Library Package
```bash
cd packages/agents
npm run dev        # Start development mode
npm run build      # Build the library
```

## Full Stack Development

From root directory:
```bash
# Install all dependencies
npm run install:all

# Start client only
npm run dev:app

# Build client
npm run build:app

# Build agent library
npm run build:lib
```

## Environment Setup

### Server Environment
1. Copy `.env.example` to `.env` in the server directory
2. Configure required environment variables:
   - `MU_API_KEY`: Your MuAPI API key
   - `MUAPI_BASE_URL`: MuAPI base URL (default: https://api.muapi.ai)
   - `ALLOWED_ORIGINS`: Comma-separated list of allowed CORS origins
   - `LOG_LEVEL`: Logging level (DEBUG, INFO, WARNING, ERROR)

### Client Environment
Create `.env.local` in client directory:
```
NEXT_PUBLIC_API_URL=http://127.0.0.1:8000
```

## Testing

### Backend Tests (TODO)
```bash
cd server
pytest
```

### Frontend Tests (TODO)
```bash
cd client
npm test
```

### E2E Tests (TODO)
```bash
npx playwright test
```

## Code Quality

### Backend
```bash
cd server
# Format code
black app/

# Lint code
ruff check app/
```

### Frontend
```bash
cd client
npm run lint
```

## Production Deployment

### Backend
```bash
cd server
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Frontend
```bash
cd client
npm run build
npm run start
```

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure `ALLOWED_ORIGINS` in server `.env` includes your frontend URL
2. **API Connection Failed**: Check that server is running on port 8000
3. **Module Not Found**: Run `npm install` or `pip install -r requirements.txt`

### Logs Location
- Server logs: Console output from uvicorn
- Client logs: Browser console

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Next.js Documentation](https://nextjs.org/docs)
- [MuAPI Documentation](https://muapi.ai/docs)
