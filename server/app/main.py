import os
import logging
from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from .routers import agent_proxy

# Load environment variables
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(env_path)

# Configure logging
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO").upper(),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Vibe-Agents API", version="1.0.0")

# Configure CORS with environment variables
allowed_origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization", "x-api-key"],
    max_age=600,
)

# Include routers
app.include_router(agent_proxy.router, prefix="/api", tags=["proxy"])

@app.get("/")
async def root():
    return {
        "message": "Welcome to Vibe-Agents API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/api/health")
async def health_check():
    """Enhanced health check with dependency verification"""
    health_status = {
        "status": "healthy",
        "timestamp": None,
        "checks": {
            "server": "ok",
            "muapi_connection": "unknown",
            "environment": "ok"
        }
    }
    
    from datetime import datetime
    from .utils.agent_helper import proxy_request
    
    health_status["timestamp"] = datetime.utcnow().isoformat()
    
    # Check MuAPI connectivity
    try:
        await proxy_request("GET", "/agents/skills")
        health_status["checks"]["muapi_connection"] = "ok"
    except Exception as e:
        health_status["checks"]["muapi_connection"] = f"error: {str(e)}"
        health_status["status"] = "degraded"
        logger.warning(f"MuAPI connection check failed: {e}")
    
    # Check environment variables
    if not os.getenv("MU_API_KEY"):
        health_status["checks"]["environment"] = "missing_api_key"
        health_status["status"] = "degraded"
    
    return health_status
