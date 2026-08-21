# Seshadripuram One — Antigravity IDE Prompt Pack

## How to use this document

You should not paste the entire document into Antigravity at once. Start with the **Master Context Prompt**, then paste one phase prompt at a time. After each phase, run the verification prompt and inspect the changes before moving to the next phase.

Use a separate Git branch for every phase:

```bash
git checkout -b phase-01-backend-modularization
```

If Antigravity proposes a large rewrite, stop and ask it to reduce the change. This project should evolve incrementally. The target architecture is a **modular monolith**, not microservices.

---

## Master Context Prompt

```text
You are working inside the existing Seshadripuram One repository.

Project context:
- Flutter/Dart mobile-first client in /lib.
- Node.js + Express + TypeScript backend in /backend.
- Drizzle ORM with SQLite/libSQL/Turso.
- Riverpod for Flutter state management.
- GoRouter for navigation.
- Dio for HTTP.
- Flutter secure storage for tokens.
- Current repository phase: authentication and authorization foundation.
- Existing backend authentication tests must remain passing.

Product goal:
Build a secure digital academic platform for Seshadripuram College serving students, teachers, administrators, and later parents or guardians if approved by the college. The platform will support identity activation, announcements, timetable, attendance, marks, assignments, notes, submissions, notifications, reports, and administration.

Important engineering rules:
1. Do not introduce microservices. Keep one deployable backend and one database, but organize the backend as a modular monolith.
2. Do not delete working authentication behavior unless you first explain the migration and preserve tests.
3. Do not trust role, institution, student, section, subject, or ownership values supplied by Flutter. The backend must derive and verify them from the database.
4. Use schema validation at every API boundary. Reject unknown or malformed input safely.
5. Academic records require history, auditability, correction workflows, and publication states. Do not silently overwrite important records.
6. Never log passwords, OTPs, JWTs, refresh tokens, activation grants, or unnecessary personal data.
7. Use migrations for database changes. Never edit production data manually.
8. Implement responsive, accessible, mobile-first UI. The app must work on small phones, tablets, and desktop/web widths where supported.
9. Use the Seshadripuram College visual direction: dark navy foundation, gold/yellow highlights, white surfaces/cards, restrained red/orange status accents, circular S emblem/logo, formal academic hierarchy, and subtle futuristic effects. Use the official logo asset; do not redraw the logo.
10. Prefer readable, calm, premium academic design over excessive neon, excessive animation, or low-contrast glassmorphism.

Development behavior:
- First inspect the relevant existing files and explain your implementation plan.
- Make the smallest coherent change for the current phase.
- Show files changed and why.
- Add or update tests before declaring the phase complete.
- Run backend typecheck/tests and Flutter analyze/tests when the required tools are available.
- If a requirement is ambiguous, record an assumption in docs/assumptions.md instead of inventing a risky data model.
- Never claim production readiness without evidence from tests, configuration, security checks, and deployment verification.
```

---

# Phase 0 — Create a safe baseline

## Prompt to paste

```text
Using the master context, prepare the repository for incremental production work.

Tasks:
1. Inspect the complete repository and current git status.
2. Create docs/architecture.md describing the current system, target modular-monolith architecture, module boundaries, API boundary, database boundary, and deployment boundary.
3. Create docs/assumptions.md with unresolved college decisions, including academic structure, identity source, attendance rules, mark publication, file retention, roles, and privacy ownership.
4. Add a root-level development guide with exact commands for backend tests, Flutter tests, migrations, local development, and staging.
5. Add a CI checklist covering backend typecheck, backend tests, Flutter analyze, Flutter tests, migration validation, dependency audit, and release build checks.
6. Do not change application behavior in this phase.

Acceptance criteria:
- Documentation accurately describes implemented features separately from planned features.
- No secrets or real credentials are added.
- Existing backend tests still pass.
- The diff is documentation and configuration only unless a minimal CI fix is necessary.
```

## Verification prompt

```text
Review Phase 0 as a maintainer. Compare the new documentation to the actual source tree. Identify every statement that describes a planned feature as implemented. Run the backend typecheck and test suite. Report failures without hiding them.
```

---

# Phase 1 — Modularize the backend without changing behavior

## Prompt to paste

