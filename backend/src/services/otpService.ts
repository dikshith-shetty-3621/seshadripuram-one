export interface OtpService {
  generateOtp(): string;
  sendOtp(destination: string, otp: string): Promise<void>;
}

export class ConsoleOtpService implements OtpService {
  generateOtp(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async sendOtp(destination: string, otp: string): Promise<void> {
    console.log(`\n========================================`);
    console.log(`[DEVELOPMENT] OTP for ${destination}: ${otp}`);
    console.log(`========================================\n`);
  }
}
