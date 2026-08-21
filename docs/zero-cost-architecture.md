# Seshadripuram One — Zero-Cost Pilot Architecture Decision

## Short answer

An **API is necessary**, but a paid external API is not necessarily required. In this project, the API means the secure HTTP interface between the Flutter app and the backend. The existing repository already contains this backend API under `/api/auth` and `/api/academic`. The Flutter app should never connect directly to the database; it should call the backend API, and the backend should enforce identity, roles, ownership, validation, and audit rules.

The recommended zero-cost pilot stack is:

| Layer | Recommendation | Why |
|---|---|---|
| App | Flutter Android APK distributed directly for the pilot | No app-store fee required for internal testing; Play Store publishing is separate |
| Backend API | Existing Express + TypeScript backend | Lowest migration risk and already implemented |
| Database | Keep Turso/libSQL for the pilot | Existing Drizzle adapter already supports it; current free allowance is suitable for a controlled pilot |
| File storage | Start without large uploads, or use a provider adapter and a small approved free-tier object store | Render local disk is not durable; attachments need separate storage |
| OTP | Development console provider now; college email/manual activation for pilot if permitted | SMS OTP is normally a paid external service; do not hard-code a fake production OTP |
| Notifications | In-app notifications first; email/push later behind adapters | Avoid paid SMS and provider lock-in |
| Backend hosting | Use a free host only for demo/staging, not as a college production SLA | Free compute may sleep, restart, or have quota limits |
| Domain | Provider URL for the pilot | A custom domain is optional and can be added later |
| Monitoring | Built-in logs, health/readiness endpoints, and manual checks initially | Paid observability is not required for the first controlled pilot |

## What “API” means in this project

An API is a set of URLs and rules that lets the Flutter application request or change data. For example, the app may call `GET /api/auth/me` to retrieve the current user or later call `GET /api/academic/attendance/me` to retrieve a student’s attendance. The backend then checks the access token, determines the real user and role, verifies the user’s academic scope, reads the database, and returns JSON.

There are two categories:

| API category | Examples for Seshadripuram One | Paid service required? |
|---|---|---|
| Your own API | Login, activation, announcements, timetable, attendance, marks, assignments, admin import | No. This is code we build and host |
| External APIs | SMS OTP, email delivery, push notifications, object storage, crash reporting, maps or payment services if later required | Not all are needed; some have free tiers and some become paid at real usage |

The college app should not add external APIs just because tutorials mention them. Add an external integration only when a feature requires it, and place it behind an interface so the provider can be replaced.

## External integrations actually needed

### Required for the application itself

The project needs a backend API, a persistent database, authentication/session handling, and a deployment endpoint. These are already represented in the repository. We can build and test them locally without paying anything.

### Required only when real users are onboarded

Real account activation needs a trusted contact channel. SMS OTP usually requires a paid SMS provider. For a zero-rupee college pilot, use one of these institution-approved alternatives: pre-provision accounts and let the administration distribute temporary credentials; use the college’s existing email system if it permits application email; or use a manual admin activation workflow. The current console OTP must remain development-only and must never be used for real student accounts.

Attachments are also a future requirement for notes, assignments, and submissions. Do not store uploads on the backend’s local filesystem because free hosting filesystems can be ephemeral. First implement the file-storage interface and metadata tables; then choose an approved provider only when the college needs file uploads.

## Database decision

Keep **Turso/libSQL** for the first pilot because the repository already uses `drizzle-orm/libsql`, the schema is SQLite-compatible, and switching immediately to PostgreSQL would delay feature delivery without solving the current domain-model gaps. Turso currently lists a free plan with 5 GB storage, 500 million monthly rows read, 10 million monthly rows written, 3 GB monthly syncs, and 1-day point-in-time restore [1]. These limits are adequate for development and a controlled pilot if indexes, pagination, and data retention are implemented correctly.