```text
Refactor the backend into a modular monolith while preserving the current API behavior.

Create clear layers:
- routes/controllers: HTTP concerns only
- validators/DTOs: request and response schemas
- services/use-cases: business workflows
- repositories: database access
- policies: authorization decisions
- shared errors and request context

For authentication, separate these use cases:
- resolve authoritative identity
- request activation
- verify OTP
- complete activation
- login
- refresh session
- logout
- get current user

Move database queries out of the route module. Keep endpoint paths and response behavior compatible unless a documented correction is required. Add dependency injection where practical so services can be tested without global state. Add a request ID/correlation ID middleware and structured error types. Do not expose stack traces in production.

Acceptance criteria:
- Authentication routes become thin controllers.
- Existing backend tests pass unchanged or with only justified test-helper changes.
- New unit tests cover identity resolution, session rotation, and activation grant validation.
- No password, OTP, token, or personal-data secrets appear in logs.
- Typecheck and tests pass.
```

---

# Phase 2 — Establish college master data and import workflow

## Prompt to paste

```text
Implement the academic master-data foundation before implementing attendance or marks.

Design and migrate tables for the college’s approved structure. At minimum evaluate:
- institutions/campuses
- departments
- programs/courses
- academic years
- semesters
- sections/batches
- subjects
- subject offerings
- students
- teachers
- enrollments
- teaching assignments

Use foreign keys, unique constraints, indexes, active/inactive status, effective dates, and created/updated metadata. Preserve the existing auth relationships. Do not duplicate the same concept under multiple names.

Implement an admin-only import workflow for CSV or JSON:
- upload or submit a file through a controlled API
- preview parsed rows
- validate required fields and references
- detect duplicates and conflicting records
- support dry-run mode
- produce row-level errors
- support idempotent re-imports
- write an import audit record
- never partially modify authoritative data without a clear transaction or quarantine strategy

Start with backend APIs and tests. Add minimal admin screens only after the API and data rules are clear.

Acceptance criteria:
- A sanitized sample dataset can be imported and re-imported safely.
- Invalid rows are reported without corrupting valid existing records.
- Non-admin users cannot import or modify master data.
- Tests cover duplicate IDs, inactive students, missing subjects, wrong department references, and cross-institution attempts.
```

---

# Phase 3 — Replace role-only access with scoped authorization

## Prompt to paste

```text
Implement resource- and scope-based authorization for the academic domain.

Role checks remain necessary but are not sufficient. Introduce policy functions that verify:
- student can view only their own records
- teacher can access only assigned sections and subjects
- department staff can access only approved department scope
- administrators receive only explicitly granted administrative capabilities
- inactive or transferred users lose access according to status rules

Create policies such as:
- canViewStudentProfile
- canViewAttendance
- canEditAttendance
- canViewMarks
- canEditMarks
- canPublishAnnouncement
- canManageMasterData
- canDownloadAttachment

Every policy must use server-side database lookups. Never authorize from URL IDs or Flutter-provided role fields alone.

Add authorization tests for both allowed and denied cases, especially IDOR scenarios where a valid user changes a studentId, sectionId, subjectId, or announcementId in the request.

Acceptance criteria:
- Every protected academic endpoint has an explicit policy.
- Cross-student and cross-section access tests fail safely with 403 or an intentionally documented response.
- Authorization logic is reusable outside HTTP routes.
- Student, teacher, and admin roles cannot bypass scope checks.
```

---

# Phase 4 — Implement the academic core

## Prompt to paste

```text
Implement the first usable academic module in this order: announcements, timetable, and attendance.

Announcements:
- institution, department, program, section, subject, and individual audience scopes
- draft/published/archived states
- author and publication timestamps
- optional attachments
- student read/unread tracking if required

Timetable:
- academic year, semester, section, subject, teacher, room, weekday, start/end time
- collision validation for teachers, rooms, and sections
- timezone-safe storage and display

Attendance:
- class/attendance session
- section and subject offering
- date/time and recorded-by teacher
- student enrollment records
- present/absent/late/excused states, subject to college approval
- edit window and correction workflow
- history of changes
- student summary and subject-wise summary

Do not build only a CRUD form. Enforce teaching assignments and enrollment scope. Add pagination and filtering to list APIs. Return stable DTOs rather than raw database rows.

Acceptance criteria:
- A teacher can record attendance only for an assigned subject and section.
- A student can view only their own attendance and permitted summaries.
- Attendance corrections preserve an audit trail.
- Duplicate attendance sessions and invalid student enrollments are rejected.
- Backend integration tests cover the entire workflow.
```

---

# Phase 5 — Implement marks with publication and correction controls

## Prompt to paste

