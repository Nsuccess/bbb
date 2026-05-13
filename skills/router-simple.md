# Simple Router

## Role
Lightweight decision tree that routes targets to appropriate skills based on explicit signals. No AI reasoning overhead - pure if/else logic.

## Purpose
Quickly determine which skills to load based on target type, user hints, or detected patterns. Keeps context minimal by loading only 1-2 relevant skills per session.

## How to Use

**Input Format:**
```
Target: <URL or path>
Type: <web|api|ai|crypto|mobile|enterprise> (optional)
Hint: <any additional context>
```

**Output:**
- Which skills to load
- Initial checklist for that target type
- Suggested starting point

## Decision Tree

### IF Type = "api" OR URL contains "/api/" OR "/graphql" OR "/v1/" OR "/v2/"
**Load:**
- recon-basic.md (API mode)
- poc-generator.md (injection/IDOR focus)

**Initial Checklist:**
- [ ] Map all endpoints (GET, POST, PUT, DELETE)
- [ ] Extract parameters and data types
- [ ] Test authentication (missing, weak, bypassable)
- [ ] Test authorization (IDOR, privilege escalation)
- [ ] Test mass assignment
- [ ] Test injection (SQL, NoSQL, command)
- [ ] Check rate limiting

**Priority Techniques:**
1. IDOR (change IDs, test cross-user access)
2. Mass assignment (add admin=true, role=admin)
3. Broken authentication (missing tokens, weak validation)
4. Injection (SQL, NoSQL, command)

---

### IF Type = "web" OR URL is standard website
**Load:**
- recon-basic.md (web mode)
- oauth-security-auditor.md (if auth detected)

**Initial Checklist:**
- [ ] Run Yandex dorking for hidden assets
- [ ] Enumerate subdomains
- [ ] Find JavaScript files (extract endpoints)
- [ ] Identify authentication method (OAuth, SAML, custom)
- [ ] Test CSRF protection
- [ ] Test XSS (reflected, stored, DOM)
- [ ] Check for open redirects

**Priority Techniques:**
1. OAuth vulnerabilities (if OAuth detected)
2. XSS (test all input fields)
3. CSRF (test state-changing actions)
4. Open redirect (test redirect parameters)

---

### IF Type = "ai" OR Hint contains "chatbot|assistant|llm|gpt|claude|gemini"
**Load:**
- prompt-injection-hunter.md
- recon-basic.md (AI mode)

**Initial Checklist:**
- [ ] Map AI capabilities (what can it do?)
- [ ] Enumerate tools/functions
- [ ] Identify data access scope
- [ ] Retrieve system prompt
- [ ] Map ALL injection points (not just chat)
- [ ] Test action triggering
- [ ] Test data exfiltration

**Priority Techniques:**
1. System prompt extraction
2. Prompt injection (action triggering)
3. Data exfiltration (markdown images, webhooks)
4. Tool abuse (unauthorized operations)

---

### IF Type = "crypto" OR Hint contains "solidity|smart contract|defi|blockchain"
**Load:**
- crypto-defi-auditor.md
- recon-basic.md (contract mode)

**Initial Checklist:**
- [ ] Identify blockchain (Solana, Ethereum, etc.)
- [ ] Map contract functions
- [ ] Test accounting logic
- [ ] Check decimal precision handling
- [ ] Test oracle integration
- [ ] Check access controls
- [ ] Test reentrancy protection

**Priority Techniques:**
1. Accounting errors (balance mismatches)
2. Decimal precision attacks
3. Oracle manipulation
4. Reentrancy
5. Access control bypass

---

### IF Type = "mobile" OR Hint contains "android|ios|apk|ipa"
**Load:**
- recon-basic.md (mobile mode)
- poc-generator.md (mobile focus)

**Initial Checklist:**
- [ ] Decompile app (apktool for Android)
- [ ] Extract API endpoints from code
- [ ] Find hardcoded secrets
- [ ] Test deep links
- [ ] Test certificate pinning
- [ ] Test local storage security
- [ ] Test API authentication

**Priority Techniques:**
1. Hardcoded secrets (API keys, tokens)
2. Insecure deep links
3. API vulnerabilities (same as API mode)
4. Certificate pinning bypass

