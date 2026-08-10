import { randomInt } from "node:crypto";
import { config } from "../config";

export interface OtpService {
  generateOtp(): string;
  sendOtp(destination: string, otp: string): Promise<void>;
}

class ConsoleOtpService implements OtpService {
  generateOtp(): string {
    return randomInt(100000, 1000000).toString();
  }

  async sendOtp(destination: string, otp: string): Promise<void> {
    // Available only with explicit local-development configuration.
    console.info(`[development OTP] destination=${destination} otp=${otp}`);
  }
}

class DisabledOtpService implements OtpService {
  generateOtp(): string {
    return randomInt(100000, 1000000).toString();
  }

  async sendOtp(): Promise<void> {
    throw new Error("No OTP provider is configured");
  }
}

export function createOtpService(): OtpService {
  if (config.otpProvider === "console" && !config.isProduction) return new ConsoleOtpService();
  return new DisabledOtpService();
}
