
## Verified official limits

### Turso Free
Turso’s pricing page currently lists $0/month, 100 databases, 5 GB storage, 500 million monthly rows read, 10 million monthly rows written, 3 GB monthly syncs, and 1 day point-in-time restore. This matches the current Drizzle/libSQL repository with minimal code changes. Source: https://turso.tech/pricing

### Render Free
Render explicitly says its Free instances are for testing, hobby projects, and previews and should not be used for production applications. Free web services spin down after 15 minutes idle and may take about one minute to wake. Their filesystem is ephemeral, and free Postgres expires after 30 days and has no backups. Source: https://render.com/docs/free

### Cloudflare Workers Free
Cloudflare Workers Free currently lists 100,000 requests/day, 10 ms CPU per invocation, 128 MB memory, and 3 MB compressed Worker size. Cloudflare D1 Free lists 5 million rows read/day, 100,000 rows written/day, and 5 GB total storage, but moving the current Express/libSQL backend to Workers/D1 would be a significant architecture rewrite. Sources: https://developers.cloudflare.com/workers/platform/limits/ and https://developers.cloudflare.com/workers/platform/pricing/

### Supabase Free
Supabase Free currently lists unlimited API requests, 50,000 monthly active users, 500 MB database size, 5 GB egress, 1 GB file storage, 2 active projects, and automatic pausing after one week of inactivity. Free projects do not include automatic backups. Sources: https://supabase.com/pricing and https://supabase.com/docs/guides/platform/billing-on-supabase

### Neon Free
Neon Free currently lists 100 CU-hours per project, 0.5 GB storage per project, 5 GB egress, scale-to-zero after inactivity, and compute suspension when a free limit is reached. It is a strong Postgres option for a prototype but requires a database migration away from the current SQLite/libSQL schema. Source: https://neon.com/pricing

## Decision implication

For the existing codebase, keep Turso/libSQL for the zero-cost pilot and keep the database behind repositories so a later migration to Postgres remains possible. Do not use Render Free for a real college production service because its documented sleep and ephemeral filesystem behavior are unsuitable. For a temporary demo, Render Free is acceptable if all durable data remains in Turso and uploaded files are not stored locally. Cloudflare Workers/D1 is viable for a new edge-native backend but is not the best next step for this existing Express codebase. Supabase Free is attractive if the project is willing to redesign around Postgres and Supabase Auth/Storage, but it is not automatically better for this repository.

## Transactional email provider research

### Resend Free
Resend’s official pricing currently lists $0/month, 3,000 transactional emails/month, and a 100-email/day limit. It supports REST API, SMTP relay, SDKs, DKIM/SPF/DMARC, webhooks, and API-key permissions. Source: https://resend.com/pricing

### Brevo Free
Brevo’s official help page currently lists a permanent free plan with 300 email sends/day, up to 100,000 stored contacts, and Brevo branding on free-plan messages. Source: https://help.brevo.com/hc/en-us/articles/208580669-FAQs-What-are-the-limits-of-the-Free-plan

### MailerSend Free
MailerSend’s official documentation currently lists 500 emails/month with a 100-email/day limit after account approval, plus API and SMTP access. Source: https://www.mailersend.com/help/plans-features-and-limits

## Email provider decision

For a small zero-cost pilot, Resend is the simplest provider to integrate through a provider interface because its free transactional allowance is larger than MailerSend’s and its API is focused on application email. Brevo is a valid alternative if the 300/day limit and free-plan branding are acceptable. No provider should be hard-coded into route logic; configure it with environment variables and retain console delivery for local tests. A verified sender domain or provider-approved sender identity is still required for reliable delivery, and provider free tiers can change.