The database must still be treated as important institutional data. Free-tier allowances are not the same as a college-grade backup contract. Before using real marks or attendance, the institution should approve a backup/export process and a restore drill. Keep all database access behind repositories and migrations so a future move to PostgreSQL remains possible.

### When to move to PostgreSQL

Move to PostgreSQL when the college requires stronger reporting, concurrent administrative imports, larger file/analytics workflows, advanced constraints, institution-wide reliability commitments, or a paid hosting budget. Supabase Free is attractive for a prototype because it currently lists a 500 MB database, 1 GB file storage, 5 GB egress, and 50,000 monthly active users, but its free projects pause after one week of inactivity and do not include automatic backups [2] [3]. Neon Free is another PostgreSQL option, but its free plan has 0.5 GB storage, 100 CU-hours per project, and compute suspension when free limits are reached [4]. Neither is automatically better than Turso for the existing repository.

## Backend deployment decision

Do not use a free backend host as the final promise to the college. Render’s official free-service documentation says its free instances are intended for testing, hobby projects, and previews rather than production applications. Free web services sleep after 15 minutes without inbound traffic, may take about a minute to wake, and have ephemeral local filesystems; Render’s free Postgres also expires after 30 days and has no backups [5].

For a zero-rupee **demo or staging environment**, a free web service can host the Express API while durable data remains in Turso. The API must not write uploads or the main database to the host’s local disk. Expect cold-start delays and occasional restarts.

Cloudflare Workers Free is powerful for a new edge-native API: it currently lists 100,000 requests per day and 10 ms CPU per invocation, while D1 lists 5 million rows read per day, 100,000 rows written per day, and 5 GB total storage [6] [7]. However, moving this Express backend to Workers/D1 would require a significant runtime and database rewrite. It is not the correct next step while the existing Express/Turso foundation is still being developed.

## Zero-cost usage model

The safest zero-cost model is a **limited pilot**, not a promise of unlimited college-wide production. Use one department or one small group of students and teachers, keep attachments disabled initially, use in-app notices instead of SMS, use manual or college-email activation, monitor the free-tier dashboards, export data regularly, and record every restore test.

Do not present this as a guaranteed high-availability service until the college accepts a hosting/database budget. A college-wide platform handling examination marks and official attendance needs ownership, support, backups, incident response, and a service-level expectation. Those requirements eventually create costs even if the software itself is open source.

## Scaling path

The application can scale without a rewrite if we follow these rules now:

1. Keep domain logic independent of Turso-specific client calls.
2. Use migrations, foreign keys, indexes, pagination, and repository interfaces.
3. Keep external providers behind interfaces for OTP, email, push, storage, and monitoring.
4. Use stateless access tokens and server-side refresh sessions.
5. Store files outside the API host.
6. Add audit history to attendance, marks, imports, and publication workflows.
7. Keep the API horizontally deployable even if the first host has one instance.
8. Add queues/outbox processing only when notifications or imports need asynchronous work.

The likely paid upgrade path is a managed always-on backend, managed PostgreSQL or a larger Turso plan, object storage, a production OTP/email provider, monitoring, backups, and a college-owned domain. The code should be prepared for this path, but no paid provider should be introduced before the college’s actual requirements justify it.

## Immediate implementation consequence

The next repository phase should implement academic master data and an admin import workflow while keeping the current Turso adapter. It should not migrate databases or add SMS yet. We should also add provider interfaces for OTP, file storage, and notifications, then keep development adapters active until the college approves real providers.

### References

[1]: https://turso.tech/pricing "Turso pricing"
[2]: https://supabase.com/pricing "Supabase pricing"
[3]: https://supabase.com/docs/guides/platform/billing-on-supabase "Supabase billing and free-plan limits"
[4]: https://neon.com/pricing "Neon pricing"
[5]: https://render.com/docs/free "Render free services documentation"
[6]: https://developers.cloudflare.com/workers/platform/limits/ "Cloudflare Workers limits"
[7]: https://developers.cloudflare.com/workers/platform/pricing/ "Cloudflare Workers pricing and D1 limits"
