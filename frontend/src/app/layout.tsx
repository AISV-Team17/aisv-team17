import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'AISV 관측 플랫폼',
  description: 'LLM 서비스 품질 관제 콘솔',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}