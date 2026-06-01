# Xalgorix 22-Phase Web Security Workflow

**Source:** https://github.com/xalgord/xalgorix
**Adapted:** 2026-05-24
**Original Author:** xalgord
**License:** MIT

---

## Overview

22-phase autonomous security testing methodology, adapted from the Xalgorix AI pentesting platform. Each phase can be run independently for focused engagements.

---

## Phase Selection

For full-scope audits, run all phases. For focused bug bounty work, select relevant phases.

### Phase Map

| # | Phase | Web | API | DeFi | Mobile | Scanner |
|---|-------|-----|-----|------|--------|---------|
| 1 | Reconnaissance | ✅ | ✅ | ✅ | ✅ | ✅ |
| 2 | Manual vulnerability discovery | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3 | Directory and file discovery | ✅ | ✅ | ⬜ | ✅ | ⬜ |
| 4 | CORS and cookie analysis | ✅ | ✅ | ⬜ | ✅ | ⬜ |
| 5 | Authentication and session testing | ✅ | ✅ | ✅ | ✅ | ⬜ |
| 6 | Injection testing | ✅ | ✅ | ⬜ | ⬜ | ✅ |
| 7 | SSRF testing | ✅ | ✅ | ✅ | ⬜ | ✅ |
| 8 | IDOR and broken access control | ✅ | ✅ | ✅ | ✅ | ✅ |
| 9 | API and GraphQL testing | ✅ | ✅ | ⬜ | ✅ | ✅ |
| 10 | File upload testing | ✅ | ✅ | ⬜ | ✅ | ✅ |
| 11 | Deserialization and RCE | ✅ | ✅ | ✅ | ✅ | ✅ |
| 12 | Race conditions and business logic | ✅ | ✅ | ✅ | ✅ | ✅ |
| 13 | Subdomain takeover | ✅ | ⬜ | ⬜ | ⬜ | ⬜ |
| 14 | Open redirect testing | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 15 | Email security testing | ✅ | ✅ | ⬜ | ✅ | ⬜ |
| 16 | Cloud and infrastructure | ✅ | ⬜ | ⬜ | ⬜ | ✅ |
| 17 | WebSocket testing | ✅ | ✅ | ✅ | ⬜ | ⬜ |
| 18 | CMS-specific testing | ✅ | ⬜ | ⬜ | ⬜ | ⬜ |
| 19 | Broken link hijacking and content spoofing | ✅ | ⬜ | ⬜ | ⬜ | ⬜ |
| 20 | Exploit verification | ✅ | ✅ | ✅ | ✅ | ✅ |
| 21 | Zero-day discovery | ✅ | ✅ | ✅ | ✅ | ✅ |
| 22 | Final report | ✅ | ✅ | ✅ | ✅ | ✅ |
| **23 (NEW)** | **OTP / Stateless VerificationId Auth Bypass** | ✅ | ✅ | ✅ | ✅ | ⬜ |
| **24 (NEW)** | **AI Scanner Prompt Injection / SSRF** | ⬜ | ⬜ | ⬜ | ⬜ | ✅ |
| **25 (NEW)** | **DeFi Safe Module / Sybil Resistance** | ⬜ | ⬜ | ✅ | ⬜ | ⬜ |
| **26 (NEW)** | **CSP Header Recon** | ✅ | ⬜ | ⬜ | ⬜ | ⬜ |

---

## Phase Details (for DeFi adaptation)

### Phase 1 — Reconnaissance
- Scan all in-scope contract addresses
- Enumerate all public functions and state variables
- Check deployed implementations (proxy patterns)
- Review upgradeability mechanisms
- Map external dependencies (oracles, bridges, AMMs)

### Phase 2 — Manual Vulnerability Discovery
- Read all audit reports (previous findings)
- Read protocol documentation
- Map economic model and incentive flows
- Identify all roles and permission boundaries

### Phase 5 — Authentication and Session
- Check all role-based access control functions
- Verify DEFAULT_ADMIN_ROLE holders
- Test for missing access controls
- Check timelocks on critical functions

### Phase 8 — IDOR and Broken Access Control
- Check position/account enumeration
- Verify cross-account isolation
- Test NFT position ID manipulation
- Check A_Token/Debt_Token transfer hooks

### Phase 11 — Deserialization and RCE
- Check for unsafe delegatecall patterns
- Verify CREATE2 address safety
- Check for unverified external contract calls
- Test proxy implementation upgrades

### Phase 12 — Race Conditions
- Check liquidation / TWAP race conditions
- Verify checks-effects-interactions patterns
- Test for reentrancy in external calls
- Check for flash loan sandwich windows

### Phase 17 — WebSocket Testing
- If protocol has any websocket endpoints (chain events)
- Check for event log manipulation possibilities

### Phase 20 — Exploit Verification
- Build and test PoC for each finding
- Validate before reporting

---

### Phase 23 — OTP / Stateless VerificationId Auth Bypass (NEW — Entries #178, #183)

**For any auth flow with OTP, magic link, email verification, or 2FA:**
- Initiate flow as Attacker
- At verification, swap identity field (loginId/email/userId) to Victim
- Check if server validates identity binding to verificationId
- If swap works → full ATO
- Also test: 2FA brute force, Host header poisoning, email canonicalization bypass

**Source:** Entry #178, #183, 053. **Full methodology:** `08-otp-auth-bypass.md`

---

### Phase 24 — AI Scanner Prompt Injection / SSRF (NEW — Entries #182, #185)

**For when TARGET is an AI-powered security scanner:**
- Map scanner's injection points (user-generated content, files, comments)
- Plant prompt injection in stored content
- Test destructive actions, data exfiltration, routing-based SSRF
- Chain: prompt injection + Host header manipulation = scanner as SSRF pivot

**Source:** Entry #182, 185. **Full methodology:** `07-ai-scanner-audit.md`

---

### Phase 25 — DeFi Safe Module / Sybil Resistance (NEW — Entries #176, #177)

**For DeFi protocols:**
- Check Safe module delegatecall authorization (SquidRouter $3M pattern)
- Check reward path order of operations (WUSD/GLOVE $19.7k pattern)
- Test fresh-address claim repetition
- Test balance-based eligibility gates

**Source:** Entry #176, 177.

---

### Phase 26 — CSP Header Recon (NEW — Entry #180)

**Quick recon win:**
- Extract CSP headers from main domain
- For each whitelisted origin: visit directly
- Check for /admin/register, /install, /setup
- Try to register an admin account
- Often one-shot full admin takeover

**Source:** Entry #180.

---

## Configuration Reference

### Environment Variables (pattern for tool integration)
```
XALGORIX_LLM=provider/model-name
XALGORIX_API_KEY=your-api-key
XALGORIX_REASONING_EFFORT=high
XALGORIX_MAX_ITERATIONS=0  # 0 = unlimited
XALGORIX_RATE_RPS=10
```

### Output Format
- Findings stored with CVSS details
- Proof of Concept evidence attached
- PDF report with executive summary + technical analysis
