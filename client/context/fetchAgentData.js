export async function fetchAgentData(id, cookieHeader, byName = false) {
  const apiBaseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://127.0.0.1:8000';
  const endpoint = `${apiBaseUrl}/api/agents/by-slug/${id}`;
  
  try {
    const res = await fetch(endpoint, {
      cache: 'no-store',
      headers: {
        'Cookie': cookieHeader || '',
        'Content-Type': 'application/json',
      },
    });
    
    if (!res.ok) {
      console.error(`Failed to fetch agent data: ${res.status} ${res.statusText}`);
      return null;
    }
  
    return await res.json();
  } catch (error) {
    console.error('Error fetching agent data:', error.message);
    return null;
  }
}

export async function fetchHistoryData(agentSlug, conversationId, cookieHeader) {
  const apiBaseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://127.0.0.1:8000';
  const endpoint = `${apiBaseUrl}/api/agents/by-slug/${agentSlug}/${conversationId}`;
  
  try {
    const res = await fetch(endpoint, {
      cache: 'no-store',
      headers: {
        'Cookie': cookieHeader || '',
        'Content-Type': 'application/json',
      },
    });
  
    if (!res.ok) {
      console.error(`Failed to fetch history data: ${res.status} ${res.statusText}`);
      return null;
    }
    
    return await res.json();
  } catch (error) {
    console.error('Error fetching history data:', error.message);
    return null;
  }
}
