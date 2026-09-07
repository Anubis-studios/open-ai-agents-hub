/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['ai-agent'],
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.muapi.ai',
        port: '',
        pathname: '/**',
      },
    ],
  },
  // Disable rewrites for Vercel deployment - use API routes or external API
  // Rewrites only work in development with local server
  async rewrites() {
    if (process.env.VERCEL) {
      // In production on Vercel, proxy to external API URL
      return [
        {
          source: '/api/:path*',
          destination: `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/api/:path*`,
        },
      ];
    }
    // Local development
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:8000/api/:path*',
      },
    ];
  },
};

export default nextConfig;
