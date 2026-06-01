# OTP / Auth-Flow Bypass Hunt

**Target Type:** Web/API auth flows with OTP, magic links, email verification, 2FA, password reset

**Skills Used:**
- oauth-security-auditor.md
- ai-self-validator.md
- recon-basic.md

**Expected Time:** 1-3 hours per auth flow

**Source:** Entry #178 (OTP Bypass via Stateless Verification ID)
**Source:** Entry #183 (Full ATO via OTP Verification Logic Flaw, $3k)
**Source:** Entry #053 (OAuth Non-Happy Path ATO, $3k)

---

## Overview

Modern auth flows are increasingly **stateless** — the server issues a temporary `verificationId` (or similar token) to track the verification process. The vulnerability occurs when this ID is **not bound to a specific user identity on the server side**.

This workflow systematically tests every OTP/verification flow for identity-binding failures. The pattern: **any identity field re-supplied at the verification step that isn't validated against the stored identity = instant ATO**.

---

## Phase 1: Auth Flow Mapping (15-30 min)

### Step 1.1: Identify All OTP / Verification Flows
**Common flows to test:**
- [ ] Login with email OTP (no password)
- [ ] Login with phone SMS OTP
- [ ] 2FA verification after password
- [ ] Email verification on signup
- [ ] Password reset via email link
- [ ] Password reset via OTP
- [ ] Magic link login
- [ ] Transaction confirmation (crypto/financial)
- [ ] Account recovery
- [ ] Email change verification
- [ ] Phone number change verification
- [ ] New device login approval
- [ ] Privilege change verification (e.g., becoming admin)

### Step 1.2: Document the Flow Structure
For each flow, document:
- **Step 1 (initiation):** What endpoint, what parameters
- **Step 2 (delivery):** Where is the OTP/link sent
- **Step 3 (verification):** What endpoint, what parameters
- **Response on success:** What does the server return (JWT, session, redirect, etc.)

**Example (typical login OTP flow):**
```
Step 1: POST /api/auth/email {"email": "user@example.com"}
  Response: {"verificationId": "KC:6BE2634:7FD2..."}

Step 2: User receives OTP via email

Step 3: PUT /api/auth/email
  {"loginId": "user@example.com", "otp_code": "123456", "verificationId": "KC:6BE2..."}
  Response: 200 OK + {"accessToken": "...", "idToken": "...", "refreshToken": "..."}
```

### Step 1.3: Identify the Identity Field
**Critical question:** What field identifies the user across the flow?
- `email`
- `loginId`
- `username`
- `userId`
- `phoneNumber`
- `accountId`

**Document where this field appears at each step.**

---

## Phase 2: Identity Injection Testing (30-60 min)

**The core attack:** swap the identity field at the verification step.

### Step 2.1: The Basic Swap Test
**Setup:** Create two accounts you control — Attacker (you) and Victim (you).

**Test:**
1. Initiate flow with Attacker's email → receive valid OTP
2. At Step 3 (verification), intercept the request
3. Swap the `loginId`/`email`/`userId` field to Victim's value
4. Keep Attacker's valid `otp_code` and `verificationId`
5. Send the modified request
6. Observe response

**Vulnerable response:** 200 OK with Victim's tokens
**Secure response:** 400/401 — "OTP doesn't match" or "Invalid user"

### Step 2.2: PoC Example (Entry #178, #183 pattern)
```bash
# Step 1: Attacker initiates flow
ATTACKER_OTP_RESPONSE=$(curl -X POST https://target.com/api/auth/email \
  -H "Content-Type: application/json" \
  -d '{"loginId": "attacker@example.com"}')

VERIFICATION_ID=$(echo $ATTACKER_OTP_RESPONSE | jq -r '.verificationId')
# Attacker receives OTP at attacker@example.com
# Let's say OTP = 123456

# Step 2: Attacker uses Attacker's valid OTP but VICTIM's identity
curl -X PUT https://target.com/api/auth/email \
  -H "Content-Type: application/json" \
  -d '{
    "loginId": "victim@example.com",
    "otp_code": "123456",
    "verificationId": "'$VERIFICATION_ID'"
  }'

# Expected (vulnerable): 200 OK + Victim's tokens
# Expected (secure): 400/401
```

