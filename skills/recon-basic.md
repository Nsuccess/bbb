# Basic Reconnaissance Skill

## Role
Systematic reconnaissance specialist that maps attack surface, enumerates endpoints, extracts parameters, and identifies entry points for vulnerability testing.

## Purpose
Provide structured reconnaissance output that feeds directly into PoC generation. Focus on actionable intelligence: endpoints, parameters, authentication flows, and potential vulnerability classes.

## Modes

This skill operates in different modes based on target type:
- **API Mode**: Focus on endpoint enumeration, parameter extraction
- **Web Mode**: Focus on JavaScript analysis, subdomain discovery, hidden assets
- **Mobile Mode**: Focus on APK decompilation, API extraction from code
- **Generic Mode**: Comprehensive recon when target type unclear

---

## API Mode

### Phase 1: Endpoint Discovery

**Methods:**
1. **Direct Enumeration**
   - Browse to `/api/`, `/graphql`, `/v1/`, `/v2/`
   - Check for API documentation: `/docs`, `/swagger`, `/openapi.json`, `/redoc`
   - Test common patterns: `/api/users`, `/api/auth`, `/api/admin`

2. **JavaScript Analysis**
   - Download all JS files
   - Extract API calls: `fetch()`, `axios()`, `$.ajax()`
   - Extract endpoints from strings: `/api/.*`
   - Look for commented-out endpoints

3. **Wayback Machine**
   - Query: `http://web.archive.org/cdx/search/cdx?url=*.target.com/api/*`
   - Find old/forgotten endpoints

**Output Format:**
```
Endpoints Found:
- GET /api/users
- POST /api/users
- GET /api/users/{id}
- PUT /api/users/{id}
- DELETE /api/users/{id}
- POST /api/auth/login
- POST /api/auth/register
- GET /api/admin/stats
```

### Phase 2: Parameter Extraction

**For Each Endpoint:**
1. **Query Parameters**
   - Test with common params: `id`, `user_id`, `page`, `limit`, `sort`
   - Check API docs for parameter list
   - Fuzz for hidden parameters (Arjun, Param Miner)

2. **Body Parameters**
   - Capture legitimate requests
   - Extract JSON/XML schema
   - Note required vs optional fields

3. **Headers**
   - Authentication: `Authorization`, `X-API-Key`, `Cookie`
   - Custom headers: `X-User-Id`, `X-Role`, etc.

**Output Format:**
```
GET /api/users/{id}
  Path: id (integer)
  Query: ?include=profile,settings
  Headers: Authorization: Bearer <token>

POST /api/users
  Body: {
    "username": "string",
    "email": "string",
    "password": "string",
    "role": "string" (optional)
  }
  Headers: Content-Type: application/json
```

### Phase 3: Authentication Analysis

**Map Auth Flow:**
1. **Registration**
   - Endpoint: POST /api/auth/register
   - Required fields
   - Validation rules

2. **Login**
   - Endpoint: POST /api/auth/login
   - Credentials: username/email + password
   - Response: token, session cookie, etc.

3. **Token Format**
   - JWT? Decode and analyze claims
   - Opaque token? Test for predictability
   - Session cookie? Check flags (HttpOnly, Secure, SameSite)

4. **Authorization**
   - Role-based? (admin, user, guest)
   - Resource-based? (owner checks)
   - How is it enforced? (token claims, database lookup)

**Output Format:**
```
Authentication:
- Type: JWT (Bearer token)
- Claims: {"user_id": 123, "role": "user", "exp": 1234567890}
- Issued by: POST /api/auth/login
- Used in: Authorization: Bearer <token>

Authorization:
- Role-based: "admin", "user"
- Enforced via: JWT "role" claim
- Admin endpoints: /api/admin/*
```

### Phase 4: Hypothesis Generation

**Based on findings, suggest vulnerability tests:**

```
High-Priority Hypotheses:
1. IDOR on GET /api/users/{id}
   - Test: Change {id} to other user's ID
   - Expected: 403 Forbidden
   - Vulnerable: 200 OK with other user's data

2. Mass Assignment on POST /api/users
   - Test: Add "role": "admin" to registration
   - Expected: Role ignored or rejected
   - Vulnerable: User created with admin role

3. Missing Authentication on GET /api/admin/stats
   - Test: Request without Authorization header
   - Expected: 401 Unauthorized
   - Vulnerable: 200 OK with admin data

4. SQL Injection on GET /api/users?sort=username
   - Test: ?sort=username' OR '1'='1
   - Expected: 400 Bad Request or safe handling
   - Vulnerable: 500 Error or unexpected behavior
```

---

## Web Mode

### Phase 1: Subdomain Discovery

**Methods:**
1. **Yandex Dorking** (superior for subdomains)
   ```
   rhost:com.target.a*
   rhost:com.target.b*
   ... (iterate through alphabet)
   ```

2. **Certificate Transparency**
   - crt.sh: `%.target.com`
   - Censys, Shodan

3. **DNS Brute-Force**
   - subfinder, amass, assetfinder

**Output Format:**
```
Subdomains Found:
- api.target.com
- staging.target.com
- dev.target.com
- admin.target.com
- mail.target.com
```

### Phase 2: JavaScript Analysis

**Extract Intelligence:**
1. **Download All JS Files**
   ```bash
   # Find JS files
   site:target.com filetype:js
   site:target.com _next/static
   site:target.com chunk.js
   ```

2. **Extract Endpoints**
   ```bash
   grep -roh "https://[^\"']*" js_files/ | sort -u
   grep -roh "/api/[^\"']*" js_files/ | sort -u
   ```

3. **Extract Secrets** (potential)
   ```bash
   grep -ri "api_key\|apikey\|secret\|token\|password" js_files/
   ```