```text
Implement assessment and marks management as a controlled workflow.

Model:
- assessment/examination
- assessment components
- maximum marks and grading rules
- student result records
- draft/submitted/approved/published/superseded states
- entered-by, approved-by, timestamps
- correction reason and revision history

Support the college’s actual terminology after recording it in docs/assumptions.md. Do not assume whether the institution calls an exam SIM, semester, internal, university, project, or practical without confirmation.

Rules:
- teachers can edit only assigned assessments and students in scope
- students can read only published results belonging to them
- published marks cannot be silently overwritten
- administrators can approve or correct only with explicit audit evidence
- calculate totals and percentages on the server
- validate maximum marks, decimal precision, grading boundaries, and missing components

Acceptance criteria:
- Every mark change is attributable and historically recoverable.
- Students never see draft or unpublished marks.
- Tests cover unauthorized edits, invalid scores, publication, correction, and result visibility.
```

---

# Phase 6 — Add assignments, notes, and secure file storage

## Prompt to paste

```text
Add assignments, submissions, notes, and attachments using a storage abstraction.

Do not store arbitrary file binaries directly in the main academic tables. Create file metadata with owner, academic scope, MIME type, size, checksum, upload status, scan status, visibility, and deletion state. Use an object-storage provider behind an interface so local development can use a mock or local adapter.

Implement:
- teacher creates and publishes assignment
- students see assignments for their enrolled subjects
- students submit before the deadline
- resubmission rules are explicit
- teacher can view submissions only for assigned scope
- notes are visible only to the intended audience
- signed short-lived download/upload URLs
- file size and allowed MIME limits
- malware scanning status before publication

Acceptance criteria:
- A user cannot download a file by changing its ID.
- Expired or unauthorized signed URLs are rejected.
- Submission deadlines and timezone handling are tested.
- No file is publicly accessible by default.
```

---

# Phase 7 — Notifications and operational workflows

## Prompt to paste

```text
Implement notifications using an outbox/job pattern rather than sending external messages inside academic request handlers.

Create notification events and jobs with:
- event type and payload reference
- recipient and channel
- queued/processing/sent/failed states
- retry count and next retry time
- provider response metadata without secrets
- idempotency key
- user notification preferences

Start with in-app notifications and email if configured. Keep SMS/push providers behind interfaces. A provider outage must not fail an attendance or announcement transaction.

Add admin/support capabilities for viewing failed jobs without exposing message secrets. Add tests for duplicate events, retry limits, provider failures, and permission-safe notification content.
```

---

# Phase 8 — Production security, privacy, and observability

## Prompt to paste

```text
Harden the application for staging and production without weakening developer experience.

Backend:
- validate all request bodies, query parameters, and path parameters
- add secure HTTP headers
- enforce HTTPS in production
- configure precise CORS allowlists
- add route-specific rate limits for activation, OTP, login, refresh, password reset, and imports
- use request IDs and structured logs
- redact secrets and sensitive fields
- add health and readiness endpoints
- add graceful shutdown
- add dependency and secret scanning
- document JWT secret rotation and session revocation

Authentication:
- implement the Flutter 401 refresh flow with a single-flight lock
- limit retries to one refresh attempt per request
- clear sessions on refresh failure
- support device/session listing and revocation
- add password reset and administrator MFA if approved

Privacy and governance:
- create a data inventory
- define collection purpose and retention
- document student/staff access boundaries
- document correction/deletion handling with the college authority
- create an incident and breach-response procedure
- ensure audit logs do not contain passwords, OTPs, raw tokens, or unnecessary personal data

Acceptance criteria:
- Security tests cover authentication abuse, IDOR, rate limits, sensitive logging, CORS, and token revocation.
- Production configuration fails closed when required secrets or providers are missing.
- A staging deployment can be monitored and safely shut down.
```

---

# Phase 9 — Backups, deployment, and release readiness

## Prompt to paste

```text
Prepare a staging and production deployment plan for the existing architecture.

Create:
- separate development, staging, and production environment configuration
- secret-management instructions without committing secrets
- database migration and rollback/runbook documentation
- automated database backup schedule
- protected backup storage and retention policy
- restore drill procedure with a recorded test result
- monitoring for API errors, latency, database failures, OTP failures, job failures, and storage failures
- crash reporting for Flutter with sensitive-data scrubbing
- release signing and staged rollout instructions
- deployment health checks and smoke tests
- incident response and rollback instructions

Use a platform-provided backend URL initially if necessary. Do not make a custom domain a prerequisite. Treat the college’s real data as sensitive. Start the pilot with sanitized or limited-scope data and obtain institutional approval before expanding.

Acceptance criteria:
- A new environment can be configured from documented steps.
- Deployments run migrations safely and expose readiness only after dependencies are available.
- A backup can be restored into a separate test database.
- A smoke test verifies login, activation where appropriate, /me, one student read flow, one teacher write flow, and one admin workflow.
- Production secrets are absent from git history and build artifacts.
```

