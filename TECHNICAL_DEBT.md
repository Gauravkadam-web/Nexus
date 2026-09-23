# Nexus — Technical Debt & Architectural Watchlist

> **Last Updated:** 2026-09-23  
> **Status:** Healthy & Zero Unresolved Blockers (Full-Stack Backend + Frontend Complete)

This document tracks intentional trade-offs, temporary scaffolding defaults, and architectural considerations to keep Nexus maintainable, performant, and compliant with PRD & SRS standards.

---

## 🟢 Open Items & Architectural Status

| Item | Scope / Domain | Description | Action / Target Phase | Status |
|---|---|---|---|---|
| **Spring Data Page Serialization Warning** | Spring Boot / Web | In Spring Boot 3.3, serializing `PageImpl` directly emits a minor stability warning. | Configured `@EnableSpringDataWebSupport(pageSerializationMode = VIA_DTO)` in `WebMvcConfig.java` | ✅ Resolved in Phase 2 |
| **Case Attachments & Storage Service** | Storage / Evidence | File uploads track metadata in `case_attachments`; pluggable `StorageService` interface implemented with local file handling & Supabase readiness. | `V3__create_collaboration_tables.sql` & `AttachmentService` | ✅ Resolved in Phase 2 |
| **Audit Logging Engine** | Audit Domain | Immutable, append-only audit trail with `REQUIRES_NEW` transaction boundary and entity timeline extraction. | `V8__create_audit_logs_and_search_indexes.sql` & `AuditService` | ✅ Resolved in Phase 7 |
| **Rate Limiting Configuration** | Security / Bucket4j | Token bucket rate limiting (10 req/min for auth, 100 req/min for general API) with 429 payload and health endpoint bypass. | `RateLimitingFilter.java` & `SecurityConfig.java` | ✅ Resolved in Phase 7 |
| **PostgreSQL 18+ JSONB Mapping** | Hibernate 6 / JPA | PostgreSQL requires explicit JSON type casting for string-mapped JSONB columns. | Added `@JdbcTypeCode(SqlTypes.JSON)` to `AiAnalysis`, `AiSuggestion`, `AutomationEvent` | ✅ Resolved in Live E2E Testing |
| **Case Assignment HTTP Method Parity** | REST Controllers | Support both `POST` and `PATCH` methods on `/api/v1/cases/{id}/assign` for frontend flexibility. | Updated `@RequestMapping(method = {RequestMethod.POST, RequestMethod.PATCH})` in `CaseController` | ✅ Resolved in Live E2E Testing |
| **Java 25 Mockito Byte Buddy Warning** | Maven / Testing | Java 21+ / Java 25 early access prints warning on dynamic agent loading. | Configured `-XX:+EnableDynamicAgentLoading` in `maven-surefire-plugin` `pom.xml` | ✅ Resolved |
| **Frontend Screen Parity & Routing** | Flutter Client | Complete all 18 Stitch design system screens across 9 Batches with GoRouter routes and live phone verification hub. | Batches 1–9 implemented and routed in `app_router.dart` | ✅ Resolved in Frontend Milestone |
| **Flutter Web Enterprise AppShell Integration** | Flutter Web | Wrap all 18 screens in unified desktop workstation layout (256px Left Sidebar + 64px Command Header) and remove legacy mobile AppBars. | Implemented `AppShell`, `NexusDataTable`, and `KpiCard` across all screens | ✅ Resolved in Web Parity Sprint |
| **Riverpod GoRouter Recreation on State Change** | Flutter / Auth | Router was being recreated on text field input/auth changes causing screen freezes on submit. | Decoupled `appRouterProvider` from direct state watches | ✅ Resolved |
| **CORS & Rate Limiting Preflight Handling** | Backend / Security | Preflight `OPTIONS` requests from web client (`http://localhost:3000`) were being intercepted by rate limiter. | Added preflight bypass in `RateLimitingFilter.java` & origin configuration | ✅ Resolved |
| **Supabase Remote Database Latency Resilience** | Frontend / Network | Cloud Postgres cold-start latency caused intermittent 10s request aborts on web client. | Increased Dio connection and receive timeouts to 30,000ms | ✅ Resolved |
| **Frontend Static Analysis Cleanliness** | Flutter / Code Quality | `dart analyze` reported 10 unused elements and enum casing warnings. | Cleaned up unused fields, wired actions, and fixed imports (`No issues found!`) | ✅ Resolved |
| **Frontend Widget Test Suite & Overflow Resilience** | Flutter / Testing | Small viewport / test runner layout constraints caused RenderFlex overflows on login and dashboard cards. | Added responsive `Wrap` containers, scroll wrappers, and expanded 5-suite interactive widget test | ✅ Resolved (5/5 Passed) |
| **Demo Environment Seed Data & Real Full-Stack Binding** | Database / Frontend | Demo data migration (`V100__seed_demo_data.sql`) populated with 5 real personas, realistic case backlogs, SLA policies, and 100% full-stack binding across all 18 screens with 0 mock data. | Complete in `V100__seed_demo_data.sql` and `nexus-frontend` Riverpod providers | ✅ Resolved |
| **Demo Persona Password BCrypt Hash Discrepancy** | Auth / Flyway | Initial V100 migration contained placeholder hash that caused 401 Bad Credentials with `Password123!`. | Applied `V101__update_demo_user_passwords.sql` with verified BCrypt hash `$2a$10$13V.tJPu8a5ZwWzNv7eiGeLldiP5.nsWqmzpjv/MGPiYP4Ixxh.zW` | ✅ Resolved in V101 |
| **Role-Based AppShell Navigation Enforcement (Option 2)** | Frontend / UX | Hardcoded sidebar nav items and role simulation footer conflicted with pure production RBAC. | Replaced with `_buildRoleSpecificNavItems` and clean user session footer in `AppShell.dart` | ✅ Resolved (Option 2) |
| **Admin User Management API Implementation** | Backend / Governance | Frontend requested `GET /api/v1/admin/users` and role updates, but controller was missing. | Implemented `AdminUserController.java` and `UserService.java` with `@PreAuthorize` security | ✅ Resolved |
| **AppShell Navigation Tap Unhandled Exception** | Frontend / UX | `Scaffold.of(context)` called without ancestor Scaffold threw Flutter runtime error, swallowing tab tap events. | Replaced with `Scaffold.maybeOf(context)` in `_buildNavItem`, unblocking tab routing | ✅ Resolved |
| **Demo Quick-Login Asynchronous Race Condition** | Frontend / Auth | `loginAsDemoRole` called synchronously without `await`, causing GoRouter to navigate before user role was set. | Converted `_handleDemoRoleLogin` to `async` and awaited auth before navigation | ✅ Resolved |
| **Resilient AI Provider Boot Fallback** | Backend / AI | When `AI_PROVIDER` is set without valid API keys, Spring Boot failed to instantiate chat model beans. | Configured `AiConfig.java` with `@ConditionalOnMissingBean` to auto-fallback to `MockAiProvider` | ✅ Resolved |
| **Executive Analytics Telemetry Key Harmonization** | Frontend / Analytics | Discrepancy between backend response keys and `analytics_models.dart` fallback strings. | Updated Dart deserialization keys to match backend telemetry API | ✅ Resolved |

---

## 🛡️ Architectural Boundaries & Compliance Checks

- **Zero Hardcoded Secrets**: All DB credentials, JWT secrets, and API keys are strictly loaded via environment variables (`application.yml` / `application-local.yml` / `application-prod.yml`).
- **Idempotency & Auditing**: No hard deletion on business entities; append-only design principles maintained.
- **Strict Role-Based Access Control**: Method-level security (`@PreAuthorize`) configured on all sensitive endpoints (`/api/v1/cases/assigned`, `/api/v1/cases/team`, `/api/v1/cases/{id}/notes`, `/api/v1/collaboration/workload/team`, `/api/v1/admin/**`, `/api/v1/audit-logs/**`, `/api/v1/analytics/**`).
- **Decoupled AI & Email Ports**: Core case management functions independently of AI/email provider availability (graceful degradation).
- **Immutable State Machine**: All lifecycle status transitions strictly validated via `CaseLifecycleService`.
- **Frontend Design System Consistency**: All screens adhere strictly to Warm Mineral & Slate Navy tokens, shared `NexusButton` / `StatusBadge` / `ResponsiveLayout` components, and standard typography hierarchies.
