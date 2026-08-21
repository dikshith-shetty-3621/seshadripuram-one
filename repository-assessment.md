# Seshadripuram One — Architecture and College-Readiness Assessment

**Repository reviewed:** `dikshith-shetty-3621/seshadripuram-one`
**Review basis:** source tree, README, database migration/schema, Flutter client, backend tests, CI configuration, and local validation.
**Assessment date:** 22 August 2026

## Executive assessment

Seshadripuram One has a sensible **foundation**, but it is not yet an academic information system that should be used with real college records. The repository currently implements an authentication and authorization proof of concept: Flutter screens and routing exist, the Express/TypeScript backend runs, user activation uses OTP concepts, refresh sessions are persisted, and the backend test suite passes. However, the academic domain is still almost entirely planned. The database migration contains authentication-related tables plus student and teacher profiles, while the only academic API is a deliberately unimplemented attendance authorization boundary returning HTTP 501.

The most important change is therefore not to split the system into microservices. The project is still small, and microservices would add deployment, monitoring, and data-consistency complexity before the product has real modules. The appropriate next step is a **modular monolith**: one backend deployment and one database, but clearly separated modules, services, repositories, policies, and API contracts. This will let the college launch safely while preserving a path to scale later.

## Current state verified from the repository

| Area | Current state | Assessment |
|---|---|---|
| Client | Flutter with Riverpod, GoRouter, Dio, secure storage, and role-based routes | Good foundation; feature implementation is minimal |
| Backend | Express 5, TypeScript, Drizzle ORM, libSQL/Turso | Appropriate for an initial deployment |
| Authentication | OTP activation, bcrypt password hashing, JWT access tokens, refresh-session rotation, logout | Promising foundation, but production controls remain incomplete |
| Authorization | Server-side `requireAuthentication` and role checks | Necessary baseline; must become resource- and scope-based |
| Academic data | Student/teacher profile tables only in the migration | Major gap between README vision and implemented schema |
| Academic APIs | Only `POST /api/academic/attendance`, returning 501 | No usable attendance, marks, timetable, assignments, notes, or announcements |
| Admin operations | Admin role foundation; no admin data-management workflow | Critical for maintaining authoritative college data |
| Testing | Backend authentication suite: 7 tests passing; Flutter tests exist | Coverage is narrow and does not validate academic behavior |
| Operations | Codemagic workflows and environment templates exist | Deployment, monitoring, backups, secrets, and production OTP are pending |

The backend validation completed successfully with `npm run typecheck` and `npm test`; the test suite reported seven passing authentication tests. Flutter static analysis could not be run in this environment because the Flutter executable was unavailable, so it should be run in CI and on a Flutter-equipped development machine before merging client changes.

## Architecture changes recommended

### 1. Keep the deployment simple, but modularize the backend

The current `backend/src/routes/auth.ts` contains HTTP parsing, identity resolution, lazy account provisioning, OTP workflow, activation grants, password hashing, session issuance, refresh rotation, and audit writes. This is manageable during the foundation phase but will become difficult to test and unsafe to extend when academic features are added.

Refactor into a modular monolith with a structure similar to:

```text
backend/src/
  app.ts                 # Express app composition
  server.ts              # process startup
  config/
  db/
    schema/
    migrations/
    repositories/
  modules/
    identity/
    authentication/
    authorization/
    academics/
      departments/
      programs/
      subjects/
      academic-years/
      sections/
      enrollments/
    attendance/
    assessments/
    assignments/
    learning-materials/
    announcements/
    notifications/
    administration/
    audit/
  shared/
    errors/
    validation/
    pagination/
    observability/
```

Each module should separate **route/controller**, **use-case/service**, **repository**, **schema/DTO**, and **policy** responsibilities. Keep a single database and deployment for now. Consider extracting a separate service only when a module has an independent scaling profile, a strong operational reason, or an external integration that must be isolated.

### 2. Replace role-only authorization with scoped, resource-based authorization

Checking `TEACHER` or `ADMIN` is not sufficient for college data. A teacher may be allowed to enter attendance for assigned sections and subjects, but not for another department. A student may read only their own attendance, marks, assignments, and submissions. An administrator may manage master data but should not automatically receive unrestricted access to every sensitive record.

Introduce policies such as:

```text
canViewAttendance(actor, enrollment/section/subject)
canEditAttendance(actor, teachingAssignment, attendanceSession)
canViewMarks(actor, assessment, student)
canPublishAnnouncement(actor, audienceScope)
canManageMasterData(actor, institutionScope)
```

Every academic table should carry enough ownership and scope information to evaluate these policies. Authorization must be tested with positive and negative cases, including cross-section, cross-department, inactive-user, and modified-ID requests.

### 3. Build the academic master-data model before feature screens

