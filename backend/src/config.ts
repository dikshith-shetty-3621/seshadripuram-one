import "dotenv/config";

const production = process.env.NODE_ENV === "production";

function required(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} must be configured`);
  return value;
}

export const config = {
  port: Number(process.env.PORT ?? 3000),
  isProduction: production,
  jwtSecret: required("JWT_SECRET"),
  jwtIssuer: process.env.JWT_ISSUER ?? "seshadripuram-one-api",
  jwtAudience: process.env.JWT_AUDIENCE ?? "seshadripuram-one-app",
  otpProvider: process.env.OTP_PROVIDER ?? "",
  corsOrigins: (process.env.CORS_ORIGINS ?? "").split(",").map((origin) => origin.trim()).filter(Boolean),
};

if (config.jwtSecret.length < 32) {
  throw new Error("JWT_SECRET must be at least 32 characters");
}