4. **Extract Logic**
   - Authentication checks
   - Authorization logic
   - Validation rules
   - Hidden features

**Output Format:**
```
JavaScript Intelligence:
- API Endpoints: /api/users, /api/auth, /api/admin
- Potential Secrets: API_KEY=abc123 (in main.js:1234)
- Auth Logic: Checks localStorage.getItem('token')
- Hidden Feature: Admin panel at /admin (commented out)
```

### Phase 3: Hidden Assets

**Yandex Dorking:**
```
site:target.com /admin
site:target.com /backup
site:target.com /config
site:target.com staging
site:target.com dev
site:target.com "Index of /"
```

**Output Format:**
```
Hidden Assets:
- https://target.com/admin (403 Forbidden - exists!)
- https://staging.target.com (200 OK - weak auth?)
- https://target.com/backup/db.sql (open directory!)
```

### Phase 4: Hypothesis Generation

```
High-Priority Hypotheses:
1. XSS in search parameter
   - Endpoint: GET /?search=<query>
   - Test: ?search=<script>alert(1)</script>
   - Check: Reflected in HTML? Encoded? CSP?

2. CSRF on state-changing actions
   - Endpoint: POST /api/user/update
   - Test: Cross-origin request without CSRF token
   - Check: Origin/Referer validation? SameSite cookie?

3. Authentication bypass on /admin
   - Endpoint: GET /admin
   - Test: Various bypass techniques
   - Check: IP whitelist? Weak auth? Path traversal?
```

---

## Mobile Mode

### Phase 1: APK Decompilation

**Extract APK:**
```bash
# Decompile APK
apktool d app.apk -o app_decompiled

# Extract strings
strings app.apk > strings.txt

# Decompile to Java (if needed)
jadx app.apk -d app_java
```

### Phase 2: API Extraction

**Find API Endpoints:**
```bash
# Search for URLs
grep -r "https://" app_decompiled/
grep -r "http://" app_decompiled/

# Search for API patterns
grep -r "/api/" app_decompiled/
grep -r "graphql" app_decompiled/

# Search for secrets
grep -ri "api_key\|apikey\|secret\|token" app_decompiled/
```

**Output Format:**
```
API Endpoints (from APK):
- https://api.target.com/v1/users
- https://api.target.com/v1/auth/login
- https://api.target.com/v1/admin/stats

Potential Secrets:
- API_KEY: abc123xyz (in strings.xml)
- BASE_URL: https://staging-api.target.com (debug build?)
```

### Phase 3: Deep Link Analysis

**Find Deep Links:**
```xml
<!-- AndroidManifest.xml -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <data android:scheme="myapp" android:host="open" />
</intent-filter>
```

**Test Deep Links:**
```
myapp://open?url=https://attacker.com
myapp://admin?token=<token>
```

### Phase 4: Hypothesis Generation

```
High-Priority Hypotheses:
1. Insecure API endpoint (from APK)
   - Endpoint: https://staging-api.target.com
   - Test: Access staging API from production app
   - Check: Different security controls?

2. Hardcoded API key
   - Key: abc123xyz (found in strings.xml)
   - Test: Use key to access API directly
   - Check: Key valid? Rotated? Scoped?

3. Deep link injection
   - Link: myapp://open?url=<url>
   - Test: myapp://open?url=javascript:alert(1)
   - Check: URL validation? Sanitization?
```

---

## Generic Mode

**When target type is unclear, run comprehensive recon:**

1. **Identify Target Type**
   - Check for `/api/` paths → API
   - Check for OAuth flows → OAuth/Auth
   - Check for chat interface → AI/LLM
   - Check for `.sol` files → Crypto/DeFi

2. **Run Basic Checks**
   - Subdomain enumeration
   - JavaScript analysis
   - Wayback Machine
   - Common path fuzzing

3. **Ask User for Clarification**
   - "Detected API endpoints. Is this an API target?"
   - "Found OAuth flow. Should I focus on OAuth security?"

---

## Output Template

**Structured output for PoC generator:**

```markdown
# Reconnaissance Report: target.com

## Target Type: [API / Web / Mobile / Unknown]

## Endpoints Discovered:
- GET /api/users
- POST /api/users
- GET /api/users/{id}
- ...

## Parameters Extracted:
- /api/users/{id}: id (integer, path parameter)
- /api/users: username, email, password, role (body parameters)
- ...

## Authentication:
- Type: JWT (Bearer token)
- Obtained via: POST /api/auth/login
- Claims: user_id, role, exp
- ...

## Authorization:
- Role-based: admin, user
- Enforced via: JWT claims
- Admin endpoints: /api/admin/*
- ...

## High-Priority Hypotheses:
1. IDOR on GET /api/users/{id}
2. Mass Assignment on POST /api/users
3. Missing Auth on GET /api/admin/stats
4. SQL Injection on GET /api/users?sort=<param>

## Next Steps:
- Load poc-generator.md
- Select hypothesis to test
- Generate PoC command
- Run and validate
```

---

## Tools Used

- **Subdomain Enum**: subfinder, amass, Yandex dorking
- **JS Analysis**: grep, custom scripts
- **API Discovery**: Burp Suite, browser DevTools
- **Mobile**: apktool, jadx, strings
- **Wayback**: web.archive.org CDX API

---

## Key Principles

1. **Actionable Output**: Every finding should lead to a testable hypothesis
2. **Structured Format**: Output feeds directly into poc-generator
3. **No Assumptions**: Document what you found, not what you think
4. **Prioritize**: Rank hypotheses by likelihood and impact
5. **Minimal Noise**: Focus on high-signal intelligence

---

## References
- Entry #004: Yandex Dork Recon Loop
- Entry #013: Advanced Yandex Search Guide
- Entry #022: Bug Bounty Methodology 2026
