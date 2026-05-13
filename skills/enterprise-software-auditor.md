# Enterprise Software Auditor

## Role
Enterprise software security specialist focusing on Windows-based applications, .NET software, backup/recovery systems, and non-web enterprise applications. Expert in source code analysis via decompilation, authentication bypass, RCE, NTLM relay, and privilege escalation.

## Purpose
Audit enterprise software (particularly Windows/.NET applications) using intuition and hacker mindset rather than deep reverse engineering knowledge. Focus on authentication bypass, RCE, NTLM relay, privilege escalation, and broken access control.

## Capabilities
- .NET decompilation (ILSpy)
- Windows application security testing
- Authentication bypass discovery
- Remote Code Execution (RCE) exploitation
- NTLM relay attacks
- Local Privilege Escalation (LPE)
- Broken access control testing
- IDOR discovery in enterprise apps
- REST API security analysis
- SAML/SSO authentication testing

## Methodology

### Phase 1: Reconnaissance

**Identify Application Type:**
- Windows desktop application (.exe)
- .NET application (.dll, .exe)
- Web-based enterprise portal
- REST API backend
- Multiple components (agents, servers, web UI)

**Gather Information:**
- Version numbers
- Components and architecture
- Authentication methods
- API endpoints
- Help documentation

### Phase 2: Decompilation (for .NET)

**ILSpy Decompilation:**

**PowerShell Script (Batch Decompile):**
```powershell
# Get all DLL files in current directory
$dllFiles = Get-ChildItem -Filter *.dll

foreach ($dllFile in $dllFiles) {
    # Create directory: filename_src
    $outputDirectory = Join-Path (Get-Location) ($dllFile.BaseName + "_src")
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
    
    # Build ilspycmd command
    $ilspycmdCommand = "ilspycmd $($dllFile.FullName) -p -o $outputDirectory"
    
    # Execute
    Invoke-Expression $ilspycmdCommand
}
```

**Analysis Focus:**
- Routes and roles
- Authentication options
- Access control logic
- API endpoints
- Database queries

### Phase 3: Authentication Testing

**Test 3.1: Authentication Bypass**

**SAML Token Manipulation (Veeam CVE-2024-29849):**
```xml
<saml2:Assertion xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion">
    <saml2:Issuer>https://127.0.0.1:8443/websso/SAML2/Metadata</saml2:Issuer>
    <saml2:Subject>
        <saml2:NameID>Administrator@lab.local</saml2:NameID>
    </saml2:Subject>
    <saml2:AttributeStatement>
        <saml2:Attribute Name="http://rsa.com/schemas/attr-names/2009/01/GroupIdentity">
            <saml2:AttributeValue>Administrators</saml2:AttributeValue>
        </saml2:Attribute>
    </saml2:AttributeStatement>
</saml2:Assertion>
```

**Attack:** Self-signed SAML token accepted without validation

**Impact:** Zero-interaction administrator account takeover

**Test 3.2: NTLM Relay**

**Scenario:** Application uses NTLM authentication

**Attack:**
1. Trigger NTLM authentication request
2. Relay to target service
3. Gain authenticated access

**Impact:** Account takeover via NTLM relay

### Phase 4: RCE Discovery

**Test 4.1: Deserialization**

**Look for:**
- Pickle files (Python)
- Java serialization
- .NET BinaryFormatter
- XML deserialization

**Test 4.2: Command Injection**

**Common Vectors:**
- File paths
- System commands
- Script execution
- Plugin loading

**Test 4.3: Agent RCE**

**Scenario:** Enterprise software with agents on client machines

**Attack:**
- Exploit agent communication
- Inject malicious commands
- Execute on agent machine

### Phase 5: Privilege Escalation

**Test 5.1: Local Privilege Escalation**

**Common Vectors:**
- Service misconfiguration
- DLL hijacking
- Unquoted service paths
- Weak file permissions

**Test 5.2: Broken Access Control**

**Look for:**
- Missing authorization checks
- Role-based access control (RBAC) bypass
- IDOR in API endpoints
- Privilege escalation via API

### Phase 6: Infrastructure Hacks

**Database Direct Access:**
- Insert dummy data directly into database
- Bypass application logic
- Test without full infrastructure setup

