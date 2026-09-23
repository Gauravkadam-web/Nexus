# Nexus — Folder Structure
### *AI-Powered Case Management Platform*

> **Source:** Extracted from `Nexus_SRS.md` §5 (SRS v1.1)

---

## Backend (Spring Boot)

```
nexus-backend/
├── src/
│   ├── main/
│   │   ├── java/com/nexus/
│   │   │   ├── NexusApplication.java
│   │   │   ├── config/
│   │   │   │   ├── SecurityConfig.java
│   │   │   │   ├── JwtConfig.java
│   │   │   │   ├── AiProviderConfig.java
│   │   │   │   ├── EmailProviderConfig.java
│   │   │   │   ├── SchedulerConfig.java
│   │   │   │   └── RateLimitConfig.java
│   │   │   │
│   │   │   ├── common/
│   │   │   │   ├── exception/
│   │   │   │   │   ├── GlobalExceptionHandler.java
│   │   │   │   │   └── custom exceptions...
│   │   │   │   ├── response/
│   │   │   │   │   └── ApiResponse.java
│   │   │   │   └── util/
│   │   │   │
│   │   │   ├── auth/
│   │   │   │   ├── controller/AuthController.java
│   │   │   │   ├── service/AuthService.java
│   │   │   │   ├── dto/ (LoginRequest, RegisterRequest, TokenResponse...)
│   │   │   │   └── security/ (JwtFilter, JwtProvider)
│   │   │   │
│   │   │   ├── organization/
│   │   │   │   ├── controller/
│   │   │   │   ├── service/
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/ (Organization, Team, Category)
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── user/
│   │   │   │   ├── controller/AdminUserController.java
│   │   │   │   ├── service/UserService.java
│   │   │   │   ├── repository/UserRepository.java, RoleRepository.java
│   │   │   │   ├── entity/ (User, Role, UserRole, RoleType, UserStatus)
│   │   │   │   └── dto/ (UserDto, UpdateUserRoleRequest)
│   │   │   │
│   │   │   ├── casemanagement/
│   │   │   │   ├── controller/CaseController.java
│   │   │   │   ├── service/CaseService.java
│   │   │   │   ├── repository/CaseRepository.java
│   │   │   │   ├── entity/ (Case, CaseAttachment, CaseAssignment, CaseRelation)
│   │   │   │   ├── dto/
│   │   │   │   └── statemachine/ (CaseLifecycleService)
│   │   │   │
│   │   │   ├── collaboration/
│   │   │   │   ├── controller/ (MessageController, TaskController, NoteController)
│   │   │   │   ├── service/
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/ (CaseMessage, InternalNote, CaseTask, Investigation)
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── ai/
│   │   │   │   ├── config/AiConfig.java
│   │   │   │   ├── controller/AiController.java
│   │   │   │   ├── service/
│   │   │   │   │   ├── AiAnalysisService.java
│   │   │   │   │   ├── AiSummaryService.java
│   │   │   │   │   ├── AiDuplicateDetectionService.java
│   │   │   │   │   ├── AiAssignmentService.java
│   │   │   │   │   ├── AiCommunicationService.java
│   │   │   │   │   └── AiCopilotService.java
│   │   │   │   ├── provider/ (AIProviderPort + MockAiProvider, SpringAiChatProvider)
│   │   │   │   ├── entity/ (AiAnalysis, AiSuggestion, AiSummary)
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── sla/
│   │   │   │   ├── controller/
│   │   │   │   ├── service/ (SlaService, SlaSchedulerJob)
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/ (SlaPolicy, CaseSla, CaseRisk)
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── escalation/
│   │   │   │   ├── controller/
│   │   │   │   ├── service/
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/ (Escalation, EscalationRule)
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── notification/
│   │   │   │   ├── controller/NotificationController.java
│   │   │   │   ├── service/NotificationService.java
│   │   │   │   ├── provider/ (EmailProviderPort + BrevoEmailProvider, SmtpEmailProvider)
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/Notification.java
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── resolution/
│   │   │   │   ├── controller/
│   │   │   │   ├── service/
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/Resolution.java
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── problem/
│   │   │   │   ├── controller/
│   │   │   │   ├── service/
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/ (Problem, ProblemIncidentRelation)
│   │   │   │   └── dto/
│   │   │   │
│   │   │   ├── audit/
│   │   │   │   ├── service/AuditService.java
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/AuditLog.java
│   │   │   │   └── aspect/AuditAspect.java
│   │   │   │
│   │   │   ├── automation/
│   │   │   │   ├── entity/AutomationEvent.java
│   │   │   │   ├── repository/
│   │   │   │   └── service/AutomationEventService.java
│   │   │   │
│   │   │   └── analytics/
│   │   │       ├── controller/AnalyticsController.java
│   │   │       ├── service/AnalyticsService.java
│   │   │       └── dto/
│   │   │
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-local.yml
│   │       ├── application-prod.yml
│   │       └── db/migration/
│   │           ├── V1__init_org_user_role.sql
│   │           ├── V2__create_case_tables.sql
│   │           ├── V3__create_collaboration_tables.sql
│   │           ├── V4__create_ai_tables.sql
│   │           ├── V5__create_case_relations_tables.sql
│   │           ├── V6__create_sla_escalation_notifications_tables.sql
│   │           ├── V7__create_resolution_problems_tables.sql
│   │           └── V8__create_audit_logs_and_search_indexes.sql
│   │
│   └── test/
│       └── java/com/nexus/
│           ├── casemanagement/
│           ├── ai/
│           ├── sla/
│           └── ... (mirrors main package structure)
│
├── pom.xml
├── Dockerfile
├── .env.example
└── README.md
```

---

## Frontend (Flutter)

```
nexus-frontend/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── config/ (env config, API base URL)
│   │   ├── network/ (Dio client, interceptors, JWT refresh)
│   │   ├── theme/
│   │   ├── routing/ (go_router setup, route guards by role)
│   │   ├── widgets/ (shared components)
│   │   └── utils/
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/ (repository, api)
│   │   │   ├── domain/ (models)
│   │   │   └── presentation/ (screens, state/providers)
│   │   │
│   │   ├── case/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/ (case_list, case_detail, case_create screens)
│   │   │
│   │   ├── collaboration/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/ (messages, tasks, notes, investigations)
│   │   │
│   │   ├── ai/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/ (analysis_panel, copilot_chat)
│   │   │
│   │   ├── sla/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/ (sla_widgets, risk_badges)
│   │   │
│   │   ├── notification/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── dashboard/
│   │   │   ├── requester/
│   │   │   ├── operator/
│   │   │   ├── team_lead/
│   │   │   └── manager/
│   │   │
│   │   └── admin/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/ (users, teams, categories, sla_policies, escalation_rules)
│   │
│   └── l10n/ (optional)
│
├── test/
├── web/
├── android/
├── ios/
├── pubspec.yaml
├── .env.example
└── README.md
```