---

### IF Type = "enterprise" OR Hint contains "windows|.net|saml|sso"
**Load:**
- enterprise-software-auditor.md
- recon-basic.md (enterprise mode)

**Initial Checklist:**
- [ ] Decompile .NET assemblies (ILSpy)
- [ ] Analyze authentication (SAML, SSO, NTLM)
- [ ] Test authentication bypass
- [ ] Test NTLM relay
- [ ] Check for RCE vectors
- [ ] Test privilege escalation
- [ ] Check broken access control

**Priority Techniques:**
1. SAML token manipulation
2. NTLM relay
3. Authentication bypass
4. RCE (deserialization, command injection)
5. Local privilege escalation

---

### IF Type = "unknown" OR no clear signals
**Load:**
- recon-basic.md (generic mode)

**Initial Checklist:**
- [ ] Run comprehensive recon
- [ ] Identify technology stack
- [ ] Map attack surface
- [ ] Classify target type
- [ ] Re-run router with classification

**Next Steps:**
1. Run Yandex dorking
2. Enumerate subdomains
3. Analyze JavaScript files
4. Identify frameworks/technologies
5. Come back to router with findings

---

## Usage Examples

### Example 1: API Target
```
You: "Hunt https://api.example.com"

Router Output:
- Type detected: API
- Loading: recon-basic.md (API mode) + poc-generator.md
- Start with: Map endpoints → Test IDOR → Test mass assignment
```

### Example 2: AI Chatbot
```
You: "Test https://assistant.ai (AI chatbot)"

Router Output:
- Type: AI
- Loading: prompt-injection-hunter.md + recon-basic.md (AI mode)
- Start with: Extract system prompt → Map injection points → Test action triggering
```

### Example 3: Unknown Target
```
You: "Hunt https://newapp.com"

Router Output:
- Type: Unknown
- Loading: recon-basic.md (generic)
- Start with: Recon → Classify → Re-route
```

---

## Router Logic (Pseudocode)

```python
def route(target, type_hint=None, user_hint=None):
    # Explicit type provided
    if type_hint:
        return load_skills_for_type(type_hint)
    
    # Pattern matching on URL
    if "/api/" in target or "/graphql" in target:
        return ["recon-basic.md (API)", "poc-generator.md"]
    
    # Pattern matching on hint
    if any(word in user_hint.lower() for word in ["chatbot", "ai", "llm"]):
        return ["prompt-injection-hunter.md", "recon-basic.md (AI)"]
    
    if any(word in user_hint.lower() for word in ["solidity", "defi", "contract"]):
        return ["crypto-defi-auditor.md", "recon-basic.md (contract)"]
    
    # Default: recon first
    return ["recon-basic.md (generic)"]
```

---

## Important Notes

### This Router is NOT:
- ❌ An AI that "detects" features (will hallucinate)
- ❌ A monolithic orchestrator (keeps context minimal)
- ❌ Auto-learning (you update priorities manually)

### This Router IS:
- ✅ Simple if/else logic (fast, predictable)
- ✅ Loads 1-2 skills max (avoids context bloat)
- ✅ Requires explicit signals (you tell it the type)
- ✅ Provides starting checklist (not full automation)

### Human-in-the-Loop:
- You classify the target (web, API, AI, etc.)
- You pick which hypothesis to test first
- You run the actual PoC commands
- You verify if vulnerability is real
- You update priorities based on results

---

## Evolution Path

### Phase 1 (Now):
- Manual type classification
- Simple if/else routing
- Load 1-2 skills per session

### Phase 2 (After 5-10 hunts):
- Add priority tags (🔴 High, 🟡 Medium, 🟢 Low)
- Update based on what worked
- Refine checklists

### Phase 3 (After 20+ hunts):
- Extract patterns into operational intelligence store
- Build technique success matrix
- Adaptive routing based on verified results

---

## Related Files
- recon-basic.md (reconnaissance skill)
- poc-generator.md (PoC creation skill)
- quick-hunt.md (sequential workflow)
- All 10 specialized skills (oauth, prompt-injection, etc.)