**Example (Veeam):**
- Needed VMware ESXI (large infrastructure)
- Solution: Insert dummy data into PostgreSQL
- Moved forward without full setup

## Tools

### Decompilation
- **ILSpy**: .NET decompiler
- **dnSpy**: .NET debugger and decompiler
- **JD-GUI**: Java decompiler

### Testing
- **Burp Suite**: API testing
- **Postman**: REST API testing
- **Responder**: NTLM relay
- **PowerShell**: Windows automation

### Analysis
- **Process Monitor**: Windows process monitoring
- **Wireshark**: Network traffic analysis
- **Fiddler**: HTTP(S) proxy

## Success Criteria

### Critical Findings
- Zero-interaction admin account takeover ($7,500 - Veeam)
- Remote Code Execution ($7,500 - Veeam)
- Cross-tenant access
- Authentication bypass

### High Findings
- NTLM relay to account takeover ($3,000 - Veeam)
- Local privilege escalation ($3,000 - Veeam)
- Broken access control
- IDOR with sensitive data access

### Medium Findings
- Information disclosure
- Weak authentication
- Missing authorization checks

## Real Examples

### Veeam Vulnerabilities ($30,000 total)

**CVE-2024-29849 - Auth Bypass ($7,500):**
- Self-signed SAML token accepted
- Zero-interaction admin takeover

**CVE-2024-42024 - RCE ($7,500):**
- RCE on Veeam One Agent

**CVE-2024-29850 - NTLM Relay ($3,000):**
- Classic NTLM relay attack

**CVE-2024-29853 - LPE ($3,000):**
- Local privilege escalation via agent

**CVE-2024-29852 - Broken Access Control:**
- Multiple IDOR vulnerabilities

**Key Insights:**
- Web guy tackling non-web apps
- Used intuition and hacker mindset
- Source code analysis via ILSpy
- 2 months of work
- $30,000 total bounties

## Key Patterns

### Vulnerable Code Patterns
```csharp
// VULNERABLE: No SAML signature validation
if (samlToken != null) {
    var user = ExtractUser(samlToken);
    AuthenticateUser(user);  // No validation!
}

// VULNERABLE: Missing authorization check
[HttpPost("/api/admin/delete")]
public IActionResult DeleteUser(int userId) {
    // No role check!
    DeleteUserFromDatabase(userId);
}

// VULNERABLE: IDOR
[HttpGet("/api/user/{id}")]
public IActionResult GetUser(int id) {
    // No ownership check!
    return GetUserData(id);
}
```

### Secure Code Patterns
```csharp
// SECURE: SAML signature validation
if (samlToken != null && ValidateSignature(samlToken)) {
    var user = ExtractUser(samlToken);
    AuthenticateUser(user);
}

// SECURE: Authorization check
[HttpPost("/api/admin/delete")]
[Authorize(Roles = "Admin")]
public IActionResult DeleteUser(int userId) {
    if (!User.IsInRole("Admin")) {
        return Forbid();
    }
    DeleteUserFromDatabase(userId);
}

// SECURE: Ownership check
[HttpGet("/api/user/{id}")]
public IActionResult GetUser(int id) {
    if (id != CurrentUser.Id && !User.IsInRole("Admin")) {
        return Forbid();
    }
    return GetUserData(id);
}
```

## Testing Checklist

- [ ] Decompile .NET assemblies with ILSpy
- [ ] Analyze routes and roles in source code
- [ ] Test SAML/SSO authentication
- [ ] Test self-signed tokens
- [ ] Test NTLM relay attacks
- [ ] Look for deserialization vulnerabilities
- [ ] Test command injection vectors
- [ ] Test agent communication security
- [ ] Check for broken access control
- [ ] Test IDOR in API endpoints
- [ ] Test privilege escalation paths
- [ ] Check service configurations
- [ ] Test DLL hijacking
- [ ] Analyze database access patterns
- [ ] Document all findings with PoCs

## References
- Entry #055: Hacking Veeam ($30k bounties, multiple CVEs)
- Entry #031: Android Pentesting Skill (similar research-based approach)
- ILSpy: https://github.com/icsharpcode/ILSpy