### Step 2.3: Identity Field Variants
Test each possible field name:
- `email` vs `loginId` vs `username` vs `userId`
- Case sensitivity (`User@example.com` vs `user@example.com`)
- Whitespace padding
- Email canonicalization tricks (`user+tag@example.com`)

---

## Phase 3: Stateless VerificationId Failures (30-45 min)

The `verificationId` is supposed to be the binding between OTP and user. Test whether it actually IS.

### Step 3.1: VerificationId Forgery
**Test:** Can you guess or brute-force valid verificationIds?
- Known pattern? (e.g., `KC:6BE2634:7FD2...`)
- Length? Complexity? Time-based?
- Reuse across users?

### Step 3.2: VerificationId Reuse
**Test:** Can you reuse a verificationId from a previous flow?
- Across different users?
- Across different flows (login vs signup vs reset)?
- After completion (use the same one twice)?
- After expiration (timing test)?

### Step 3.3: Race Condition in Verification
**Test:** Send the verification request multiple times in parallel — does the same verificationId unlock for multiple users?

```bash
# Parallel requests with different identities, same verificationId
for email in attacker1@example.com attacker2@example.com victim@example.com; do
  curl -X PUT https://target.com/api/auth/email \
    -H "Content-Type: application/json" \
    -d "{\"loginId\": \"$email\", \"otp_code\": \"$OTP\", \"verificationId\": \"$VERIFICATION_ID\"}" &
done
wait
```

### Step 3.4: VerificationId to User Binding Check
**Test:** At Step 3, does the server validate that the verificationId was issued for the user being verified?

**How to check:** Use the verificationId from a flow initiated for User A to verify User B. If it works, the server is NOT binding identity server-side.

---

## Phase 4: Happy Path Bypass (15-30 min)

### Step 4.1: Skip OTP Entirely
**Test:** What if you go directly to the post-authentication state without verifying?

**Common bypass techniques:**
- Direct URL access to post-auth pages with valid session cookie
- API request to protected endpoint with token obtained before verification
- WebSocket connection with pre-verification token
- Setting a "verified=true" flag manually

### Step 4.2: Replay Previous Verified Session
**Test:** 
1. Complete full OTP flow for Attacker
2. Save the resulting JWT/cookies
3. Try to use those tokens to access Victim's resources

### Step 4.3: Forced Browser Back
**Test:** After completing OTP for Attacker, use browser back button. Does the post-auth state persist for the next OTP attempt?

---

## Phase 5: Non-Happy Path Exploitation (30-45 min)

**Source:** Entry #053 — OAuth Non-Happy Path ATO ($3k)

### Step 5.1: Error State Retention
**Test:** Trigger an error during verification (wrong OTP, expired, etc.) — does the verificationId still work after recovery?

### Step 5.2: Type Confusion
**Test:** Change `response_type`/`grant_type` to invalid values. Does the server still process the request and preserve state?

### Step 5.3: Referer / Origin Manipulation
**Test:** Modify Referer/Origin headers. Does the server still process the verification?

### Step 5.4: Method Override
**Test:** Send the verification request with method override headers (X-HTTP-Method-Override). Does the server accept it?

### Step 5.5: Content-Type Confusion
**Test:** Send verification as different content types (form vs JSON). Does the server still process it identically?

---

## Phase 6: Magic Link & Email Token Variations (30-45 min)

### Step 6.1: Magic Link Token Theft
**Test:** Click your own magic link, but with the victim's session cookie active. Does the token bind to the clicker or to the recipient?

### Step 6.2: Magic Link Reuse
**Test:** Use the same magic link twice. Does it work multiple times?

