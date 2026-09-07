"use client";

import { AiAgent } from "ai-agent";
import "ai-agent/dist/tailwind.css";
import { useState, useEffect } from "react";

// Mock user context - TODO: Replace with actual authentication
const mockUseUser = () => ({
  user: {
    name: "Demo User",
    username: "demo_user",
    profile_photo: "",
  }
});

export default function AgentClientWrapper({ initialAgentDetails, initialHistory = null }) {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Simulate loading state for better UX
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 100);
    
    return () => clearTimeout(timer);
  }, []);

  if (isLoading) {
    return (
      <div className="h-dvh w-full flex items-center justify-center bg-white">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-slate-600 font-medium">Loading agent...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="h-dvh w-full flex items-center justify-center bg-white">
        <div className="flex flex-col items-center gap-4 max-w-md px-6 text-center">
          <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
            <svg className="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h3 className="text-lg font-bold text-slate-900">Failed to load agent</h3>
          <p className="text-slate-600">{error}</p>
          <button 
            onClick={() => window.location.reload()}
            className="px-6 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-dvh w-full">
      <AiAgent 
        initialAgentDetails={initialAgentDetails} 
        initialHistory={initialHistory} 
        useUser={mockUseUser}
        usedIn="muapiapp"
      />
    </div>
  );
}
