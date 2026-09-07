import os
import httpx
import logging
from fastapi import HTTPException
from typing import Optional

# Configure logging
logger = logging.getLogger(__name__)

MUAPI_BASE_URL = os.getenv("MUAPI_BASE_URL", "https://api.muapi.ai")
DEFAULT_TIMEOUT = float(os.getenv("DEFAULT_TIMEOUT", "30"))
CHAT_TIMEOUT = float(os.getenv("CHAT_TIMEOUT", "60"))
IMAGE_GEN_TIMEOUT = float(os.getenv("IMAGE_GEN_TIMEOUT", "120"))

async def get_api_key():
    """Retrieve and validate API key from environment"""
    api_key = os.getenv("MU_API_KEY")
    if not api_key:
        logger.error("MU_API_KEY not found in environment variables")
        raise HTTPException(
            status_code=500, 
            detail="Server configuration error: MU_API_KEY not configured. Please contact administrator."
        )
    return api_key

async def proxy_request(
    method: str, 
    path: str, 
    payload: Optional[dict] = None, 
    params: Optional[dict] = None,
    timeout_type: str = "default"
):
    """
    Proxy request to MuAPI with configurable timeouts and improved error handling
    
    Args:
        method: HTTP method (GET, POST, PUT, DELETE)
        path: API path
        payload: Request body for POST/PUT requests
        params: Query parameters
        timeout_type: Type of timeout ('default', 'chat', 'image_gen')
    """
    api_key = await get_api_key()
    url = f"{MUAPI_BASE_URL}/{path.lstrip('/')}"
    
    # Select timeout based on operation type
    timeout_map = {
        "default": DEFAULT_TIMEOUT,
        "chat": CHAT_TIMEOUT,
        "image_gen": IMAGE_GEN_TIMEOUT
    }
    timeout = timeout_map.get(timeout_type, DEFAULT_TIMEOUT)
    
    headers = {
        "Content-Type": "application/json",
        "x-api-key": api_key,
        "User-Agent": "Vibe-Agents-Server/1.0.0"
    }

    async with httpx.AsyncClient(timeout=timeout) as client:
        try:
            logger.debug(f"Making {method} request to {url}")
            response = await client.request(
                method=method,
                url=url,
                json=payload,
                params=params,
                headers=headers
            )
            
            # Log response status
            logger.info(f"{method} {path} - Status: {response.status_code}")
            
            # Handle different response types
            content_type = response.headers.get("content-type", "")
            if "application/json" in content_type:
                return response.json()
            else:
                logger.debug(f"Non-JSON response received: {content_type}")
                return {"data": response.text, "content_type": content_type}
                
        except httpx.TimeoutException as e:
            logger.error(f"Request timeout after {timeout}s for {method} {path}: {e}")
            raise HTTPException(
                status_code=504, 
                detail=f"Request timed out after {timeout} seconds. Please try again."
            )
        except httpx.ConnectError as e:
            logger.error(f"Connection error for {method} {path}: {e}")
            raise HTTPException(
                status_code=503, 
                detail="Unable to connect to external service. Please try again later."
            )
        except httpx.RequestError as e:
            logger.error(f"Request error for {method} {path}: {e}")
            raise HTTPException(
                status_code=502, 
                detail=f"Error contacting external service: {str(e)}"
            )
        except HTTPException:
            raise
        except Exception as e:
            logger.exception(f"Unexpected error in proxy_request for {method} {path}: {e}")
            raise HTTPException(
                status_code=500, 
                detail="An unexpected error occurred. Please try again or contact support."
            )
