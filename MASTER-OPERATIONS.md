# MASTER EXPLOITATION FRAMEWORK — OPERATIONS MANUAL

## Architecture: How Everything Fits Together

```
YOU (Target Input)
  │
  ▼
┌─────────────────────────────────────────────────┐
│             00-router.md (Decision Tree)         │
│  Analyzes target → Recommends workflow           │
└──────────┬──────────────────────┬───────────────┘
           │                      │
     ┌─────▼──────────┐    ┌─────▼──────────┐
     │  Methodology   │    │    Workflow    │
     │  (how to hunt) │    │ (what to do)   │
     └─────┬──────────┘    └─────┬──────────┘
           │                      │
           └──────────┬───────────┘
                      ▼
     ┌──────────────────────────────┐
     │  Skills (AI agent personas)  │
     │  + Cloned Tools (weapons)    │
     └──────────────────────────────┘
                      │
                      ▼
     ┌──────────────────────────────┐
     │  Steering (rules & ethics)   │
     │  + 00-INBOX.md (72 entries)  │
     └──────────────────────────────┘
                      │
                      ▼
                 FINDING → VALIDATE → REPORT
```

---

## TOOL-TO-SKILL MAPPING

Every cloned repo is mapped to the skill/workflow it powers:

### 1. RECON & INTELLIGENCE

| Tool | Maps To | Purpose |
|------|---------|---------|
| `api-wordlist/` `(10.5k endpoints)` | `skills/recon-basic.md` | API endpoint discovery & fuzzing |
| `api-wordlist/AI-MCP.txt` `(523 lines)` | `skills/recon-basic.md` | AI/MCP-specific endpoint discovery |
| `ripgrep-all/` | `skills/recon-basic.md` | Search inside PDFs, archives, sqlite |
| `Bug-Bounty-Agents/osint-collector.md` | `steering/recon-methodology.md` | OSINT gathering (650 lines) |
| `Bug-Bounty-Agents/recon-advisor.md` | `steering/recon-methodology.md` | Reconnaissance analyst (226 lines) |
| `Bug-Bounty-Agents/subdomain-takeover.md` | `skills/recon-basic.md` | Subdomain takeover (152 lines) |
| `Awesome-AI-Hacking-Agents/` | — | Registry of 64+ AI hacking agents to study |

### 2. OAUTH & AUTHENTICATION ATTACKS

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/jwt-cracker.md` | `methodologies/02-oauth-security-testing.md` | JWT/token attacks (144 lines) |
| `Bug-Bounty-Agents/credential-tester.md` | `skills/oauth-security-auditor.md` | Password attacks (357 lines) |
| `cybersentry/` | — | Autonomous auth scanning via 8 ReAct tools |

### 3. WEB APPLICATION ATTACKS

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/web-hunter.md` | `workflows/01-web-app-hunt.md` | Web app pentesting (297 lines) |
| `Bug-Bounty-Agents/bizlogic-hunter.md` | `workflows/01-web-app-hunt.md` | Business logic vulns (317 lines) |
| `Bug-Bounty-Agents/ssrf-hunter.md` | `workflows/01-web-app-hunt.md` | SSRF discovery (131 lines) |
| `Bug-Bounty-Agents/payload-crafter.md` | — | Custom payload generation (352 lines) |
| `Bug-Bounty-Agents/vuln-scanner.md` | — | Nuclei/Nikto/Nmap scanning (315 lines) |
| `next-16.2.4-pocs/` | — | 12 Next.js CVEs w/exploit scripts |
| `CVE-2026-42779/` | — | Apache MINA deser → RCE (CVSS 9.8) |

### 4. API SECURITY

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/api-security.md` | `workflows/02-api-security-hunt.md` | API security testing (102 lines) |
| `Bug-Bounty-Agents/graphql-hunter.md` | `workflows/02-api-security-hunt.md` | GraphQL testing (156 lines) |
| `api-wordlist/api` `(10.5k lines)` | `skills/parser-differential-tester.md` | Endpoint fuzzing wordlists |

### 5. AI / LLM ATTACKS

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/llm-redteam.md` | `methodologies/05-prompt-injection-framework.md` | LLM red-teaming (161 lines) |
| `redai/` | — | AI-assisted vuln scanner + live browser/sim validation |
| `awesome-bugbounty-mcp/` | `skills/mcp-security-auditor.md` | 12 MCP servers for bug bounty ops |
| `ironcurtain/` | — | Secure MCP agent runtime (policy engine, MITM, sandbox) |

