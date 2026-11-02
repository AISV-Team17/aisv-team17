import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  output: 'standalone',
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        // docker-compose의 CONSOLE_API_URL 환경변수로 주입, 기본값은 내부 서비스명
        destination: `${process.env.CONSOLE_API_URL ?? 'http://console:8002'}/api/:path*`,
      },
    ];
  },
};

export default nextConfig;