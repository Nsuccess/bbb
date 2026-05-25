# Adaptive Security Hunt

**Target Type:** Unknown or complex targets requiring multiple techniques

**Skills Used:** ALL available skills in sequence

**Expected Time:** 4-6 hours per target

**Philosophy:** Try everything systematically, pivot when stuck, validate rigorously

---

## Overview

This workflow is for:
- ✅ Unknown target types
- ✅ Targets that don't fit other workflows
- ✅ Comprehensive security assessment
- ✅ When other workflows found nothing

**Approach:** Sequential testing with intelligent pivoting

---

## Phase 1: Reconnaissance (45-60 min)

### Step 1.1: Yandex Dorking
**Activate:** `yandex-recon-specialist.md`

**Actions:**
```bash
# Run complete Yandex recon
./yadexloop.sh target.com

# Outputs:
# - api.txt
# - javascript.txt
# - auth_admin.txt
# - environments.txt
# - files.txt
# - documents.txt
# - cloud.txt
```

### Step 1.2: Subdomain Enumeration
```bash
# Letter-by-letter brute-force
for letter in {a..z} {0..9}; do
  # Yandex: rhost:com.target.${letter}*
done
```

### Step 1.3: Technology Stack Identification
**Identify:**
- [ ] Framework (Next.js, React, Vue, etc.)
- [ ] Backend (Node.js, Python, Java, etc.)
- [ ] Database (PostgreSQL, MongoDB, etc.)
- [ ] Cloud provider (AWS, GCP, Azure)
- [ ] CDN (Cloudflare, Fastly, etc.)

### Step 1.4: Attack Surface Mapping
**Document:**
- All discovered endpoints
- All subdomains
- All JavaScript files
- All API endpoints
- All authentication methods
- All file uploads
- All user inputs

---

## Phase 2: Try High-Value Techniques First (90-120 min)

### Technique 1: OAuth Security (if OAuth present)
**Activate:** `oauth-security-auditor.md`

**Quick tests:**
- [ ] Popup hijacking
- [ ] redirect_uri bypass
- [ ] Token theft
- [ ] Non-happy path

**Time limit:** 30 min
**If nothing found:** Move to next technique

### Technique 2: Prompt Injection (if AI features)
**Activate:** `prompt-injection-hunter.md`

**Quick tests:**
- [ ] System prompt extraction
- [ ] Action triggering
- [ ] Data exfiltration
- [ ] Injection point mapping

**Time limit:** 30 min
**If nothing found:** Move to next technique

### Technique 3: API Security
**Activate:** `recon-basic.md` + manual testing

**Quick tests:**
- [ ] IDOR
- [ ] Mass assignment
- [ ] SQL/NoSQL injection
- [ ] GraphQL introspection

**Time limit:** 30 min
**If nothing found:** Move to next technique

---

## Phase 3: Parser Differentials (30-45 min)

**Activate:** `parser-differential-tester.md`

### Test 3.1: Query String Confusion
```
?admin=false&admin=true
?param=value%26injected=malicious
```

### Test 3.2: URL Parser Confusion
```
https://target.com@attacker.com/
https://target.com\@attacker.com
```

### Test 3.3: Content-Type Confusion
```
Upload PHP as image/jpeg
Send JSON as form data
```

### Test 3.4: Encoding Differentials
```
%252F (double encoding)
file.php%00.jpg (null byte)
```

**Time limit:** 30-45 min
**If nothing found:** Move to next technique

---

## Phase 4: Less Common Techniques (60-90 min)

### Technique 4: Bucket Squatting (if cloud assets)
**Activate:** `bucket-squatting-detector.md`

**Tests:**
- [ ] Predictable bucket names
- [ ] Bucket ownership verification
- [ ] Provisioning behavior mapping

**Time limit:** 30 min

### Technique 5: Enterprise Software (if .NET/Windows)
**Activate:** `enterprise-software-auditor.md`

**Tests:**
- [ ] ILSpy decompilation
- [ ] SAML token manipulation
- [ ] NTLM relay
- [ ] LPE

**Time limit:** 30 min

### Technique 6: MCP Security (if MCP server)
**Activate:** `mcp-security-auditor.md`

**Tests:**
- [ ] Open DCR
- [ ] JavaScript protocol injection
- [ ] XSS via consent screen
- [ ] Direct server access

**Time limit:** 30 min

---

## Phase 5: Deep Dive on Promising Leads (60-90 min)

**If any technique showed promise:**
- Deep dive with full workflow
- Example: Found OAuth → Run complete `01-web-app-hunt.md`
- Example: Found API → Run complete `02-api-security-hunt.md`

**If nothing promising:**
- Review findings
- Look for patterns
- Try creative combinations

---