### 6. CLOUD & INFRASTRUCTURE

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/cloud-security.md` | `steering/cloud-security-standards.md` | AWS/Azure/GCP testing (104 lines) |
| `Bug-Bounty-Agents/container-escape.md` | `steering/cloud-security-standards.md` | K8s escape (172 lines) |
| `dive/` | — | Docker image layer analysis |
| `grype/` | — | SBOM vulnerability scanning |
| `syft/` | — | SBOM generation |
| `tracee/` | — | Runtime security monitoring |
| `tetragon/` | — | eBPF process monitoring |
| `tag-security/` | — | CNCF security papers |

### 7. MOBILE

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Android-Pentesting-Skill/` `(188+ files)` | `skills/recon-basic.md` (mobile mode) | Complete Android APK audit: 37 Frida scripts, RASP bypass, CVSS 4.0 |
| `Bug-Bounty-Agents/mobile-pentester.md` | — | Mobile app security (355 lines) |

### 8. ENTERPRISE & WINDOWS

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/ad-attacker.md` | `skills/enterprise-software-auditor.md` | AD penetration testing (431 lines) |
| `Bug-Bounty-Agents/privesc-advisor.md` | `skills/enterprise-software-auditor.md` | Privilege escalation (105 lines) |
| `Bug-Bounty-Agents/binary-exploit.md` | — | Binary exploitation (74 lines) |
| `ILSpy/` | `skills/enterprise-software-auditor.md` | .NET decompilation |

### 9. CRYPTO & DEFI

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/crypto-analyst.md` | `methodologies/??` | Crypto implementation review (65 lines) |

### 10. TRAINING & PRACTICE

| Tool | Maps To | Purpose |
|------|---------|---------|
| `HackLabs/` | — | 45 intentionally-vulnerable labs (OWASP + AI) |
| `cybersentry/` | — | Autonomous scanning agent + demo |
| `Bug-Bounty-Agents/ctf-solver.md` | — | CTF challenge solver (173 lines) |

### 11. SUPPORT & VALIDATION

| Tool | Maps To | Purpose |
|------|---------|---------|
| `Bug-Bounty-Agents/poc-validator.md` | `methodologies/03-ai-self-validation.md` | PoC validation (262 lines) |
| `Bug-Bounty-Agents/exploit-chainer.md` | `methodologies/??` | Multi-step exploit chaining (291 lines) |
| `Bug-Bounty-Agents/report-generator.md` | — | Report writing (150 lines) |
| `Bug-Bounty-Agents/engagement-planner.md` | — | Test planning (75 lines) |
| `cve-lite-cli/` | — | OWASP dependency vuln scanner (offline) |
| `Vibecode-Cleaner-Fartrun/` | — | Code health scanner + safety net |
| `bugSkills/` | — | Convert H1 reports → reuseable AI skills |

---

## QUICK-START TARGETING

### STEP 1: Pick Target → Run Router
```
@workflows/00-router.md
Input: <your target URL>
→ Router recommends workflow
```

### STEP 2: Load Weapon Stack
Based on target type, load the corresponding weapon stack:

| Target Type | Skills to Load | Cloned Tools to Reference | INBOX Entries |
|------------|---------------|--------------------------|---------------|
| **Web App + OAuth** | `oauth-security-auditor` `parser-differential-tester` `ai-self-validator` | `Bug-Bounty-Agents/web-hunter.md` `Bug-Bounty-Agents/bizlogic-hunter.md` | #18, #22, #41, #7, #25 |
| **REST/GraphQL API** | `recon-basic` `parser-differential-tester` `ai-self-validator` | `api-wordlist/api` `Bug-Bounty-Agents/api-security.md` `Bug-Bounty-Agents/graphql-hunter.md` | #7, #23, #25, #41 |
| **AI/LLM App** | `prompt-injection-hunter` `mcp-security-auditor` `ai-self-validator` | `redai/` `ironcurtain/` `awesome-bugbounty-mcp/` | #38, #39, #40, #50 |
| **Android App** | `recon-basic` (mobile) `ai-self-validator` | `Android-Pentesting-Skill/` (all 188 files) `Bug-Bounty-Agents/mobile-pentester.md` | #56, #57 |
| **Crypto/DeFi** | `crypto-defi-auditor` `ai-self-validator` | `Bug-Bounty-Agents/crypto-analyst.md` | #16, #26 |
| **Cloud/Infra** | `bucket-squatting-detector` `ai-self-validator` | `grype/` `syft/` `dive/` `tracee/` `tetragon/` | #29, #30 |
| **Enterprise/.NET** | `enterprise-software-auditor` `ai-self-validator` | `ILSpy/` `Bug-Bounty-Agents/ad-attacker.md` | #19 |
| **Logic Bug / Supply Chain** | `methodologies/07-logic-bug-hunting.md` `ai-self-validator` | `tracee/` `ironcurtain/` `Bug-Bounty-Agents/bizlogic-hunter.md` `Bug-Bounty-Agents/exploit-chainer.md` | #075, #011, #042 |
| **Race Condition / Kernel** | `methodologies/07-logic-bug-hunting.md` `methodologies/03-ai-self-validation.md` | `tracee/` `tetragon/` | #076, #075 |
| **Unknown** | `recon-basic` `router-simple` `ai-self-validator` | `05-adaptive-hunt.md` + all tools | #1, #22 |

