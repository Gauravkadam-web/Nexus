# Nexus — API Verification Guide: Swagger UI & Postman Collection

> **Haan Gaurav Bhau!** Aap **Swagger UI** (Browser me directly) ya **Postman Collection** (Desktop app me) — **dono me se koi bhi use kar sakte ho** apni suvidha ke anusaar!

Dono options complete authentication, dynamic tokens, aur all 7 phases ke sare 40+ endpoints ko support karte hain.

---

## ⚡ Quick Start: Backend Run Kaise Karein?

Apne terminal me jaakar backend ko start karein:

```bash
cd /d/NEXUS/nexus-backend
mvn spring-boot:run
```

Jab console par `Started NexusApplication in X.XX seconds` message aa jaye, aapka backend `http://localhost:8080` par live ho jayega!

---

## 🌐 Option 1: Swagger UI (Browser me Direct Testing)

Swagger UI browser me visually sare endpoints ko explore aur test karne ka sabse fast tareeka hai.

### 1. Swagger UI Open Karein

**Live Cloud Production (Render):**
👉 **[https://nexus-h44p.onrender.com/swagger-ui/index.html](https://nexus-h44p.onrender.com/swagger-ui/index.html)**  
Raw OpenAPI JSON: **[https://nexus-h44p.onrender.com/v3/api-docs](https://nexus-h44p.onrender.com/v3/api-docs)**  
Live Health Check: **[https://nexus-h44p.onrender.com/api/v1/health](https://nexus-h44p.onrender.com/api/v1/health)**  

**Local Development:**
👉 **[http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)**  
Raw OpenAPI JSON: **[http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)**  


---

### 2. Swagger UI me JWT Token Kaise Set Karein?

1. Swagger UI me **`auth-controller`** section kholein.
2. **`POST /api/v1/auth/register`** ya **`POST /api/v1/auth/login`** par click karein.
3. **"Try it out"** par click karein aur Execute karein:
   ```json
   {
     "email": "gaurav.admin@nexus.io",
     "password": "Admin@123456"
   }
   ```
4. Response body se **`accessToken`** copy karein.
5. Page ke top-right corner me green **🔓 Authorize** button par click karein.
6. **Value** box me apna token paste karein (bina "Bearer " prefix ke).
7. **Authorize** button dabayein aur **Close** karein.
8. 🎉 **Done!** Ab aap baki sare protected endpoints (Case, AI, SLA, Analytics, Audit, etc.) par direct **"Try it out" ➔ "Execute"** kar sakte hain.

---

## 📮 Option 2: Postman Collection (Advanced Testing)

Humne project me complete pre-configured collection aur environment files generate kar di hain:
- 📁 Collection File: [`postman/nexus_postman_collection.json`](file:///d:/NEXUS/postman/nexus_postman_collection.json)
- 📁 Environment File: [`postman/nexus_environment.json`](file:///d:/NEXUS/postman/nexus_environment.json)

---

### 1. Postman me Import Kaise Karein?

1. **Postman Desktop App** kholein.
2. Top-left corner me **Import** button par click karein.
3. `d:\NEXUS\postman\` folder se dono files drag & drop karein:
   - `nexus_postman_collection.json`
   - `nexus_environment.json`
4. Top-right environment dropdown me **"Nexus Local Environment"** select karein.

---

### 2. Automatic Token Handling in Postman

Collection me automated test scripts configured hain:
- Jab bhi aap **`1. Authentication / Register User / Admin`** ya **`Login`** run karenge:
  - Token automatically extract hokar `{{accessToken}}` environment variable me save ho jayega!
  - Aapko manually token copy-paste karne ki zaroorat nahi hai.
  - Baki sare requests automatically `Bearer {{accessToken}}` header use karenge.

---

## 🔄 Recommended End-to-End Testing Flow

Agar aap pure system ka complete lifecycle verify karna chahte hain, to is order me run karein:

```
Step 1: Health Check (GET /api/v1/health)
   ⬇️
Step 2: Register / Login (POST /api/v1/auth/register) -> Auto saves {{accessToken}}
   ⬇️
Step 3: Create Category & Team (POST /api/v1/categories, POST /api/v1/teams)
   ⬇️
Step 4: Create Case (POST /api/v1/cases) -> Auto saves {{caseId}} (US-1)
   ⬇️
Step 5: Communication Flow (US-6, US-7, US-8):
        - Send Message (POST /api/v1/cases/{{caseId}}/messages)
        - Ask Question (Transitions status to WAITING_FOR_INFO)
        - Requester Answer (Transitions status to INVESTIGATING)
   ⬇️
Step 6: Investigation & Notes (US-9):
        - Add Private Note (POST /api/v1/cases/{{caseId}}/notes)
        - Add Structured Finding (POST /api/v1/cases/{{caseId}}/investigations)
   ⬇️
Step 7: AI Intelligence (US-11, 12, 13, 14, 29, 30):
        - Get AI Analysis (GET /api/v1/cases/{{caseId}}/ai/analysis)
        - Get AI Summary (GET /api/v1/cases/{{caseId}}/ai/summary)
        - Copilot Q&A (POST /api/v1/cases/{{caseId}}/ai/copilot)
        - Draft Communication (POST /api/v1/cases/{{caseId}}/ai/draft-communication)
   ⬇️
Step 8: Smart Operations & Relations (US-16 to US-20):
        - Duplicate Detection (GET /api/v1/cases/{{caseId}}/ai/duplicates)
        - Smart Assignment (GET /api/v1/cases/{{caseId}}/ai/assignment-recommendation)
   ⬇️
Step 9: SLA & Risk Monitoring (US-21 to US-25):
        - Check SLA Deadlines (GET /api/v1/cases/{{caseId}}/sla)
        - Check At-Risk Queues (GET /api/v1/sla/at-risk)
   ⬇️
Step 10: Resolution & Confirmation (US-26, US-27):
        - Submit Resolution (POST /api/v1/cases/{{caseId}}/resolution) -> RESOLUTION_PROPOSED
        - Confirm Resolution (PUT /api/v1/cases/{{caseId}}/resolution/confirm) -> CLOSED
   ⬇️
Step 11: Problem Management (US-28):
        - Create Problem Record (POST /api/v1/problems)
        - Link Incident (POST /api/v1/problems/{{problemId}}/incidents)
        - Detect Recurring Patterns (GET /api/v1/problems/recurring-patterns)
   ⬇️
Step 12: Manager Analytics & Audit Governance (US-31 to US-34):
        - Executive Overview KPIs (GET /api/v1/analytics/overview)
        - Volume Trends (GET /api/v1/analytics/trends?days=7)
        - Category Velocity (GET /api/v1/analytics/categories)
        - Team Workloads (GET /api/v1/analytics/teams)
        - Operational Insights (GET /api/v1/analytics/operational-insights)
        - Advanced Search (GET /api/v1/cases/search?query=VPN)
        - Case Audit Timeline (GET /api/v1/audit-logs/case/{{caseId}}/timeline)
```

---

## 🔒 Security Hardening & Rate Limiting Verification (US-35)

Bucket4j rate limiter active hai:
- `/api/v1/auth/login` par 1 minute me 11 consecutive requests bhejiye -> **HTTP 429 Too Many Requests** response with `Retry-After: 60` verify hoga.
- `/api/v1/health` aur `/swagger-ui/**` endpoints unthrottled rahenge.
