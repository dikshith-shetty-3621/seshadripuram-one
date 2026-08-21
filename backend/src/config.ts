const production = process.env.NODE_ENV === 'production';

function required(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} must be configured`);
  return value;
}

export const config = {
  port: Number(process.env.PORT ?? 3000),
  isProduction: production,
  jwtSecret: required('JWT_SECRET'),
  jwtIssuer: process.env.JWT_ISSUER ?? 'seshadripuram-one-api',
  jwtAudience: process.env.JWT_AUDIENCE ?? 'seshadripuram-one-app',
  otpProvider: process.env.OTP_PROVIDER ?? '',
  resendApiKey: process.env.RESEND_API_KEY?.trim() ?? '',
  emailFrom: process.env.EMAIL_FROM?.trim() ?? '',
  corsOrigins: (process.env.CORS_ORIGINS ?? '').split(',').map((origin) => origin.trim()).filter(Boolean),
};

if (config.jwtSecret.length < 32) {
  throw new Error('JWT_SECRET must be at least 32 characters');
}

if (config.otpProvider === 'resend' && (!config.resendApiKey || !config.emailFrom)) {
  throw new Error('RESEND_API_KEY and EMAIL_FROM must be configured when OTP_PROVIDER=resend');
}