### STEP 3: Execute Methodology
```
@methodologies/<relevant-file>.md
Follow step-by-step
```

### STEP 4: Validate Everything
```
@methodologies/03-ai-self-validation.md
Challenge every finding → Aim for 80% rejection
```

### STEP 5: Exploit & Report
Build PoC → Submit report

---

## DIRECTORY STRUCTURE (Quick Reference)

```
E:\cantin MEZO\
├── bbb\                      # MAIN FRAMEWORK (72 entries, methodologies, skills)
│   ├── skills\               # 12 AI agent skills
│   ├── methodologies\        # 7 hunting methodologies
│   ├── workflows\            # 6 automated workflows
│   ├── steering\             # 7 AI steering documents
│   ├── resources\            # 00-INBOX.md (13,434 lines / 72 entries)
│   └── MASTER-OPERATIONS.md  # ← YOU ARE HERE
│
└── cloned-repos\             # 22 WEAPONS / TOOLS
    ├── Android-Pentesting-Skill\     # 188 files: Frida, RASP, MASVS
    ├── api-wordlist\                 # 10.5k API endpoints + AI/MCP wordlist
    ├── Awesome-AI-Hacking-Agents\    # 64+ AI agents registry
    ├── awesome-bugbounty-mcp\        # 12 bug bounty MCP servers
    ├── Bug-Bounty-Agents\            # 43 agent prompts
    ├── bugSkills\                    # H1 → AI skill converter
    ├── CVE-2026-42779\              # Apache MINA deser RCE PoC
    ├── cve-lite-cli\                # OWASP dependency scanner
    ├── cybersentry\                 # Autonomous ReAct pentest agent
    ├── dive\                        # Docker image analyzer
    ├── grype\                       # SBOM vuln scanner
    ├── HackLabs\                    # 45 vulnerable labs
    ├── ILSpy\                       # .NET decompiler
    ├── ironcurtain\                 # Secure MCP agent runtime
    ├── next-16.2.4-pocs\            # 12 Next.js CVEs
    ├── redai\                       # AI vuln scanner + validation
    ├── ripgrep-all\                 # Universal file search
    ├── syft\                        # SBOM generator
    ├── tag-security\                # CNCF security papers
    ├── tetragon\                    # eBPF monitoring (16k files)
    ├── tracee\                      # Runtime security
    └── Vibecode-Cleaner-Fartrun\    # Code health + safety net
```

---

## HIGH-VALUE TARGET PRIORITY (from INBOX)

| Priority | Vuln Type | INBOX # | Avg Bounty |
|----------|-----------|---------|-----------|
| **🔥 P0** | OAuth popup hijacking / redirect_uri bypass | #18 | $5k-$15k |
| **🔥 P0** | Prompt injection → data exfiltration | #38, #39 | $5k-$10k |
| **🔥 P0** | MCP security / DCR vulnerabilities | #50, #51 | $3k-$10k |
| **🔥 P0** | Multi-agent orchestration vulns | #11 | $10k+ |
| **⚡ P1** | IDOR / mass assignment | #7, #25, #41 | $2k-$9k |
| **⚡ P1** | Parser differential (WAF bypass) | #8, #34 | $3k-$8k |
| **⚡ P1** | Yandex dorking → exposed secrets | #13, #14 | $2k-$5k |
| **⚡ P1** | SSRF via PDF/image processors | #42 | $3k-$7k |
| **🔶 P2** | NoSQL injection | #23 | $2k-$5k |
| **🔶 P2** | Bucket squatting | #29 | $1k-$5k |
| **🔶 P2** | Enterprise .NET / AD vulns | #19, #20 | $5k-$30k |
| **🔶 P2** | Crypto/DeFi accounting errors | #16, #26 | $5k-$50k |
| **🔥 P0** | Race condition (kernel/app) | #076 | $20k+ |

---

## CORE PRINCIPLES

1. **Self-validate everything** — 80% of findings should be rejected before submission
2. **Build working PoCs** — No half-baked reports
3. **Quality over quantity** — 1 validated P1 > 10 rejected P4s
4. **AI-first approach** — Use the skills/agents to scale
5. **Document everything** — Every finding, every bypass, every technique
6. **Reverse Devil's Advocate** — When AI says "not exploitable", push harder. The AI doesn't know what it can't do — prove it wrong. (Entry #076 — chompie: Claude gaslit her, $20k Pwn2Own win)
7. **80% on verification, 20% on finding** — Microsoft's insight: finding bugs is solved. Proving them with zero FPs is the real challenge. Put engineering effort into debate, dedup, and prove stages. (Entry #077)
8. **Patch diffing for N-day** — A Patch Tuesday + ~$300 in API tokens + open-source tools = verified exploit. Tyler Holmwood proved one researcher can build Mythos-class capability. (Entry #078, `methodologies/08-patch-diffing-pipeline.md`)