## Phase 6: Logic Bug & Supply Chain Analysis (45-60 min)

**Activate:** `methodologies/07-logic-bug-hunting.md`

**Purpose:** Hunt logic bugs — no memory corruption needed, chain multiple low-severity issues for critical impact

### Step 6.1: Map Trust Boundaries
- Component boundaries (browser/renderer/sandbox, app/API/db, frontend/backend)
- IPC mechanisms and message passing
- Permission models and privilege levels
- State transitions and assumptions

### Step 6.2: Identify Logic Bug Categories
| Category | Description |
|----------|-------------|
| State Confusion | Assumptions about execution state are wrong |
| TOCTOU | Time-of-check vs time-of-use gaps |
| Privilege Confusion | Wrong privilege level assumed |
| Validation Bypass | Incomplete validation chain |
| Atomicity Violation | Multi-step operation not atomic |
| Assumption Violation | Code assumes something not guaranteed |
| Supply Chain Logic | Dependency introduces conflicting logic |

### Step 6.3: Chain Construction
```
Bug 1 → Bug 2 → Bug 3 → Bug 4 (Critical)
Low-sev info leak → boundary bypass → privilege esc → sandbox escape
```

### Step 6.4: Supply Chain Logic Analysis
- Dependency behavior changes (patch introduces new assumptions)
- Configuration drift (new feature defaults override security)
- Missing update side effects (fix is ineffective)
- Behavioral regressions (library behavior changes)

**Key Reference:** Entry #075 — Orange Tsai: 4 logic bugs → Edge sandbox escape, $175k, zero memory corruption

---

## Phase 7: Creative Pivoting (30-45 min)

### Pivot 1: JavaScript Analysis
```bash
# Download all JS files
cat javascript.txt | while read url; do
  wget "$url" -P js_files/
done

# Extract secrets
grep -r "api[_-]key" js_files/
grep -r "secret" js_files/
grep -r "password" js_files/
grep -r "token" js_files/

# Extract endpoints
grep -roh "https://[^\"']*" js_files/ | sort -u
```

### Pivot 2: Wayback Machine
```bash
# Get historical URLs
curl "http://web.archive.org/cdx/search/cdx?url=*.target.com/*&output=txt&fl=original&collapse=urlkey" \
  | sort -u > wayback_urls.txt

# Test old endpoints
cat wayback_urls.txt | while read url; do
  curl -I "$url"
done
```

### Pivot 3: GitHub Dorking
```bash
# Search for target in GitHub
site:github.com "target.com"
site:github.com "api_key" "target.com"
site:github.com "password" "target.com"
```

### Pivot 4: Certificate Transparency
```bash
# Find subdomains via CT logs
curl "https://crt.sh/?q=%.target.com&output=json" \
  | jq -r '.[].name_value' \
  | sort -u
```

---

## Phase 8: Validation (30-45 min)

**Activate:** `ai-self-validator.md`

### For EVERY finding:

1. **Challenge the finding**
   - Is it really exploitable?
   - Have I tested all protections?
   - Is the impact real?

2. **Build working PoC**
   - Deterministic (curl command, script)
   - Reproducible
   - Demonstrates impact

3. **Document thoroughly**
   - Step-by-step reproduction
   - Evidence (screenshots, logs)
   - Impact analysis

4. **Decision: ACCEPT or REJECT**
   - Only report if passes validation
   - Kill weak findings early

---

## Technique Priority Matrix

| Technique | Time | Priority | Success Rate |
|-----------|------|----------|--------------|
| OAuth Security | 30 min | CRITICAL | HIGH (if OAuth present) |
| Prompt Injection | 30 min | CRITICAL | HIGH (if AI present) |
| API Security | 30 min | HIGH | VERY HIGH |
| Parser Differentials | 30-45 min | HIGH | MEDIUM |
| Bucket Squatting | 30 min | MEDIUM | LOW (specific targets) |
| Enterprise Software | 30 min | MEDIUM | MEDIUM (if .NET) |
| MCP Security | 30 min | MEDIUM | MEDIUM (if MCP) |
| JavaScript Analysis | 30 min | HIGH | MEDIUM |
| Wayback Machine | 15 min | MEDIUM | LOW |
| GitHub Dorking | 15 min | MEDIUM | LOW |
| CT Logs | 15 min | LOW | LOW |

---

## When Stuck

> **Primary lookup:** `resources/VULN-INDEX.md` → Generic "I'm Stuck" Recovery (bottom section)