The README lists departments, courses, subjects, academic years, semesters, sections, enrollments, timetable, attendance, marks, assignments, notes, and announcements, but those entities are not yet implemented in the migration. The college needs an authoritative data model before attendance or marks can be trusted.

A minimum relational model should include `institutions`, `campuses`, `departments`, `programs`, `academic_years`, `semesters`, `sections`, `students`, `teachers`, `subjects`, `subject_offerings`, `enrollments`, and `teaching_assignments`. Use foreign keys, unique constraints, status fields, effective dates, and indexes deliberately. Avoid storing academic context only as free-text fields.

The current `resolveIdentity()` behavior lazily creates a `users` row during an activation request. For production, prefer an explicit import/provisioning workflow that validates records first, reports errors, and creates accounts in a controlled job. Authentication should consume authoritative records, not mutate institutional master data as a side effect of a login-related request.

### 4. Design academic records for correction, history, and auditability

Attendance and marks are not ordinary mutable profile fields. They need who/when/why history and preferably a correction workflow. For attendance, model an attendance session or class meeting, enrollment/student presence, status, recorded-by, recorded-at, and correction/reversal metadata. For marks, model assessment definition, component, maximum marks, student result, entered-by, version or revision, publication status, and moderation/approval where the college requires it.

Do not allow a teacher to silently overwrite a published mark. Use draft, submitted, approved, published, and superseded states where appropriate. The existing `audit_logs` table is too generic for high-value academic changes because it lacks actor identity, target resource, before/after representation, request correlation, and IP/device context. Extend audit events while carefully excluding passwords, OTPs, raw tokens, and unnecessary personal data.

### 5. Add a proper file-storage boundary

Assignments, notes, and submissions will require attachments. Do not store arbitrary binary files directly in the application database or accept uncontrolled file paths. Add an object-storage abstraction with metadata tables for owner, academic scope, MIME type, size, checksum, scan status, visibility, and deletion state. Use short-lived signed upload/download URLs, server-side authorization before issuing URLs, file-size/type limits, malware scanning, and retention rules.

### 6. Add notifications as an asynchronous capability

Announcements and reminders should not make the main academic request wait on SMS, email, or push delivery. Introduce an outbox or job table and a worker process for notification delivery, retries, deduplication, provider status, and user preferences. Start with in-app notifications and email; add push notifications after device-token registration and consent/preferences are defined. This can remain inside the modular monolith initially.

## Security and privacy changes before real deployment

The authentication foundation is directionally good, but several controls need to be completed before handling real student data.

| Priority | Required change | Reason |
|---|---|---|
| P0 | Connect a production OTP provider and define delivery fallback | Console OTP is development-only; activation cannot be safely launched as-is |
| P0 | Add brute-force protection by institution ID, IP, device, and contact destination | A single global route limiter is not enough for credential and OTP abuse |
| P0 | Add security headers, structured request IDs, input schema validation, and consistent error handling | Improves attack resistance, debugging, and safe client behavior |
| P0 | Define secrets management, key rotation, and emergency session revocation | JWT and refresh-token compromise must be containable |
| P0 | Establish database backups and tested restores | Academic records require recoverability, not merely database availability |
| P1 | Add account lockout/risk controls, password reset, session/device management, and optional MFA for administrators | Required for real operational use and privileged accounts |
| P1 | Review CORS, HTTPS enforcement, production logging, dependency scanning, and rate limits at the edge | Reduces deployment and abuse risks |
| P1 | Create a data inventory and retention policy for IDs, contact data, attendance, marks, files, audit logs, and tokens | The platform processes personal and academic data; governance must be explicit |
| P1 | Add privacy notices, institutional roles, data-subject request handling, breach response, and vendor agreements | Needed for responsible deployment under the institution’s policies and applicable Indian data-protection requirements |

Use the OWASP Application Security Verification Standard as a release checklist rather than treating authentication tests alone as a security assessment. OWASP describes ASVS as a basis for testing technical security controls and as secure-development guidance [1]. The official Ministry of Electronics and Information Technology publication of the Digital Personal Data Protection Act, 2023 should be reviewed with the college’s designated legal/privacy authority for the institution’s exact obligations [2].

The application should also implement protected, independent backups and routinely test restoration. NIST guidance emphasizes that backup protection and recovery testing are part of reducing data-loss impact, not optional operational extras [3].

## Flutter client changes

The Flutter foundation is clean enough to continue, but the current client will become tightly coupled as modules grow. The authentication repository currently combines API calls, refresh-token logic, secure persistence, user parsing, and auth-state streaming. Split these concerns into an authentication data source, session manager, token store, auth repository, and presentation notifier/controller.

The interceptor currently attaches the access token, but its 401 handler contains only a placeholder comment. Implement a single-flight refresh mechanism so concurrent failed requests do not rotate the same refresh token multiple times. On refresh failure, clear local session state and route to login. Add cancellation, retry limits, offline detection, user-friendly error mapping, and observability that never logs secrets.