### Step 6.3: Host Header Poisoning
**Test:** Initiate flow with `Host: attacker.com` header. Does the magic link go to attacker.com?

```bash
curl -X POST https://target.com/api/auth/magic-link \
  -H "Host: attacker.com" \
  -H "Content-Type: application/json" \
  -d '{"email": "victim@example.com"}'
```

### Step 6.4: Email Header Injection
**Test:** Can you inject extra email headers in the OTP email? (`\r\nBcc: attacker@example.com`)

### Step 6.5: Email Canonicalization Bypass
**Test variations:**
- `victim+attacker@example.com` (plus aliasing)
- `vіctim@example.com` (Unicode homoglyph)
- `victim@exаmple.com` (Cyrillic 'a')
- `victim@example.com.` (trailing dot)
- `Victim@Example.com` (case)
- `victim@gmail.com` (gmail dot trick: `v.ictim@gmail.com`)

---

## Phase 7: 2FA / MFA Bypass (30-45 min)

### Step 7.1: 2FA Enumeration
**Test:** Does the 2FA response differ for valid vs invalid codes? (Timing, status code, error message)

### Step 7.2: 2FA Brute Force
**Test:** Is there rate limiting on 2FA attempts?
- Check per-IP limits
- Check per-account limits
- Check per-session limits

**Bypass techniques:**
- `X-Forwarded-For: 1.2.3.4` rotation
- `X-Real-IP` header
- `X-Originating-IP`
- IPv6 rotation

### Step 7.3: 2FA Recovery
**Test:** 
- "I lost my 2FA device" flow
- Backup codes
- SMS fallback
- Email fallback
- Support flow

### Step 7.4: 2FA Skip via Direct API
**Test:** Bypass the 2FA UI by calling the protected API directly with pre-2FA session token.

### Step 7.5: 2FA Race Condition
**Test:** Rapidly submit OTP attempts in parallel — does the rate limiter miss some?

---

## Phase 8: Validation (30 min)

**Activate:** `ai-self-validator.md`

### Step 8.1: Challenge Each Finding
For each potential bypass:

1. **Did the swap actually work?**
   - Re-run the test 3 times to confirm
   - Try with different victim accounts
   - Try with different attacker accounts

2. **What's the actual impact?**
   - Account takeover? Data access? Privilege escalation?
   - Mass exploitation (script for many victims)?

3. **Does the PoC require victim interaction?**
   - Victim must click link? = medium severity
   - No interaction = critical severity

### Step 8.2: Build Working PoC
**Example:**
```markdown
# Stateless VerificationId ATO

## Pre-conditions
- Attacker has their own account at target
- Attacker knows victim's email

## Steps
1. POST /api/auth/email with attacker's email → receive verificationId + OTP
2. PUT /api/auth/email with:
   - loginId: victim's email
   - otp_code: attacker's valid OTP
   - verificationId: attacker's valid ID
3. Server responds 200 with victim's full token suite
4. Attacker uses tokens to access victim's account

## Evidence
- Video: full reproduction
- Response logs: 200 OK with victim's tokens
- Access: attacker successfully accesses /api/account with victim's data

## Impact
- One-click ATO for any user
- Bypasses password, 2FA, and OTP protections
- No victim interaction required
- Mass-exploitable via automation
```

---

## Success Criteria