| When This Happens | What To Do |
|---|---|
| All techniques exhausted | Run `05-adaptive-hunt.md` Phase 7 (Creative Pivoting) |
| Every vuln class blocked | `resources/CROSS-DOMAIN-MAP.md` — switch domains, keep same technique |
| Can't find any entry point | `resources/VULN-INDEX.md` → Recon section (#004, #013, #112, #115) |
| Finding too many FPs | `resources/VULN-INDEX.md` → Logic Bugs → happy path trap (#160) |
| Need inspiration | `resources/VULN-INDEX.md` → Target Evaluation (#022, #120, #135) |

**Ultimate recovery:** `resources/VULN-INDEX.md` → "Generic I'm Stuck Recovery" (6-step: adaptive workflow → parallel agents → change vuln class → change domain → ask router → cross-domain map)

---

### When to Pivot

### Pivot Triggers:
- ✅ Technique found nothing after time limit
- ✅ Stuck on same issue for >30 min
- ✅ False positives accumulating
- ✅ No new findings in last hour

### Pivot Strategy:
1. **Document what was tried**
2. **Analyze why it didn't work**
3. **Choose different technique**
4. **Set new time limit**
5. **Execute and evaluate**

---

## Success Criteria

### Critical Findings
- ✅ Any RCE
- ✅ Any authentication bypass
- ✅ Any authorization bypass
- ✅ Any data exfiltration

### High Findings
- ✅ IDOR with sensitive data
- ✅ OAuth vulnerabilities
- ✅ Prompt injection
- ✅ SQL/NoSQL injection

### Medium Findings
- ✅ XSS
- ✅ CSRF
- ✅ Information disclosure
- ✅ Missing security headers

---

## Logging and Learning

### After Each Technique:
```bash
echo "$(date) | target.com | OAuth testing | No findings | 30 min" >> hunt-log.txt
echo "$(date) | target.com | API testing | Found IDOR | 45 min" >> hunt-log.txt
```

### After Hunt:
```bash
# Summary
echo "=== Hunt Summary ===" >> hunt-log.txt
echo "Target: target.com" >> hunt-log.txt
echo "Total time: 4 hours" >> hunt-log.txt
echo "Techniques tried: 8" >> hunt-log.txt
echo "Findings: 2 (1 HIGH, 1 MEDIUM)" >> hunt-log.txt
echo "Bounty: $3,500" >> hunt-log.txt
```

### Extract Patterns:
- What worked?
- What didn't work?
- What to try first next time?
- What to skip next time?

---

## Common Patterns (From 72 Resources)

### Pattern 1: OAuth Still Vulnerable
- 8 entries, $12,700+ bounties
- Popup hijacking, redirect_uri bypass, token theft
- **Lesson:** Always test OAuth thoroughly

### Pattern 2: IDOR Everywhere
- Multiple entries, consistent findings
- Numeric IDs, UUIDs, predictable patterns
- **Lesson:** Test every ID parameter

### Pattern 3: AI = New Attack Surface
- Prompt injection, MCP security
- High impact, low competition
- **Lesson:** Prioritize AI features

### Pattern 4: Parser Differentials Work
- Query strings, URLs, Content-Type
- Medium success rate, creative approach
- **Lesson:** Try when stuck

### Pattern 5: JavaScript Leaks Secrets
- API keys, endpoints, internal URLs
- Easy to find, high value
- **Lesson:** Always analyze JS files

---

## Tools Required

### Essential
- curl
- Burp Suite
- Browser DevTools
- Text editor

### Specialized
- Yandex search
- ffuf
- nuclei
- jq

### Optional
- MCP Inspector
- ILSpy
- Slither
- Foundry

---

## Time Allocation

| Phase | Time | Priority |
|-------|------|----------|
| Reconnaissance | 45-60 min | HIGH |
| High-Value Techniques | 90-120 min | CRITICAL |
| Parser Differentials | 30-45 min | HIGH |
| Less Common Techniques | 60-90 min | MEDIUM |
| Deep Dive | 60-90 min | HIGH (if promising) |
| Logic Bug & Supply Chain | 45-60 min | HIGH |
| Creative Pivoting | 30-45 min | MEDIUM |
| Validation | 30-45 min | CRITICAL |

**Total:** 5-7.5 hours per target

---

## Next Steps

### If Found Something:
1. Deep dive with specific workflow
2. Validate thoroughly
3. Report with PoC

### If Found Nothing:
1. Review hunt-log.txt
2. Analyze what was missed
3. Try different target
4. Come back later with fresh perspective

---

## References
- All 72 resources (comprehensive approach)
- Entry #22: Bug Bounty Methodology 2026 (systematic hunting)
- Entry #5: AI Self-Validation (challenge findings)
- Entry #11: Multi-Agent Orchestration (parallel techniques)
- Entry #075: Orange Tsai Edge sandbox escape (4 logic bugs, $175k)
- Entry #042: Chrome V8 RCE memory corruption ($55k)
- Entry #036: Big Sleep AI zero-day discovery
