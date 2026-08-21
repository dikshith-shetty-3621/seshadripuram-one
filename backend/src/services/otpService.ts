import { randomInt } from 'node:crypto';
import { config } from '../config';

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

class ResendOtpService implements OtpService {
  generateOtp(): string {
    return randomInt(100000, 1000000).toString();
  }

  async sendOtp(destination: string, otp: string): Promise<void> {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${config.resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: config.emailFrom,
        to: [destination],
        subject: 'Your Seshadripuram One verification code',
        text: [
          'Your Seshadripuram One verification code is:',
          '',
          otp,
          '',
          'This code expires in 10 minutes and can be used only once.',
          'If you did not request account activation, you can ignore this email.',
        ].join('\n'),
      }),
    });

    if (!response.ok) {
      // Do not log the provider response because it may contain sensitive metadata.
      throw new Error(`Email provider rejected the OTP request with status ${response.status}`);
    }
  }
}

class DisabledOtpService implements OtpService {
  generateOtp(): string {
    return randomInt(100000, 1000000).toString();
  }

  async sendOtp(): Promise<void> {
    throw new Error('No OTP provider is configured');
  }
}

export function createOtpService(): OtpService {
  if (config.otpProvider === 'console' && !config.isProduction) return new ConsoleOtpService();
  if (config.otpProvider === 'resend') return new ResendOtpService();
  return new DisabledOtpService();
}
