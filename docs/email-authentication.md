# Email OTP authentication

Seshadripuram One now supports provider-agnostic OTP delivery with two modes:

| Mode | Configuration | Intended use |
|---|---|---|
| Console | `OTP_PROVIDER=console` | Local development and automated tests only |
| Resend | `OTP_PROVIDER=resend` plus `RESEND_API_KEY` and `EMAIL_FROM` | Limited pilot after sender verification |

## Resend setup

1. Create a Resend account and create an API key.
2. Verify the sender identity or domain required by Resend.
3. Copy `backend/.env.example` to `backend/.env`.
4. Set the following values locally or in the hosting provider’s secret manager:

```env
OTP_PROVIDER=resend
RESEND_API_KEY=your-resend-api-key
EMAIL_FROM=Seshadripuram One <verified-sender@example.com>
NODE_ENV=development
```

5. Start the backend and request account activation from the Flutter app.
6. Confirm that the email arrives before using the provider with real users.

Do not commit `backend/.env`, API keys, OTP values, or provider responses. The backend validates that `RESEND_API_KEY` and `EMAIL_FROM` are present when `OTP_PROVIDER=resend` is selected. In production, an unconfigured provider fails closed instead of silently logging OTPs.

## Limits and operational rules

Resend’s current free plan is listed as 3,000 transactional emails per month with a 100-email/day limit. These limits can change, so monitor the provider dashboard. Rate limiting in the backend remains necessary because provider quotas do not prevent abuse by themselves.

Email OTP is suitable for a small controlled pilot only if the college approves the verified sender and the contact data. Email delivery is not the same as identity proof; the backend must still resolve the institution ID against authoritative student/teacher records. Keep OTPs hashed, short-lived, one-time-use, and attempt-limited.

For local development, keep `OTP_PROVIDER=console` and read the generated code from the backend terminal. Never use console OTP delivery for real college accounts.
