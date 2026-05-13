# Security Hunt Router

**Purpose:** Intelligent workflow selector based on target type and characteristics

**How to Use:**
1. Provide target URL or description
2. Router analyzes target
3. Router recommends workflow(s)
4. Execute recommended workflow

---

## Decision Tree

### Input Analysis

**You provide:**
- Target URL or application
- Optional hint (web/API/AI/crypto/mobile)
- Optional context (what you already know)

**Router determines:**
- Target type
- Attack surface
- Recommended workflow(s)
- Priority order

---

## Classification Rules

### Rule 1: OAuth/SSO Detected
**Indicators:**
- `/oauth/` in URL
- `/auth/` in URL
- `/login` with social login buttons
- OAuth providers mentioned (Google, GitHub, Facebook)
- Keywords: "oauth", "sso", "saml", "openid"

**→ Recommend:** `01-web-app-hunt.md` (OAuth focus)
**Priority:** CRITICAL (OAuth vulns = high bounties)

---

### Rule 2: API Detected
**Indicators:**
- `/api/` in URL
- `/graphql` in URL
- `/swagger` or `/openapi` in URL
- `Content-Type: application/json` responses
- REST/GraphQL/gRPC patterns
- Keywords: "api", "rest", "graphql", "endpoint"

**→ Recommend:** `02-api-security-hunt.md`
**Priority:** HIGH (IDOR, mass assignment common)

---

### Rule 3: AI/LLM Features Detected
**Indicators:**
- Chat interface
- Document upload/analysis
- AI assistant features
- "Powered by GPT/Claude/Gemini"
- MCP server endpoints
- Keywords: "ai", "chatbot", "assistant", "llm", "mcp"

**→ Recommend:** `03-ai-app-hunt.md`
**Priority:** CRITICAL (new attack surface, high impact)

---

### Rule 4: Crypto/DeFi Detected
**Indicators:**
- `.sol` files (Solidity)
- Smart contract addresses
- Blockchain interaction
- DeFi protocols
- Keywords: "crypto", "defi", "blockchain", "smart contract", "solana", "ethereum"

**→ Recommend:** `04-crypto-hunt.md`
**Priority:** CRITICAL (high bounties, complex vulns)

---

### Rule 5: Multiple Indicators
**If multiple types detected:**

**Example: Web app + API + OAuth**
**→ Recommend:**
1. `01-web-app-hunt.md` (start with OAuth)
2. `02-api-security-hunt.md` (then API testing)

**Example: AI app + API**
**→ Recommend:**
1. `03-ai-app-hunt.md` (start with prompt injection)
2. `02-api-security-hunt.md` (then API testing)

---

### Rule 6: Unknown/Generic Target
**If no clear indicators:**

**→ Recommend:** `05-adaptive-hunt.md`
**Priority:** MEDIUM (tries multiple techniques)

**Or ask user:**
```
"What type of target is this?
1. Web application (forms, login, OAuth)
2. API (REST, GraphQL, endpoints)
3. AI application (chatbot, assistant)
4. Crypto/DeFi (smart contracts)
5. Unknown (try everything)"
```

---

## Usage Examples

### Example 1: OAuth Web App
**Input:**
```
Target: https://app.example.com
Hint: Has Google OAuth login
```

**Router Analysis:**
- OAuth detected: ✅ (Google OAuth)
- API detected: ❓ (check for /api/)
- AI features: ❌

**Recommendation:**
```
PRIMARY: 01-web-app-hunt.md
  - Focus on OAuth security testing
  - Test popup hijacking
  - Test redirect_uri bypass
  - Test token theft

SECONDARY: 02-api-security-hunt.md (if API endpoints found)
```

---

### Example 2: REST API
**Input:**
```
Target: https://api.example.com/v1/
Hint: REST API with Swagger docs
```

**Router Analysis:**
- OAuth detected: ❓ (check auth method)
- API detected: ✅ (REST API, Swagger)
- AI features: ❌

**Recommendation:**
```
PRIMARY: 02-api-security-hunt.md
  - Start with endpoint enumeration
  - Test IDOR
  - Test mass assignment
  - Test injection

SECONDARY: 01-web-app-hunt.md (if OAuth auth found)
```

---

### Example 3: AI Chatbot
**Input:**
```
Target: https://chat.example.com
Hint: AI-powered document analyzer
```

**Router Analysis:**
- OAuth detected: ❓ (check auth)
- API detected: ❓ (check for API)
- AI features: ✅ (chatbot, document analysis)

