
# Nexus — Environment Configuration & Deployment
### *AI-Powered Case Management Platform*

> **Source:** Extracted from `Nexus_SRS.md` §10 & §11 (SRS v1.1)

---

## 10. Environment Configuration

All secrets and provider selection are environment-driven — never hardcoded.

**Backend `.env` (example keys):**
```
SPRING_PROFILES_ACTIVE=local|prod

# Database
SUPABASE_DB_URL=
SUPABASE_DB_USERNAME=
SUPABASE_DB_PASSWORD=

# Storage
SUPABASE_STORAGE_URL=
SUPABASE_STORAGE_KEY=
SUPABASE_STORAGE_BUCKET=

# Auth
JWT_SECRET=
JWT_ACCESS_EXPIRY_MINUTES=
JWT_REFRESH_EXPIRY_DAYS=

# AI Provider (Spring AI)
AI_PROVIDER=openai|anthropic|gemini
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GEMINI_API_KEY=

# Email Provider
EMAIL_PROVIDER=brevo|smtp
BREVO_API_KEY=
BREVO_SENDER_EMAIL=
SMTP_HOST=
SMTP_PORT=
SMTP_USERNAME=
SMTP_PASSWORD=

# Monitoring
SENTRY_DSN=
```

**Frontend `.env` (example keys):**
```
API_BASE_URL=
ENVIRONMENT=local|production
```

---

## 11. Deployment

### Live Cloud Production Endpoints

| Component | Provider | Live Production URL | Notes |
|---|---|---|---|
| **Backend API** | Render | `https://nexus-h44p.onrender.com` | Spring Boot 3.3.4 (Java 21) multi-stage container |
| **Operational Health** | Render | `https://nexus-h44p.onrender.com/api/v1/health` | Public 200 OK health probe (`{"status":"UP"}`) |
| **Interactive API Docs** | Render | `https://nexus-h44p.onrender.com/swagger-ui/index.html` | OpenAPI 3.0 / Swagger UI with Bearer JWT support |
| **Frontend Web Portal** | Vercel | `https://nexus-weld-two.vercel.app` | Flutter Web SPA with GoRouter deep linking |
| **Cloud Database** | Supabase | Port 5432 Session Pooler | PostgreSQL with Flyway V1–V8, V100, V101 |
| **Cloud File Storage** | Supabase | Bucket: `nexus-attachments` | REST multipart upload with local disk fallback |

---

### Infrastructure & Deployment Matrix

| Concern | Approach | Configuration / File |
|---|---|---|
| **Backend Hosting** | Render Web Service via Docker | [`nexus-backend/Dockerfile`](file:///D:/NEXUS/nexus-backend/Dockerfile) (`maven:3.9.9-eclipse-temurin-21-alpine` ➔ `eclipse-temurin:21-jre-alpine`), unprivileged user `nexususer`, `-XX:MaxRAMPercentage=75.0` |
| **Render Blueprint** | Declarative service spec | [`render.yaml`](file:///D:/NEXUS/render.yaml) mapping port 10000, health check `/api/v1/health` |
| **Frontend Hosting** | Vercel (Flutter Web) | [`nexus-frontend/vercel.json`](file:///D:/NEXUS/nexus-frontend/vercel.json) (SPA rewrite `/(.*)` ➔ `/index.html`, security headers, static caching) |
| **Vercel Build Hook** | Automated Flutter build script | [`nexus-frontend/vercel-build.sh`](file:///D:/NEXUS/nexus-frontend/vercel-build.sh) (installs Flutter stable, compiles `flutter build web --release`, injects `API_BASE_URL`) |
| **Database Pooler** | Supabase PostgreSQL via Pooler | Connect via `aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?sslmode=require` (IPv4 compatible with Render free tier) |
| **Cloud Storage** | Supabase Storage REST API | `SupabaseStorageService.java` uploading to `nexus-attachments` public bucket with graceful local fallback |
| **CORS Governance** | Backend Spring Security | `CORS_ALLOWED_ORIGINS=https://nexus-weld-two.vercel.app,http://localhost:*,http://127.0.0.1:*` |
| **Secrets & Keys** | Environment-Driven Only | Configured directly in Render & Vercel environment variable settings — never committed to Git |
| **CI/CD Pipeline** | Git-triggered deployment | Render & Vercel auto-deploy on push to `main` |
| **Local Development** | Docker Compose / Local JVM | Local Spring Boot on `8080`, Flutter Web on `3000`, Android via dynamic IPv4 tunnel (`127.0.0.1:8080`), `AI_PROVIDER=mock` |

