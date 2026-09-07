from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
import os
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

# Pydantic models for request validation
class AgentSuggestionRequest(BaseModel):
    """Request model for agent suggestions"""
    query: str = Field(..., min_length=1, max_length=500, description="Search query for agent suggestions")
    limit: Optional[int] = Field(default=10, ge=1, le=100, description="Number of results to return")
    
class CreateAgentRequest(BaseModel):
    """Request model for creating an agent"""
    name: str = Field(..., min_length=1, max_length=100, description="Agent name")
    description: str = Field(..., min_length=1, max_length=2000, description="Agent description")
    skills: Optional[list] = Field(default_factory=list, description="List of agent skills")
    config: Optional[Dict[str, Any]] = Field(default_factory=dict, description="Agent configuration")

class ChatRequest(BaseModel):
    """Request model for agent chat"""
    message: str = Field(..., min_length=1, max_length=10000, description="User message")
    conversation_id: Optional[str] = Field(default=None, max_length=100, description="Conversation ID")
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict, description="Additional metadata")

class UpdateAgentRequest(BaseModel):
    """Request model for updating an agent"""
    name: Optional[str] = Field(default=None, min_length=1, max_length=100)
    description: Optional[str] = Field(default=None, min_length=1, max_length=2000)
    skills: Optional[list] = Field(default=None)
    config: Optional[Dict[str, Any]] = Field(default=None)

class ImageGenRequest(BaseModel):
    """Request model for image generation"""
    prompt: str = Field(..., min_length=1, max_length=2000, description="Image generation prompt")
    negative_prompt: Optional[str] = Field(default="", max_length=2000)
    width: Optional[int] = Field(default=512, ge=64, le=2048)
    height: Optional[int] = Field(default=512, ge=64, le=2048)
    steps: Optional[int] = Field(default=20, ge=1, le=150)

class PreviewRealignRequest(BaseModel):
    """Request model for preview realign"""
    changes: Dict[str, Any] = Field(..., description="Proposed changes to the agent")
    validate_changes: Optional[bool] = Field(default=True, description="Whether to validate changes")

class CloudfrontUrlRequest(BaseModel):
    """Request model for CloudFront signed URL"""
    file_path: str = Field(..., min_length=1, max_length=1000, description="File path")
    expiration_minutes: Optional[int] = Field(default=60, ge=1, le=1440, description="URL expiration time in minutes")

MUAPI_BASE_URL = os.getenv("MUAPI_BASE_URL", "https://api.muapi.ai")

# Import after defining models to avoid circular imports
from app.utils.agent_helper import proxy_request
# --- Agent Library Endpoints ---

@router.get("/agents/user/agents")
async def get_user_agents():
    return await proxy_request("GET", "/agents/user/agents")

@router.get("/agents/templates/agents")
async def get_template_agents():
    return await proxy_request("GET", "/agents/templates/agents")

@router.get("/agents/featured/agents")
async def get_featured_agents():
    return await proxy_request("GET", "/agents/featured/agents")

@router.post("/agents/suggest")
async def get_suggested_agents(request_data: AgentSuggestionRequest):
    """Get agent suggestions with validated input"""
    return await proxy_request(
        "POST", 
        "/agents/suggest", 
        payload={"query": request_data.query, "limit": request_data.limit}
    )

@router.post("/agents")
async def create_agent(request_data: CreateAgentRequest):
    """Create a new agent with validated input"""
    logger.info(f"Creating agent: {request_data.name}")
    payload = {
        "name": request_data.name,
        "description": request_data.description,
        "skills": request_data.skills,
        "config": request_data.config
    }
    return await proxy_request("POST", "/agents", payload=payload)

# --- Agent Detail & Chat Endpoints ---
@router.get("/agents/skills")
async def get_agent_skills():
    return await proxy_request("GET", f"/agents/skills")

@router.get("/agents/by-slug/{slug}")
async def get_agent_by_slug(slug: str):
    return await proxy_request("GET", f"/agents/by-slug/{slug}")

@router.get("/agents/{slug}/profile")
async def get_agent_profile(slug: str):
    return await proxy_request("GET", f"/agents/{slug}/profile")

@router.put("/agents/by-slug/{slug}")
async def update_agent_by_slug(slug: str, request_data: UpdateAgentRequest):
    """Update an agent with validated input"""
    logger.info(f"Updating agent: {slug}")
    payload = {k: v for k, v in request_data.model_dump().items() if v is not None}
    return await proxy_request("PUT", f"/agents/by-slug/{slug}", payload=payload)

@router.post("/agents/by-slug/{slug}/chat")
async def agent_chat(slug: str, request_data: ChatRequest):
    """Chat with an agent with validated input"""
    logger.info(f"Chatting with agent: {slug}")
    payload = {
        "message": request_data.message,
        "conversation_id": request_data.conversation_id,
        "metadata": request_data.metadata
    }
    return await proxy_request("POST", f"/agents/by-slug/{slug}/chat", payload=payload)

@router.post("/agents/by-slug/{slug}/like")
async def like_agent(slug: str, request: Request):
    params = dict(request.query_params)
    return await proxy_request("POST", f"/agents/by-slug/{slug}/like", params=params)

@router.get("/agents/by-slug/{slug}/{conv_id}")
async def get_conversation_history(slug: str, conv_id: str):
    return await proxy_request("GET", f"/agents/by-slug/{slug}/{conv_id}")

@router.post("/agents/by-slug/{slug}/preview-realign")
async def get_agent_preview(slug: str, request_data: PreviewRealignRequest):
    """Get agent preview with validated input"""
    logger.info(f"Getting preview for agent: {slug}")
    payload = {
        "changes": request_data.changes,
        "validate": request_data.validate_changes
    }
    return await proxy_request("POST", f"/agents/by-slug/{slug}/preview-realign", payload=payload)

# --- Prediction & Image Gen Endpoints ---

@router.get("/api/v1/predictions/{request_id}/result")
async def get_prediction_result(request_id: str):
    return await proxy_request("GET", f"/api/v1/predictions/{request_id}/result")

@router.post("/api/v1/flux-schnell-image")
async def generate_flux_image(request_data: ImageGenRequest):
    """Generate image with validated input"""
    logger.info(f"Generating image: {request_data.prompt[:50]}...")
    payload = {
        "prompt": request_data.prompt,
        "negative_prompt": request_data.negative_prompt,
        "width": request_data.width,
        "height": request_data.height,
        "steps": request_data.steps
    }
    return await proxy_request("POST", "/api/v1/flux-schnell-image", payload=payload)

# --- App & Workflow Utilities ---

@router.get("/app/get_file_upload_url")
async def get_upload_url(request: Request):
    params = dict(request.query_params)
    return await proxy_request("GET", "/app/get_file_upload_url", params=params)

@router.post("/workflow/cloudfront-signed-url")
async def get_signed_url(request_data: CloudfrontUrlRequest):
    """Get CloudFront signed URL with validated input"""
    logger.info(f"Generating signed URL for: {request_data.file_path}")
    payload = {
        "file_path": request_data.file_path,
        "expiration_minutes": request_data.expiration_minutes
    }
    return await proxy_request("POST", "/workflow/cloudfront-signed-url", payload=payload)

