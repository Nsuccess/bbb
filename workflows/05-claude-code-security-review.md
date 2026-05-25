# Claude Code Security Review Workflow

**Source:** https://github.com/anthropics/claude-code-security-review
**Adapted:** 2026-05-24
**Original Author:** Anthropic
**License:** MIT

---

## Overview

Three-phase AI-powered security review methodology focusing on high-confidence vulnerabilities with aggressive false positive filtering. Designed for code review (PRs/diffs) but adaptable to full codebase audits.

---

## Phase 1 — Repository Context Research

**Tools:** File search, Grep, Read, Glob

1. Identify existing security frameworks and libraries in use
2. Look for established secure coding patterns in the codebase
3. Examine existing sanitization and validation patterns
4. Understand the project's security model and threat model
5. Document the privilege/role hierarchy

**Output:** Context summary (security patterns found, frameworks in use, threat model)

---

## Phase 2 — Comparative Analysis

1. Compare new code changes against existing security patterns
2. Identify deviations from established secure practices
3. Look for inconsistent security implementations
4. Flag code that introduces new attack surfaces
5. Trace data flow from user inputs to sensitive operations

**Output:** List of code changes with security significance

---

## Phase 3 — Vulnerability Assessment

**Categories to examine:**

### Input Validation
- SQL injection via unsanitized user input
- Command injection in system calls or subprocesses
- XXE injection in XML parsing
- Template injection in templating engines
- NoSQL injection in database queries
- Path traversal in file operations

### Authentication & Authorization
- Authentication bypass logic
- Privilege escalation paths
- Session management flaws
- JWT token vulnerabilities
- Authorization logic bypasses

### Crypto & Secrets Management
- Hardcoded API keys, passwords, or tokens
- Weak cryptographic algorithms or implementations
- Improper key storage or management
- Cryptographic randomness issues
- Certificate validation bypasses

### Injection & Code Execution
- Remote code execution via deserialization
- Pickle injection in Python
- YAML deserialization vulnerabilities
- Eval injection in dynamic code execution
- XSS vulnerabilities (reflected, stored, DOM-based)

### Data Exposure
- Sensitive data logging or storage
- PII handling violations
- API endpoint data leakage
- Debug information exposure

**Output:** List of findings with file, line, severity, category, description

---

## False Positive Filtering

### Hard Exclusions (DO NOT REPORT)
1. Denial of Service (DOS) vulnerabilities or resource exhaustion attacks
2. Secrets or credentials stored on disk if otherwise secured
3. Rate limiting concerns or service overload scenarios
4. Memory consumption or CPU exhaustion issues
5. Lack of input validation on non-security-critical fields without proven security impact
6. Input sanitization concerns for CI/CD workflows unless untrusted input
7. A lack of hardening measures (code is not expected to implement all best practices)
8. Race conditions or timing attacks that are theoretical rather than practical
9. Vulnerabilities related to outdated third-party libraries (managed separately)
10. Memory safety issues in memory-safe languages (Rust, Go, etc.)
11. Files that are only unit tests or test infrastructure
12. Log spoofing concerns (outputting user input to logs)
13. SSRF vulnerabilities that only control the path (must control host/protocol)
14. Including user-controlled content in AI system prompts
15. Regex injection
16. Regex DOS concerns
17. Insecure documentation (markdown files, etc.)
18. A lack of audit logs

### Precedents (Use for Judgment Calls)
1. Logging high-value secrets in plaintext IS a vulnerability. Logging URLs is safe.
2. UUIDs can be assumed unguessable — no validation needed.
3. Environment variables and CLI flags are trusted values.
4. Resource management issues (fd leaks, memory) are not valid.
5. Subtle/low-impact web vulns (tabnabbing, XS-Leaks, prototype pollution, open redirect) — do not report unless extremely high confidence.
6. React/Angular are generally secure against XSS unless using dangerous HTML methods.
7. Most CI/CD workflow vulns are not exploitable in practice.
8. Lack of auth checks in client-side JS/TS is NOT a vulnerability (backend is responsible).
9. Only include MEDIUM findings if obvious and concrete.
10. ipynb files: only report if concrete untrusted input path exists.
11. Logging non-PII data is not a vulnerability.
12. Command injection in shell scripts is generally not exploitable (no untrusted input).

### Confidence Scoring
- **10**: Certain exploit path identified, tested if possible
- **8-9**: Clear vulnerability pattern with known exploitation methods
- **7**: Suspicious pattern requiring specific conditions
- **<7**: Do NOT report (too speculative)

**Only report findings with confidence >= 8/10.**

---

## Output Format

### JSON Schema
```json
{
  "findings": [
    {
      "file": "path/to/file.py",
      "line": 42,
      "severity": "HIGH",
      "category": "sql_injection",
      "description": "User input passed to SQL query without parameterization",
      "exploit_scenario": "Attacker could extract database contents...",
      "recommendation": "Replace string formatting with parameterized queries...",
      "confidence": 0.95
    }
  ],
  "analysis_summary": {
    "files_reviewed": 8,
    "high_severity": 1,
    "medium_severity": 0,
    "low_severity": 0,
    "review_completed": true
  }
}
```

### Markdown Output Format
Each finding:
```
# Vuln N: <CATEGORY>: `<file>:<line>`

- Severity: <HIGH/MEDIUM/LOW>
- Description: <what and why>
- Exploit Scenario: <how to exploit>
- Recommendation: <how to fix>
```

---

## Sub-Agent FP Filtering Flow

For each finding identified in Phase 3:
1. Create a sub-agent with the FALSE POSITIVE FILTERING instructions
2. The sub-agent evaluates: concrete exploitable path? real security risk? specific code?
3. Only findings with confidence >= 8/10 survive
4. Final report contains only survivors

---

## Application to DeFi/Crypto Audits

**Modified exclusions for crypto:**
- Do NOT exclude: DoS/gas griefing (can be HIGH in DeFi)
- Do NOT exclude: Oracle manipulation (even if conditions-specific)
- Do NOT exclude: MEV/sandwich attacks (real value extraction)
- Do NOT exclude: Economic/Mathematical issues (rounding, precision)

**Modified security categories for crypto:**
- Add: Reentrancy / Cross-contract call safety
- Add: Oracle manipulation / Price feed integrity
- Add: Access control / Role management
- Add: Economic / Incentive alignment
- Add: Upgradeability / Proxy pattern safety
- Add: Signature / EIP-712 / Permit replay
- Add: Flash loan attack vectors
- Add: Liquidation mechanics
