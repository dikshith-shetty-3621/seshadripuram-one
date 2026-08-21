# Seshadripuram One — Demo-to-Production Handover

## Operating model

Seshadripuram One is being built as a production-ready application from the beginning. The first deployment is a temporary review environment for the HOD and college stakeholders. It is not the final college service and must not contain official student marks, attendance, or other sensitive records unless the college explicitly approves the environment.

The demo environment should use synthetic or approved sample data, a non-production database, console OTP or a test email sender, and a clear banner that it is for review. The production environment should be created only after the college approves the app, supplies the official infrastructure details, and agrees who owns administration, support, backups, and data protection responsibilities.

## Information to request from the college after approval

| Area | Required information or approval |
|---|---|
| Institution identity | Official college name, campus name, logo, address, and official branding rules |
| Domain | College-owned domain or subdomain for the API, web links, and email sender |
| Email | Approved sender address, email domain, SMTP or transactional-email decision, and sender verification authority |
| User records | Authoritative student, teacher, staff, department, program, semester, section, subject, and enrollment data |
| Data format | Official CSV/Excel export format, column definitions, ID rules, and update frequency |
| Roles | Who may act as super administrator, academic administrator, teacher, student, and support administrator |
| Policies | Account activation, password reset, data retention, attendance correction, marks publication, and account deactivation policies |
| Hosting | College-approved hosting account, billing owner, region/data-residency requirements, and technical contact |
| Database | College-approved managed database or Turso/PostgreSQL decision, backup retention, and restore owner |
| Security | MFA requirement for administrators, allowed networks, incident contacts, and security review requirements |
| Notifications | Approval for email, SMS, push notifications, templates, and opt-out rules |
| File storage | Approved storage provider, file-size rules, retention, malware scanning, and access policy |
| Operations | Support hours, escalation path, maintenance windows, uptime expectation, and release approval process |
| Legal/privacy | Data-controller approval, privacy notice, consent/notice wording, and records-access process |

## Production environment variables

These values must be supplied through the production deployment secret manager, never committed to Git:

```env
NODE_ENV=production
PORT=3000
TURSO_DATABASE_URL=...
TURSO_AUTH_TOKEN=...
JWT_SECRET=...
JWT_ISSUER=...
JWT_AUDIENCE=...
CORS_ORIGINS=https://approved-college-origin.example
OTP_PROVIDER=resend
RESEND_API_KEY=...
EMAIL_FROM=Seshadripuram One <verified-sender@college.example>
```

The final values must be approved by the college technical owner. The demo must use a different database, JWT secret, email account, and API keys from production.

## Handover gates

Production handover should not occur until the following gates pass:

1. The college approves the product scope and the demo feedback is recorded.
2. An authoritative data export has been received and validated through the import preview workflow.
3. An administrator and a backup administrator have been nominated.
4. Production domain, email sender, hosting, database, backups, and secrets are configured.
5. Restore testing has been completed from a known backup.
6. Role and resource-level authorization has been tested with student, teacher, and administrator accounts.
7. Attendance and marks correction/publication policies are encoded and approved.
8. Privacy notice, support contact, incident process, and maintenance process are available.
9. A limited pilot has passed acceptance testing with nominated college users.
10. The college accepts the responsibility and cost of operating the production service.

## Demo restrictions

The demo must not claim college-wide availability or high availability. It should display sample data, use a separate database, avoid real official marks, and provide a way to reset demo data. Production credentials must never be entered into the demo environment.