Organize each new feature consistently, for example:

```text
lib/features/attendance/
  data/
    attendance_api.dart
    attendance_repository.dart
    attendance_models.dart
  domain/
    attendance.dart
    attendance_policy.dart
  presentation/
    attendance_controller.dart
    attendance_screen.dart
    attendance_state.dart
```

Use server-driven pagination and filtering for announcements, assignments, and audit views. Define loading, empty, error, retry, and offline states for every screen. Add accessibility labels, localization support, date/time and academic-year formatting, and responsive layouts for phones, tablets, and the web if web deployment is retained.

## College-specific product requirements that should be clarified

Before implementing Phase 4, conduct short workshops with students, teachers, department heads, examination staff, and administrators. The following questions affect the schema and permissions more than the screen design:

| Decision area | Questions to settle with the college |
|---|---|
| Identity | What is the authoritative student/employee identifier? Can one person have multiple roles or accounts? |
| Academic structure | Which campuses, departments, programs, batches, semesters, sections, and electives must be represented? |
| Attendance | Is attendance per lecture, per day, or per subject? Who can correct it, and is approval required? |
| Marks | Which components exist: internals, university/SIM exams, projects, practicals, attendance marks? When are marks published or locked? |
| Communication | Are announcements institution-wide, department-wide, section-specific, subject-specific, or individual? |
| Files | What file types and size limits are allowed? How long should notes and submissions be retained? |
| Administration | Who imports master data, who approves changes, and how are inactive/transferred students handled? |
| Privacy | Which staff may see marks, attendance history, contact data, and audit logs? What is the retention/deletion policy? |
| Reliability | What is the acceptable downtime during examination periods, and how will support handle incidents? |

A particularly important requirement is **data import**. Build CSV/Excel import with a preview, row-level validation errors, dry-run mode, duplicate detection, idempotency, rollback or quarantine, and an import audit report. Do not make administrators edit thousands of students and subjects manually through a basic CRUD screen.

## Recommended implementation order

### P0 — Before academic feature development

Freeze the data and authorization decisions with college stakeholders. Refactor authentication into services, add request validation and structured errors, finish refresh-token handling in Flutter, configure production OTP, establish secret management, set up monitoring and backups, and define a staging environment. Add CI checks for backend typecheck/tests, Flutter analyze/tests, dependency auditing, migration validation, and build artifacts.

### P1 — Academic Core pilot

Implement master data, enrollments, teaching assignments, timetable, announcements, and attendance. Start with one department or section as a pilot. Attendance should have a clear edit window and correction history. Release read-only student views only after teacher entry and administrator reconciliation are working.

### P2 — Assessments and learning

Implement assessment definitions, marks entry, approval/publication workflow, result visibility, assignments, submissions, notes, object storage, and notification jobs. Add audit and authorization tests for every state transition.

### P3 — Administration and production hardening

Implement imports, academic-year rollover, transfers and alumni/inactive states, support tools, reports, privacy workflows, backups/restore drills, incident response, app signing, staged rollout, crash reporting, and performance testing under examination-period load.

## Suggested acceptance criteria for a college pilot

The first pilot should not be declared successful merely because the app logs in. It should demonstrate that an administrator can import a real-but-sanitized dataset, assign teachers to sections and subjects, publish an announcement, create a class session, enter and correct attendance with audit history, and show each student only their own records. It should also demonstrate restore from backup, revocation of a lost device session, safe handling of expired OTPs, and recovery from an unavailable notification provider.

The pilot should use sanitized or limited-scope data until privacy, support, and recovery procedures have been approved. Collect feedback on network reliability, especially for classrooms with weak connectivity, and decide whether offline attendance capture is required. If offline support is needed, design conflict resolution and signed event synchronization before allowing offline writes to become authoritative.

## Final recommendation

Continue the project, but revise the architecture plan from “authentication foundation followed directly by screens” to **institutional master data → scoped authorization → academic workflows → audit/history → integrations → production operations**. Keep the current Flutter + Express + Drizzle + Turso direction for the pilot, provided the college accepts the database and operational limits of the selected hosting setup. Do not introduce microservices yet. The highest-value engineering work now is the domain model, import pipeline, resource-level authorization, academic record history, production operations, and testing—not additional dashboard decoration.

### References

[1]: https://owasp.org/www-project-application-security-verification-standard/ "OWASP Application Security Verification Standard"
[2]: https://www.meity.gov.in/static/uploads/2024/06/2bf1f0e9f04e6fb4f8fef35e82c42aa5.pdf "Digital Personal Data Protection Act, 2023 — Ministry of Electronics and Information Technology"
[3]: https://csrc.nist.gov/pubs/other/2020/04/24/protecting-data-from-ransomware-and-other-data-los/final "NIST: Protecting Data from Ransomware and Other Data Loss"
