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
| **Android ADB Reverse IPv6 DNS Connection Refusal** | Frontend / Android | Android physical devices resolve `localhost` to IPv6 `[::1]`, refusing ADB reverse tunnel connection. | Dynamic platform router in `AppConfig.dart` sets `http://127.0.0.1:8080/api/v1/` on Android | ✅ Resolved |
| **Mobile Layout Squeeze from Fixed Desktop Sidebar** | Frontend / Layout | AppShell rendered fixed 256px sidebar in horizontal Row on all viewports, crushing 360px mobile viewports. | Gated sidebar to `width >= 1100px`, switched mobile to slide-out Drawer + BottomNav | ✅ Resolved |
| **Backend Production Multi-Stage Dockerfile for Render** | Backend / Infra | Render native Java environment could suffer build timeouts or version mismatch on Spring Boot 3.3.4 (Java 21). | Created multi-stage `Dockerfile` (`maven:3.9-eclipse-temurin-21` -> `eclipse-temurin:21-jre-alpine`) with unprivileged user and memory limits + `render.yaml` Blueprint | ✅ Resolved |
| **Supabase Cloud Storage Integration with Graceful Fallback** | Backend / Storage | `LocalStorageService` saved files to ephemeral container disk on Render. | Created `SupabaseStorageService.java` with REST API multipart upload to Supabase bucket and automatic fallback to local disk; verified with 3 unit tests | ✅ Resolved |
| **Vercel Flutter Web SPA Routing & Deep Link 404 Prevention** | Frontend / Infra | Direct navigation or refresh on deep URLs (`/dashboard/manager`, `/cases/:id/track`) failed with 404 on Vercel. | Added `vercel.json` with SPA rewrite rules (`/(.*)` -> `/index.html`), caching headers, and `vercel-build.sh` build script | ✅ Resolved |
| **Render Cloud Datasource Configuration (`application.yml`)** | Backend / Infra | `application-prod.yml` was git-ignored, causing Render to miss DB credentials. | Added environment-driven `spring.datasource` configuration with fallback aliases (`SUPABASE_DB_URL`, `SPRING_DATASOURCE_URL`, `DATABASE_URL`) to tracked `application.yml` | ✅ Resolved |
| **Supabase Pooler IPv4 Connection Compatibility** | Cloud Database / Network | Direct connection (`db.<ref>.supabase.co:5432`) is IPv6-only on modern Supabase tiers; Render containers operate on IPv4. | Connected via Supabase Session Pooler (`aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?sslmode=require`) with IPv4 routing | ✅ Resolved |
| **CORS Allowed Origins & Preflight Alignment** | Security / Web | Origin headers must not contain paths/fragments (`/#/...`); wildcards needed for local dev alongside Vercel production. | Configured `CORS_ALLOWED_ORIGINS=https://nexus-weld-two.vercel.app,http://localhost:*,http://127.0.0.1:*` in Render environment | ✅ Resolved |
| **Mobile Multi-Role Dynamic Data & Overflow Hardening** | Frontend / Mobile | Audit all 5 persona roles (Operator, Requester, Team Lead, Manager, Admin) on 360px mobile viewport, ensuring universal `ApiResponse.extractList` page parsing, flexible badge rows with zero RenderFlex overflow, and unified final APK release. | Next Session Multi-Role Consolidated Sprint | 📋 Tracked & Ready for Next Session |




---

## 📱 Mobile Multi-Role Audit & Consolidation Plan (Next Session Action Matrix)

| Role | Target Screens | Dynamic Data Endpoints | Mobile Layout Hardening Scope (360px Viewport) |
|---|---|---|---|
| **Operator** | `OperatorTriageFeedScreen`<br>`OperatorInvestigationStudioScreen`<br>`SlaRiskRadarConsoleScreen` | `/api/v1/cases/assigned`<br>`/api/v1/cases/team`<br>`/api/v1/cases/{id}`<br>`/api/v1/cases/{id}/tasks`<br>`/api/v1/sla/at-risk` | • Flexible card header with short `NEX-XXXXXX` IDs<br>• Stacked action buttons (`Reassign`, `Open Studio`)<br>• Activity stream & tab bar alignment<br>• Studio workbench full-width composer |
| **Requester** | `RequesterDashboardScreen`<br>`CaseCreateWizardScreen`<br>`CaseTrackerScreen` | `/api/v1/cases/my`<br>`/api/v1/categories`<br>`/api/v1/cases/{id}/timeline` | • KPI cards adaptive aspect ratio (`1.15`)<br>• Case creation form stacked dropdowns<br>• Interactive timeline step nodes vertical alignment |
| **Team Lead** | `TeamLeadCommandScreen` | `/api/v1/cases/team`<br>`/api/v1/collaboration/workload/team` | • Member workload cards responsive grid<br>• Team case assignment dialog full-screen modal on mobile |
| **Manager / Exec** | `ExecutiveAnalyticsScreen`<br>`ProblemManagementScreen` | `/api/v1/analytics/overview`<br>`/api/v1/analytics/trends`<br>`/api/v1/problems` | • Chart containers scrollable / simplified mobile card view<br>• Recurring problem pattern cards wrapping |
| **Admin** | `AdminUserManagementScreen`<br>`AdminSettingsScreen` | `/api/v1/admin/users`<br>`/api/v1/admin/sla-policies`<br>`/api/v1/admin/escalation-rules` | • User table converted to responsive list tile cards on mobile<br>• Role dropdown & action sheet |

---

## 🛡️ Architectural Boundaries & Compliance Checks

- **Zero Hardcoded Secrets**: All DB credentials, JWT secrets, and API keys are strictly loaded via environment variables (`application.yml` / `application-local.yml` / `application-prod.yml`).
- **Idempotency & Auditing**: No hard deletion on business entities; append-only design principles maintained.
- **Strict Role-Based Access Control**: Method-level security (`@PreAuthorize`) configured on all sensitive endpoints (`/api/v1/cases/assigned`, `/api/v1/cases/team`, `/api/v1/cases/{id}/notes`, `/api/v1/collaboration/workload/team`, `/api/v1/admin/**`, `/api/v1/audit-logs/**`, `/api/v1/analytics/**`).
- **Decoupled AI & Email Ports**: Core case management functions independently of AI/email provider availability (graceful degradation).
- **Immutable State Machine**: All lifecycle status transitions strictly validated via `CaseLifecycleService`.
- **Frontend Design System Consistency**: All screens adhere strictly to Warm Mineral & Slate Navy tokens, shared `NexusButton` / `StatusBadge` / `ResponsiveLayout` components, and standard typography hierarchies.
