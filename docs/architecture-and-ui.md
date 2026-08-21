# Seshadripuram One — Phase 0 Implementation Notes

## Current implementation scope

The repository currently contains an authentication foundation with Flutter client routing, OTP activation, JWT access tokens, refresh sessions, secure token storage, and server-side role checks. Academic modules are still planned. The dashboards in this phase are responsive visual foundations using placeholder data; they do not claim to be connected to academic APIs yet.

## Target architecture

The first production direction is a modular monolith: one Express deployment and one database, separated internally into authentication, identity, authorization, academic master data, attendance, assessments, assignments, learning materials, announcements, notifications, administration, audit, and shared infrastructure modules. Each module should eventually separate HTTP controllers, validation/DTOs, use cases, repositories, policies, and database schema.

Microservices are intentionally deferred. The product needs stable academic workflows, data ownership, and operational evidence before independent service boundaries would provide value.

## UI design system

The visual direction is inspired by the public Seshadripuram College website: dark navy academic surfaces, gold achievement accents, white content cards, restrained red/orange status colors, circular S emblem treatment, and strong academic hierarchy. The app modernizes the identity with subtle glow, elevation, responsive cards, and purposeful motion. It should remain calm, accessible, and information-first rather than overly neon.

Primary tokens are centralized in `lib/core/theme/app_theme.dart`. Shared dashboard components are in `lib/core/widgets/dashboard_components.dart`. Breakpoints are compact below 760 px and expanded at or above 760 px. Compact layouts use bottom navigation; expanded layouts use a navigation rail and constrained content width.

## Phase 0 acceptance checklist

- Existing authentication behavior remains unchanged.
- Dashboard screens compile when Flutter SDK is available.
- Backend typecheck and tests remain passing.
- Placeholder dashboard data is clearly understood as presentation-only.
- No real college personal data or secrets are committed.
- The official logo should replace the temporary S mark after an approved asset is added.