---

# Phase 10 — Full verification prompt

```text
Act as a production-readiness reviewer for Seshadripuram One.

Inspect the repository and produce a report with:
1. implemented features versus planned features
2. failing or missing tests
3. authentication and authorization findings
4. IDOR and cross-scope test results
5. migration and data-integrity risks
6. privacy and sensitive-data handling risks
7. observability, backup, and restore evidence
8. Flutter responsiveness and accessibility findings
9. deployment reproducibility findings
10. a go/no-go decision for a limited college pilot

Do not mark an item complete because documentation exists. Require code, tests, configuration, or recorded evidence. Give every finding a severity: P0 blocker, P1 before pilot, P2 before broad rollout, or P3 improvement.
```

---

# Futuristic Seshadripuram UI design system

The college website suggests a formal academic identity built around the **Seshadripuram emblem, navy/dark sections, gold achievement accents, white content areas, accreditation, programs, news, events, facilities, and student success**. The app should modernize that identity without becoming a gaming interface.

## Theme tokens

Use these as a starting point, then sample the official logo assets and adjust them after stakeholder review.

| Token | Suggested value | Use |
|---|---|---|
| `navy950` | `#07111F` | App background and dark hero surfaces |
| `navy900` | `#0B1B2B` | Navigation, headers, dashboard shell |
| `navy800` | `#12304A` | Elevated panels and selected states |
| `gold500` | `#D7A928` | Primary brand accent, progress, achievement, focus |
| `gold300` | `#F0CE63` | Hover/highlight and light accent |
| `paper` | `#F7F9FC` | Main light surface |
| `white` | `#FFFFFF` | Cards and readable content surfaces |
| `ink` | `#17212B` | Primary text on light surfaces |
| `muted` | `#64748B` | Secondary text |
| `success` | `#1F9D68` | Present, approved, successful |
| `warning` | `#D97706` | Pending, late, attention |
| `danger` | `#C43D3D` | Failed, absent, destructive actions |

Use gold sparingly. Gold should indicate importance, progress, active navigation, and achievement—not every button. Maintain strong contrast for text and controls. Use subtle gradients such as navy-to-blue or navy-to-gold glow only behind focal areas.

## Component style

Use rounded cards with 16–20 px radius, 1 px low-opacity borders, 20–24 px spacing, large readable headings, and consistent icon containers. On dark surfaces, use translucent navy panels rather than transparent white glass. On light surfaces, use white cards with very light gray borders and a small shadow. Motion should be short and purposeful: 150–220 ms transitions, gentle chart entrance, and no continuous animation that harms concentration or battery life.

## Information architecture

| User | Primary navigation |
|---|---|
| Student | Home, Timetable, Attendance, Marks, Assignments, Notes, Announcements, Profile |
| Teacher | Home, My Classes, Attendance, Assessments, Assignments, Materials, Announcements, Profile |
| Admin | Overview, Students, Teachers, Academics, Imports, Audit Logs, Reports, Settings |

Use a bottom navigation bar with four or five high-frequency items on phones. Put the rest behind a “More” destination. On tablets and desktop widths, use a permanent or collapsible left rail. Never force a phone user to navigate a desktop-style sidebar.

## Student dashboard wireframe

```text
┌──────────────────────────────────────┐
│ [S logo] Good morning, Ananya    [bell]│
│ BCA • Semester 4 • Section A       [avatar]
├──────────────────────────────────────┤
│ TODAY                                 │
│ ┌──────────────────────────────────┐ │
│ │ 09:00  Web Technology             │ │
│ │        Room 204 • Dr. Rao         │ │
│ │                         View day →│ │
│ └──────────────────────────────────┘ │
│                                      │
│ QUICK OVERVIEW                        │
│ [Attendance 86%] [Next deadline 2d]  │
│ [Current GPA — ] [Unread 4]           │
│                                      │
│ ANNOUNCEMENTS                         │
│ Examination timetable published   →  │
│ Workshop registration open         →  │
├──────────────────────────────────────┤
│ Home   Timetable   Attendance   More  │
└──────────────────────────────────────┘
```

## Teacher dashboard wireframe

