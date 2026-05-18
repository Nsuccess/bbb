# BitMEX Bug Bounty Program — Target Evaluation

**Evaluated:** 2026-05-17
**Platform:** HackerOne
**Scope:** `testnet.bitmex.com`, `www.bitmex.com`, `*.bitmex.com`, mobile apps
**Program URL:** HackerOne BitMEX

---

## Router Classification

| Rule | Match | Workflow | Priority |
|------|-------|----------|----------|
| Rule 2: API Detected | ✅ REST API at `/api/explorer/` | `02-api-security-hunt.md` | **HIGH** |
| Rule 4: Crypto | ❌ Centralized exchange — NOT smart contracts | `04-crypto-hunt.md` (accounting only) | **MEDIUM** |
| Rule 1: OAuth | ❓ Unknown — API key auth primary | `01-web-app-hunt.md` if OAuth found | **LOW** |

**Primary:** `02-api-security-hunt.md` (IDOR, mass assignment, auth bypass)
**Secondary:** `07-logic-bug-hunting.md` (trading engine, order matching, liquidation)
**Tertiary:** `04-crypto-hunt.md` (accounting errors only)

---

## Program Details

### Stats
- **Avg first response:** 1.7 days ✅ Fast
- **Avg bounty (High):** $5,000 ✅ Decent
- **Response efficiency:** 90%+ ✅
- **Testnet reports resolved:** 58 (well-tested) ⚠️
- **Must disclose AI/LLM use** — first program to require this ⚠️

### Payouts
| Severity | Avg Bounty | % of Reports |
|----------|-----------|-------------|
| Critical | n/a | 3% |
| High | $5,000 | 22% |
| Medium | $2,075 | 20% |
| Low | n/a | 55% |

### Scope
| Asset | Reports | Notes |
|-------|---------|-------|
| `testnet.bitmex.com` | 58 (41%) | Most tested — use this |
| `www.bitmex.com` | 4 (3%) | Less tested — but prefer testnet |
| `*.bitmex.com` wildcard | 59 (42%) | Subdomain enumeration potential |
| Mobile apps | 0-5 each | Largely untested |

### Key Exclusions (don't waste time)
- Chat endpoints public access
- Proof of Reserve S3 bucket
- Analytics keys in JS (expected)
- Clickjacking, CSRF without working PoC
- Path disclosure, missing headers
- XSS mitigated by CSP = Low unless bypass found

---

## INBOX Entries That Apply

| Entry | Technique | BitMEX Application |
|-------|-----------|-------------------|
| #016 | Accounting bugs (router pays difference) | Position/leverage calc bugs, funding rate manipulation |
| #027 | Case-sensitivity/oracle string canon | Market symbol registration, duplicate markets |
| #075 | Logic bug chaining (Orange Tsai) | Chain 3-4 API logic bugs for critical impact |
| #076 | Race conditions | Order create/cancel race, position modification race |
| #077 | 80% verification, 20% finding | HIGH priority — detailed PoC required |
| #088 | MoonPay auth chain experience | Transfer same chain methodology to REST API |
| #110 | Crypto target recon approach | Testnet registration, API explorer analysis |
| #120 | Triager AMA (raw HTTP, CVSS) | Must follow for BitMEX |
| #124 | WordPress user enum | Check if bitmex.com runs WP |
| #127 | URL-encoded WAF bypass | Try `/%61dmin` on admin panels |

---

## Attack Surface

### API Endpoints (REST)
```
GET    /api/v1/user           — User info
GET    /api/v1/position       — Open positions
GET    /api/v1/order          — Orders
POST   /api/v1/order          — Create order
DELETE /api/v1/order          — Cancel order
GET    /api/v1/wallet         — Wallet data
GET    /api/v1/trade          — Trade history
```

### Auth Methods
- API keys with scopes: read-only, trade, withdraw
- Session-based auth via web UI
- Testnet: auto-KYC on 2nd login

---

## Attack Vectors (by Priority)

### 🔴 CRITICAL Potential

**1. App-Layer DoS (Explicitly In Scope!)**
- BitMEX is the rare program that includes DoS up to Critical
- Target: order book floods, WebSocket reconnect storms, complex query DoS
- From policy: "App-layer DoS issues are eligible for up to critical severity"
- **Unique angle** — most programs exclude DoS entirely

**2. API Key Permission Escalation**
- Read-only key submits trades? Trade key withdraws funds?
- Test all scope combinations
- Pattern: `07-logic-bug-hunting.md` Phase 1 — privilege confusion

### 🟡 HIGH Potential

**3. IDOR on Positions/Orders**
- Can User A see User B's positions via `/api/v1/position`?
- Can User A cancel User B's orders?
- 58 previous reports ≠ this is gone — new edge cases exist

**4. Rate Limit Bypass**
- Order submission rate limits
- Bypass via different endpoints or headers
- Chain with app-layer DoS

**5. Liquidation Logic Bug**
- Trigger wrongful liquidation of profitable position
- Edge cases in mark price calculation
- Funding rate manipulation

### 🟢 MEDIUM Potential

**6. Account Enumeration**
- Testnet registration email existence check
- Password reset timing differences

**7. Mass Assignment**
- API key creation accepts unexpected params
- User profile update accepts role/permissions

**8. Referral/Affiliate Abuse**
- Self-referral, manipulation of referral tracking

---

## Risk Assessment

| Factor | Score | Detail |
|--------|-------|--------|
| Payout reliability | 🟢 HIGH | 90%+ response, avg $5k High |
| Response speed | 🟢 HIGH | ~2 days avg |
| Surface uniqueness | 🟡 MED | Well-tested (58 reports), DoS angle unique |
| Competition | 🔴 HIGH | Mature program, top researchers active |
| Methodology fit | 🟢 HIGH | API + logic hunting maps well |
| AI disclosure | 🟡 MED | Must disclose — may bias triage |
| Barrier to entry | 🟢 LOW | Testnet, auto-KYC, free |
| Novelty potential | 🟡 MED | Low-hanging fruit gone; deep logic bugs remain |

---

## Verdict: WORTH HACKING — WITH STRATEGY

### Do NOT waste time on:
- Basic IDOR on user data (picked clean by 58 reports)
- XSS (capped at Low unless CSP bypass)
- Clickjacking/CSRF (OOS or requires working browser PoC)

### DO focus on:
1. **App-layer DoS** — unique angle, up to Critical
2. **Complex logic bugs** — order matching, liquidation, funding rate (less competition)
3. **Auth chain bugs** — API key permission escalation (transfer MoonPay methodology)
4. **Race conditions** — order create/cancel race (Entry #076)
5. **Subdomain wildcard** `*.bitmex.com` — forgotten services

### Must do:
- Create testnet account (2 logins for auto-KYC)
- Download API swagger from `testnet.bitmex.com/api/explorer/`
- Map all REST endpoints + parameters
- Follow `09-submission-format.md` — raw HTTP, CVSS, lead with PoC
- **Disclose AI use** per program rules

### Comparison: BitMEX vs MoonPay

| Factor | MoonPay | BitMEX |
|--------|---------|--------|
| Program age | Newer | Mature |
| Competition | Lower | Higher |
| PoC requirements | Moderate | Strict |
| Response speed | Slow (37d avg) | Fast (1.7d) |
| Payout consistency | Unknown | Proven |
| AI disclosure | Not required | **Required** |
| Unique angle | GraphQL + bundle | **DoS in scope** |
