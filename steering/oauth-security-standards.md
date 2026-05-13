---
inclusion: auto
description: OAuth security best practices, common pitfalls, and attack patterns for authorization flow testing
keywords: oauth, authorization, authentication, popup, redirect, token
---

# OAuth Security Standards & Attack Patterns

## Critical OAuth Vulnerabilities to Test

### 1. OAuth Popup Hijacking via Predictable window.open() Target

**Attack Vector**: Iframe name collision allows hijacking authorization popups.

**Root Cause**: Static, predictable window names in `window.open()` calls.

**Vulnerable Pattern**:
```javascript
// VULNERABLE: Static window name
let popup = window.open(
    authorizeUrl, 
    "oauth-window",  // ❌ Predictable name
    "width=640,height=575"
);
```

**Attack Chain**:
1. Attacker page contains `<iframe>` with pre-chosen name matching target's `window.open()` name
2. Victim visits attacker page, then opens legitimate app
3. App calls `window.open(authorizeUrl, "oauth-window")`
4. Browser finds existing browsing context (attacker's iframe)
5. OAuth flow loads in attacker's iframe instead of new window
6. Attacker redirects to pre-captured callback with malicious authorization code
7. Victim's app processes response, links attacker-controlled resource

**Testing Checklist**:
- [ ] Identify OAuth popup flows in target application
- [ ] Check if `window.open()` uses static/predictable target names
- [ ] Test if iframe with matching name can hijack popup
- [ ] Verify if CSP allows framing of any app pages (even static files)
- [ ] Check if callback endpoints validate window.opener relationship
- [ ] Test if intermediate CSP failures break attack chain

**Remediation**:
```javascript
// SECURE: Randomized window name
let popup = window.open(
    authorizeUrl,
    `oauth-${crypto.randomUUID()}`,  // ✅ Unique per session
    "width=640,height=575"
);
```

### 2. OAuth Security Checks (Necessary but Insufficient)

**Common Security Patterns**:
```javascript
window.addEventListener("message", (event) => {
    // Check 1: Origin validation
    if (event.origin !== expectedOrigin) return;
    
    // Check 2: Source window validation  
    if (event.source !== popupReference) return;
    
    // Process OAuth callback
    handleOAuthResponse(event.data);
});
```

**Why These Checks Can Fail**:
- Origin check: Correct, but doesn't prevent iframe hijacking
- Source check: Validates window reference, but iframe maintains valid reference
- Browser maintains context relationships across redirects
- Intermediate CSP failures don't break attack chain

**Additional Required Checks**:
- [ ] Randomized window names (prevents hijacking)
- [ ] State parameter validation (CSRF protection)
- [ ] PKCE (Proof Key for Code Exchange) for public clients
- [ ] Nonce validation for ID tokens
- [ ] Redirect URI strict matching (no wildcards)

### 3. CSP Bypass via Static Files

**Common Weakness**: Static files often have relaxed CSP headers.

**Attack Pattern**:
```html
<!-- Attacker creates iframe under target origin -->
<iframe
    name="oauth-window"
    src="https://app.target.com/static/chunk.js">
    <!-- Static JS file has relaxed CSP, omits frame-ancestors -->
</iframe>
```

**Testing**:
- [ ] Check CSP headers on static file endpoints (`/static/*`, `/assets/*`, `/public/*`)
- [ ] Verify `frame-ancestors` directive present on ALL pages
- [ ] Test if 404 pages have proper CSP
- [ ] Check if API endpoints (`/api/*`) have CSP headers

**Remediation**:
- Apply consistent CSP across all endpoints
- Include `frame-ancestors 'none'` or specific origins
- Don't exempt static files from security headers

### 4. OAuth Redirect URI Validation

**Common Pitfalls**:

**Insufficient Validation**:
```javascript
// ❌ VULNERABLE: Substring matching
if (redirectUri.includes("app.example.com")) {
    // Allows: https://evil.com?redirect=app.example.com
}

// ❌ VULNERABLE: Regex without anchors
if (/app\.example\.com/.test(redirectUri)) {
    // Allows: https://app.example.com.evil.com
}

// ❌ VULNERABLE: Wildcard subdomains
allowedRedirects = ["https://*.example.com/callback"]
// Allows subdomain takeover attacks
```

**Secure Validation**:
```javascript
// ✅ SECURE: Exact URL matching
const allowedRedirects = [
    "https://app.example.com/oauth/callback",
    "https://app.example.com/auth/callback"
];

if (!allowedRedirects.includes(redirectUri)) {
    throw new Error("Invalid redirect URI");
}

// ✅ SECURE: Strict origin + path validation
const url = new URL(redirectUri);
if (url.origin !== "https://app.example.com" || 
    !url.pathname.startsWith("/oauth/")) {
    throw new Error("Invalid redirect URI");
}
```

**Testing Checklist**:
- [ ] Test with subdomain variations (`evil.app.example.com`)
- [ ] Test with path traversal (`/oauth/callback/../admin`)
- [ ] Test with URL parameters (`?redirect=evil.com`)
- [ ] Test with fragments (`#evil.com`)
- [ ] Test with open redirects in allowed domains
- [ ] Test with homograph attacks (unicode domains)
- [ ] Test with IP addresses vs domain names
- [ ] Test with different schemes (`http://` vs `https://`)

### 5. State Parameter Attacks

**Purpose**: CSRF protection for OAuth flows.

**Vulnerable Implementation**:
```javascript
// ❌ VULNERABLE: Predictable state
const state = btoa(userId);  // Easily guessable

// ❌ VULNERABLE: No state validation
// Just accepts any state parameter
```

**Secure Implementation**:
```javascript
// ✅ SECURE: Cryptographically random state
const state = crypto.randomUUID();
sessionStorage.setItem('oauth_state', state);

// Later, in callback:
const receivedState = new URL(window.location).searchParams.get('state');
const expectedState = sessionStorage.getItem('oauth_state');

if (receivedState !== expectedState) {
    throw new Error("State mismatch - possible CSRF");
}
sessionStorage.removeItem('oauth_state');
```

**Testing**:
- [ ] Check if state parameter is present
- [ ] Test if state is validated on callback
- [ ] Test if state is cryptographically random
- [ ] Test if state is single-use (replay protection)
- [ ] Test if missing state is rejected
- [ ] Test if state from different session is rejected

### 6. PKCE (Proof Key for Code Exchange)

**Required for**: Public clients (SPAs, mobile apps, desktop apps).

**Flow**:
```javascript
// 1. Generate code verifier (random string)
const codeVerifier = generateRandomString(128);

// 2. Generate code challenge (SHA256 hash)
const codeChallenge = base64url(sha256(codeVerifier));

// 3. Authorization request
const authUrl = `${authEndpoint}?` +
    `client_id=${clientId}&` +
    `redirect_uri=${redirectUri}&` +
    `code_challenge=${codeChallenge}&` +
    `code_challenge_method=S256`;

// 4. Token request (include verifier)
const tokenResponse = await fetch(tokenEndpoint, {
    method: 'POST',
    body: JSON.stringify({
        code: authCode,
        code_verifier: codeVerifier,  // Server verifies hash matches
        client_id: clientId,
        redirect_uri: redirectUri
    })
});
```

**Testing**:
- [ ] Check if PKCE is required for public clients
- [ ] Test if `code_challenge` parameter is validated
- [ ] Test if `code_verifier` is required in token request
- [ ] Test if mismatched verifier is rejected
- [ ] Test if `plain` method is rejected (only `S256` should be allowed)
- [ ] Test if PKCE can be omitted entirely

### 7. Token Leakage Vectors

**Common Leakage Points**:

1. **Referer Header**:
   ```html
   <!-- ❌ Token in URL fragment -->
   https://app.example.com/callback#access_token=SECRET
   
   <!-- User clicks external link -->
   <a href="https://evil.com">Click here</a>
   <!-- Referer: https://app.example.com/callback#access_token=SECRET -->
   ```

2. **Browser History**:
   - Tokens in URL are stored in browser history
   - Accessible via JavaScript: `history.back()`
   - Visible in browser's history UI

3. **Logs and Analytics**:
   - Tokens in URL logged by web servers
   - Sent to analytics platforms (Google Analytics, etc.)
   - Stored in CDN logs

**Testing**:
- [ ] Check if tokens are in URL (query or fragment)
- [ ] Test if tokens are in POST body instead
- [ ] Check if `Referrer-Policy` header is set
- [ ] Test if tokens are cleared from URL after processing
- [ ] Check if tokens are logged server-side
- [ ] Test if tokens are sent to third-party analytics

**Secure Pattern**:
```javascript
// ✅ Use authorization code flow (token in POST body)
// ✅ Set Referrer-Policy header
// ✅ Clear URL after processing

const url = new URL(window.location);
const code = url.searchParams.get('code');

// Exchange code for token (server-side)
const token = await exchangeCodeForToken(code);

// Clear URL
window.history.replaceState({}, document.title, url.pathname);
```

## OAuth Testing Methodology

### Phase 1: Reconnaissance

- [ ] Identify OAuth provider (Google, GitHub, custom, etc.)
- [ ] Map all OAuth endpoints (authorize, token, userinfo)
- [ ] Identify OAuth flow type (authorization code, implicit, hybrid)
- [ ] Check if PKCE is used
- [ ] Document all redirect URIs
- [ ] Identify client type (confidential vs public)

### Phase 2: Configuration Analysis

- [ ] Check `client_id` exposure
- [ ] Test if `client_secret` is exposed (client-side code)
- [ ] Verify `response_type` parameter
- [ ] Check `scope` parameter (test for scope escalation)
- [ ] Analyze `redirect_uri` validation
- [ ] Test `state` parameter implementation

### Phase 3: Flow Testing

- [ ] Test authorization request manipulation
- [ ] Test callback parameter injection
- [ ] Test token endpoint directly
- [ ] Test refresh token flow
- [ ] Test token revocation
- [ ] Test logout/session termination

### Phase 4: Attack Scenarios

- [ ] OAuth popup hijacking (iframe name collision)
- [ ] Redirect URI manipulation
- [ ] State parameter bypass (CSRF)
- [ ] PKCE bypass
- [ ] Scope escalation
- [ ] Token leakage (Referer, logs, history)
- [ ] Account takeover via OAuth
- [ ] Pre-account takeover (account linking)

## Common OAuth Misconfigurations

### 1. Implicit Flow in 2026

**Problem**: Implicit flow is deprecated, tokens in URL fragment.

**Check**:
```
response_type=token          # ❌ Implicit flow
response_type=code           # ✅ Authorization code flow
response_type=code id_token  # ⚠️  Hybrid flow (check PKCE)
```

### 2. Missing PKCE for Public Clients

**Problem**: Public clients can't keep secrets, vulnerable to authorization code interception.

**Required**: PKCE for all public clients (SPAs, mobile, desktop).

### 3. Wildcard Redirect URIs

**Problem**: Allows attacker-controlled redirects.

```json
// ❌ VULNERABLE
"redirect_uris": [
    "https://*.example.com/callback"
]

// ✅ SECURE
"redirect_uris": [
    "https://app.example.com/oauth/callback",
    "https://app.example.com/auth/callback"
]
```

### 4. Open Redirects in Allowed Domains

**Problem**: Even with strict redirect URI validation, open redirects in allowed domains can leak tokens.

**Attack**:
```
https://app.example.com/oauth/callback?code=SECRET
→ https://app.example.com/redirect?url=https://evil.com
→ https://evil.com (code leaked via Referer)
```

**Testing**: Find open redirects in domains with allowed redirect URIs.

## Automation Checklist

When analyzing OAuth implementations:

- [ ] Extract all `window.open()` calls, check for static names
- [ ] Map all postMessage listeners, verify origin checks
- [ ] Identify OAuth endpoints from JavaScript
- [ ] Extract redirect URIs from config/code
- [ ] Check for state parameter generation and validation
- [ ] Verify PKCE implementation
- [ ] Test CSP headers on all endpoints
- [ ] Check for token leakage vectors
- [ ] Test redirect URI validation with fuzzing
- [ ] Verify token storage (localStorage vs sessionStorage vs cookies)

## References

- Entry #018: OAuth Popup Hijacking via Predictable window.open() Target
- Entry #048: OAuth Security Best Practices (if available)
- Entry #053: OAuth Common Pitfalls (if available)
- Entry #054: OAuth Attack Patterns (if available)
- Entry #059: OAuth Token Leakage (if available)
- Entry #060: OAuth PKCE Implementation (if available)
- Entry #064: OAuth Redirect URI Validation (if available)

## Key Takeaways

1. **Never use predictable window names** in security-sensitive `window.open()` calls
2. **Origin + source checks are insufficient** - need randomization
3. **Static files need same CSP** as dynamic pages
4. **Redirect URI validation must be exact** - no wildcards, no substring matching
5. **State parameter is mandatory** - cryptographically random, single-use
6. **PKCE is required for public clients** - no exceptions
7. **Tokens should never be in URLs** - use authorization code flow
8. **Test the entire chain** - one weak link breaks all security