```text
┌────────────────────────────────────────┐
│ [S logo] Teacher workspace        [bell]│
│ Tuesday, 22 August 2026             [avatar]
├────────────────────────────────────────┤
│ GOOD MORNING, DR. RAO                   │
│ [3 classes today] [2 pending reviews]   │
│                                        │
│ TODAY'S CLASSES                         │
│ BCA 4A • Web Technology • 09:00         │
│ [Take attendance]                       │
│ BCA 4B • Database Systems • 11:00       │
│ [Take attendance]                       │
│                                        │
│ QUICK ACTIONS                           │
│ [Create announcement] [New assignment]  │
│ [Enter marks]       [Upload material]   │
├────────────────────────────────────────┤
│ Home  Classes  Attendance  Assessments  More│
└────────────────────────────────────────┘
```

## Attendance screen wireframe

```text
┌──────────────────────────────────────┐
│ ← Attendance                         │
│ BCA 4A • Web Technology               │
│ 22 Aug 2026 • 09:00 • Room 204        │
├──────────────────────────────────────┤
│ [All present] [Save draft]             │
│ Present 38   Absent 4   Late 2        │
├──────────────────────────────────────┤
│ Search student…                       │
│ ○ 01  A. Ananya           Present     │
│ ○ 02  B. Bharath          Absent      │
│ ○ 03  C. Charan           Present     │
│ ...                                    │
├──────────────────────────────────────┤
│ [Save attendance]                      │
└──────────────────────────────────────┘
```

## UI implementation prompt for Antigravity

```text
Implement the Seshadripuram One design system in Flutter without changing backend behavior.

Create centralized theme tokens and reusable components:
- AppColors
- AppTypography
- AppSpacing
- AppRadii
- AppShadows
- PrimaryButton
- SecondaryButton
- AppCard
- StatCard
- SectionHeader
- EmptyState
- ErrorState
- LoadingSkeleton
- ResponsiveScaffold
- RoleAwareBottomNavigation

Use the navy/gold/white academic palette described in docs/ui-design.md. Add light and dark themes where practical, but keep contrast and accessibility as the priority. Use the official logo asset if available and add a clear placeholder instruction if it is not.

Implement responsive breakpoints:
- compact: under 600 px, bottom navigation and one-column cards
- medium: 600–1024 px, two-column content and compact rail
- expanded: over 1024 px, navigation rail/sidebar and constrained content width

Do not put business logic directly in widgets. Screens should consume Riverpod state/controllers. Every screen must have loading, empty, error, retry, and success states. Keep motion subtle and disable nonessential animation when accessibility settings request reduced motion.

First implement the theme and reusable components, then apply them to the login screen and role dashboards. Keep the layout functional with placeholder data until the APIs are implemented.
```

---

# How to sketch UI as a beginner

Start with paper or a simple drawing tool. Do not begin with colors. First draw rectangles for the header, content, cards, buttons, and navigation. For every screen, answer three questions: **What is the most important action? What information must be visible immediately? Where does the user go next?**

Create only these first five sketches: login/activation, student home, teacher home, attendance entry, and admin import. Draw each at phone width first. Then redraw the same screen at tablet width and decide what becomes a second column or a side rail.

A simple screen specification should look like this:

```text
Screen name: Student dashboard
User: Student
Primary goal: Quickly see today’s class, attendance, and urgent notices
Primary action: Open today’s timetable or attendance detail
Required states: loading, loaded, empty, error, offline
Navigation: Home → Timetable / Attendance / Announcement detail
Data needed: current user, today’s classes, attendance summary, announcements
```

Do not make one giant dashboard containing every feature. Use progressive disclosure: show the most important four or five items, then provide “View all.” This is especially important for students using small screens.

## Final UI review prompt

```text
Review the Flutter UI as a senior product designer and accessibility reviewer.

Check:
- Is the most important action obvious within three seconds?
- Does the design visibly belong to Seshadripuram College without copying the website layout literally?
- Are navy, gold, white, and status colors used consistently?
- Is text readable in both light and dark surfaces?
- Does the layout work at 360 px, 768 px, and 1280 px widths?
- Are loading, empty, error, retry, offline, and success states present?
- Can a student use the app with one hand on a phone?
- Can a teacher complete attendance with minimal taps?
- Can an administrator understand import errors row by row?
- Are buttons, focus states, labels, and touch targets accessible?

Return findings grouped as P0 usability blockers, P1 before pilot, and P2 polish. Fix only P0 and P1 findings in this pass.
```

## Recommended first step

Paste **Master Context Prompt**, then **Phase 0**, and commit the result. After that, paste **Phase 1**. Do not start with the futuristic UI. First make the architecture and data boundaries safe; then apply the design system to the login and dashboards while academic APIs are built in parallel.