### Critical Findings
- ✅ Identity swap at verification = ATO (Entry #178, #183)
- ✅ VerificationId not bound to user = mass ATO
- ✅ 2FA completely bypassable
- ✅ Magic link sent to attacker via Host header poisoning

### High Findings
- ✅ Race condition in OTP verification
- ✅ 2FA brute-forceable
- ✅ Email canonicalization bypass
- ✅ Method override allows verification bypass

### Medium Findings
- ✅ VerificationId reuse after completion
- ✅ Email header injection in OTP delivery
- ✅ Error state retention allows re-verification

---

## Real Examples (From Inbox)

### Entry #178 — OTP Bypass via Stateless Verification ID
- Server issued verificationId but didn't bind to user identity
- Swap loginId in PUT body → full ATO
- Server trusted re-supplied identity field

### Entry #183 — Full ATO via OTP Verification Logic Flaw ($3k, HackerOne)
- Same pattern: identity field re-supplied at verification not validated
- $3,000 bounty
- Affects any stateless OTP implementation

### Entry #053 — OAuth Non-Happy Path to ATO ($3k)
- Error conditions in OAuth flow exploited
- Token still issued despite errors
- $3,000 bounty

---

## Tools Required

### Essential
- Burp Suite (intercept and modify requests)
- Two test email accounts you control
- Multiple test user accounts on target

### Specialized
- Email headers analysis (for `\r\n` injection)
- Unicode/IDN homoglyph tools (for email bypass)
- Race condition tool (Turbo Intruder)

---

## Time Allocation

| Phase | Time | Priority |
|-------|------|----------|
| Flow Mapping | 15-30 min | CRITICAL |
| Identity Injection | 30-60 min | CRITICAL |
| VerificationId Failures | 30-45 min | CRITICAL |
| Happy Path Bypass | 15-30 min | HIGH |
| Non-Happy Path | 30-45 min | HIGH |
| Magic Link / Email | 30-45 min | HIGH |
| 2FA / MFA | 30-45 min | HIGH |
| Validation | 30 min | CRITICAL |

**Total:** 3.5-5.5 hours per auth flow

---

## Defensive Checklist (For Blue Team / Developers)

**MUST implement:**
- [ ] Bind verificationId to user identity server-side (store mapping in DB/Redis)
- [ ] Validate that identity at verification step matches identity at initiation
- [ ] Use JWT with `sub` (subject) claim bound to user
- [ ] Sign verificationId with server-side key
- [ ] Set verificationId to single-use
- [ ] Set verificationId to short TTL (5-10 min)
- [ ] Rate-limit verification attempts (per user, per IP, per session)

**Should implement:**
- [ ] Log all OTP events for audit
- [ ] Notify user via separate channel on successful verification
- [ ] Implement 2FA always-on for sensitive operations
- [ ] Detect unusual OTP patterns (e.g., 100 OTPs/hour from one IP)
- [ ] Add anomaly detection on post-OTP session creation

---

## When Stuck

> **Primary lookup:** `resources/VULN-INDEX.md` → OAuth/Authentication section

| Stuck On... | VULN-INDEX Section | Key Entry |
|---|---|---|
| OTP doesn't bind identity at all | Auth → stateless verificationId | #178, #183 |
| Email canonicalization filter | Auth → email manipulation | ATO-Via-Password-Reset |
| Host header attack blocked | Auth → reset token, link generation | ATO-Via-Password-Reset |
| 2FA fully enforced | Auth → non-happy path ATO | #053 |
| Token already used but valid | Auth → reset token reuse | ATO-Via-Password-Reset |

**Cross-reference:** `methodologies/02-oauth-security-testing.md` for OAuth-specific bypasses.

---

## Next Steps

1. **If OAuth flow detected:** Try `01-web-app-hunt.md` (full OAuth testing)
2. **If API-only:** Try `02-api-security-hunt.md` (API auth bypass)
3. **If complex multi-factor:** Try `05-adaptive-hunt.md` (comprehensive)

---

## References

- Entry #178: OTP Bypass via Stateless Verification ID
- Entry #183: Full ATO via OTP Verification Logic Flaw ($3k)
- Entry #053: OAuth Non-Happy Path ATO ($3k)
- Entry #054: Drilling the redirect_uri in OAuth
- ATO-Via-Password-Reset repo: Complete password reset methodology
- `methodologies/02-oauth-security-testing.md`: OAuth attack patterns
- `steering/oauth-security-standards.md`: OAuth security standards