**Recommendation:**
```
PRIMARY: 03-ai-app-hunt.md
  - Start with prompt injection
  - Map injection points (documents, chat)
  - Test action triggering
  - Test data exfiltration

SECONDARY: 02-api-security-hunt.md (if API endpoints found)
TERTIARY: 01-web-app-hunt.md (if OAuth found)
```

---

### Example 4: DeFi Protocol
**Input:**
```
Target: Solana DEX router
Hint: Smart contract on Solana
```

**Router Analysis:**
- OAuth detected: ❌
- API detected: ❓ (check RPC)
- AI features: ❌
- Crypto detected: ✅ (Solana, DEX)

**Recommendation:**
```
PRIMARY: 04-crypto-hunt.md
  - Analyze smart contract code
  - Test accounting logic
  - Test decimal precision
  - Test oracle manipulation
```

---

### Example 5: Unknown Target
**Input:**
```
Target: https://newapp.com
Hint: None
```

**Router Analysis:**
- OAuth detected: ❓
- API detected: ❓
- AI features: ❓
- Crypto detected: ❌

**Recommendation:**
```
STEP 1: Quick reconnaissance
  - Check for /api/, /oauth/, /graphql
  - Check for AI features (chat, upload)
  - Check technology stack

STEP 2: Based on findings, use:
  - 01-web-app-hunt.md (if web app)
  - 02-api-security-hunt.md (if API)
  - 03-ai-app-hunt.md (if AI)
  - 05-adaptive-hunt.md (if still unclear)
```

---

## Priority Matrix

| Target Type | Workflow | Priority | Reason |
|-------------|----------|----------|--------|
| OAuth/SSO | 01-web-app-hunt.md | CRITICAL | High bounties, common vulns |
| AI/LLM | 03-ai-app-hunt.md | CRITICAL | New attack surface, high impact |
| Crypto/DeFi | 04-crypto-hunt.md | CRITICAL | High bounties, complex vulns |
| REST API | 02-api-security-hunt.md | HIGH | IDOR, mass assignment common |
| GraphQL | 02-api-security-hunt.md | HIGH | Introspection, batching issues |
| Unknown | 05-adaptive-hunt.md | MEDIUM | Tries multiple techniques |

---

## Workflow Combinations

### Combination 1: Web App with API
```
1. Run 01-web-app-hunt.md (OAuth, XSS, CSRF)
2. If API endpoints found → Run 02-api-security-hunt.md
3. Validate all findings with ai-self-validator.md
```

### Combination 2: AI App with API
```
1. Run 03-ai-app-hunt.md (prompt injection, MCP)
2. If API endpoints found → Run 02-api-security-hunt.md
3. Validate all findings with ai-self-validator.md
```

### Combination 3: Comprehensive Hunt
```
1. Run 05-adaptive-hunt.md (tries everything)
2. Based on findings, deep dive with specific workflow
3. Validate all findings with ai-self-validator.md
```

---

## Quick Start Commands

### For Kiro IDE:
```
# Activate router
Load skill: router-simple.md

# Provide target
"Hunt https://target.com (web app with OAuth)"

# Router recommends workflow
# Execute recommended workflow
```

### Manual Selection:
```
# If you know the target type:
- Web app with OAuth → 01-web-app-hunt.md
- REST/GraphQL API → 02-api-security-hunt.md
- AI chatbot/assistant → 03-ai-app-hunt.md
- Smart contract → 04-crypto-hunt.md
- Unknown → 05-adaptive-hunt.md
```

---

## Success Metrics

### Router Effectiveness:
- ✅ Correct workflow recommended
- ✅ Vulnerabilities found using recommended workflow
- ✅ Time saved vs. trying all workflows

### Workflow Effectiveness:
- ✅ Findings per hour
- ✅ False positive rate
- ✅ Bounty amount per finding

---

## Continuous Improvement

### After Each Hunt:
1. **Log result:**
   ```
   Target: example.com
   Type: Web app with OAuth
   Workflow: 01-web-app-hunt.md
   Result: Found OAuth redirect_uri bypass
   Bounty: $5,000
   Time: 3 hours
   ```

2. **Update priorities:**
   - If OAuth hunting successful → increase OAuth priority
   - If API testing successful → increase API priority
   - If technique failed → try different approach next time

3. **Build operational memory:**
   - Extract successful patterns
   - Document what worked
   - Update workflows based on learnings

---

## References
- Entry #22: Bug Bounty Methodology 2026 (workflow design)
- Entry #5: AI Self-Validation (challenge findings)
- Entry #11: Multi-Agent Orchestration (parallel hunting)
