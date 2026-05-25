# Vulnerability Type Index — "When Stuck" Lookup

> **How to use:** You're working on a bug bounty target. You're stuck on a particular vulnerability type. Look up the vuln class below to find the exact INBOX entries, workflows, methodologies, and skills to unblock you.

---

## XSS (Cross-Site Scripting)

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Reflected XSS basics** | #010 | Intigriti's favorite vuln — methodology |
| **Content-Type / image XSS** | #045 | Google AI Studio — access token leak via iframe |
| **Parser differential (two parsers disagree)** | #057 | Query string differentials → XSS |
| **DOM XSS → ATO chain** | #068 | GIS SDK DOM XSS escalated to account takeover |
| **CSPT / Cloudflare abuse** | #069 | Cloudflare Image Proxy as CSPT gadget |
| **CSP bypass** | #062 | Weird CSP bypass → $3.5k bounty |
| **Universal XSS (browser)** | #058 | Samsung Browser uXSS CVE-2025-58485 |
| **Sanitizer API bypass** | #170 | Chrome Sanitizer API: xlink:href + URL reparsing |
| **Blind XSS** | #144 | BlindXSS Dorker — recon tool for blind XSS points |
| **Filter/WAF bypass** | #175 | 150+ XSS writeups collection from Awesome-Bugbounty-Writeups |

**Workflows:** `01-web-app-hunt.md` (Phase 3 — client-side testing)
**Skills:** `parser-differential-tester.md`
**Methodologies:** `07-logic-bug-hunting.md`

---

## SSRF (Server-Side Request Forgery)

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **SSRF basics / playbook** | #168 | theXSSrat's full SSRF playbook (6 steps) |
| **Next.js WebSocket SSRF** | #079 | NextSSRF CVE-2026-44578 scanner |
| **Unauthenticated SSRF via CORS** | #122 | /api/cors on demo subdomains |
| **Blind SSRF detection** | #168 | Timing + Collaborator pingbacks technique |
| **SSRF → metadata creds** | #168 | 169.254.169.254 pivot |
| **SSRF → RCE escalation** | #052 | MCP tree deep dive — SSRF in agent infra |
| **Blocklist bypass** | #168 | Decimal IP, IPv6, 302 redirect bypasses |
| **Cloud SSRF patterns** | #047 | MCP server SSRF patterns |
| **AI scanner routing-based SSRF** | #182 | Host header manipulation + prompt injection → scanner as SSRF pivot inside internal network |

**Workflows:** `02-api-security-hunt.md`, `03-ai-app-hunt.md`
**Methodologies:** `06-mcp-security-audit.md`
**Skills:** `mcp-security-auditor.md`

---

## IDOR (Insecure Direct Object Reference)

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **IDOR basics / methodology** | #108 | Ultimate 12-phase IDOR testing checklist |
| **Export functionality (goldmine)** | #025 | Export features = parametric IDOR |
| **Google support IDOR ($14k)** | #041 | Hacking Google Support — leaking millions |
| **Front-end secrets + IDOR** | #123 | skraft9 API key leak + IDOR chain |
| **Mass data exposure** | #106 | showAllAccounts.json production data leak |
| **Old program → new IDOR** | #040 | $9k from old Bugcrowd program |

**Workflows:** `01-web-app-hunt.md`, `02-api-security-hunt.md`
**Skills:** `recon-basic.md`

---

## OAuth / Authentication

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **OAuth popup hijacking** | #018 | Predictable window.open() target |
| **redirect_uri double-decode** | #048 | One-click account takeover |
| **Non-happy path ATO ($3k)** | #053 | Edge cases in OAuth flow |
| **Drilling redirect_uri** | #054 | Deep methodology on redirect_uri testing |
| **Token theft via referrer** | #059 | Chrome 0-day referrer policy override |
| **CSS data exfiltration for tokens** | #060 | $9.7k — stealing OAuth tokens with CSS |
| **Reverse proxy hijack** | #064 | OAuth code interception via proxy |
| **1-click client takeover ($13k)** | #117 | Henhouse UI OAuth client takeover |
| **Puny-code 0-click ATO** | #056 | International domain ATO |
| **DNS rebinding ATO** | #063 | Account takeover with DNS rebinding |
| **Password reset checklist** | #089 | Complete password reset testing |
| **Email param manipulation** | ATO-Via-Password-Reset | Array `["victim","attacker"]`, `\r\n` injection, JSON duplicate keys, `%0aBcc:` → token sent to attacker |
| **Host header poisoning** | ATO-Via-Password-Reset | Reset links generated with `Host: attacker.com` → victim clicks attacker's reset URL =
 token leak |
| **Reset token reuse** | ATO-Via-Password-Reset | Same token accepted after password change = full ATO |
| **IDOR in reset endpoint** | ATO-Via-Password-Reset | Change `user_id` in final reset request to takeover any account |
| **Race condition** | ATO-Via-Password-Reset | Two simultaneous reset requests = token mix-up |
| **Rate limit bypass** | ATO-Via-Password-Reset | Brute-force reset tokens by bypassing rate limits (X-Forwarded-For, header spoofing) |
| **Hidden reset APIs** | ATO-Via-Password-Reset | Scan for `/api/su/resetPwd`, `/admin/reset`, `/graphql` mutations |
| **Email canonicalization** | ATO-Via-Password-Reset | `victim+1@gmail.com`, `vіctim@gmail.com` (unicode) → bypass exact-match checks |
| **Password reset CSRF** | ATO-Via-Password-Reset | If no CSRF token → victim visits attacker page → password changed silently |
| **OTP bypass: stateless verificationId** | #178 | Identity field swap at verification step — verificationId not bound to user server-side |
| **OTP bypass: verification logic flaw ($3k)** | #183 | Swap loginId in PUT body at final verification — server trusts re-supplied identity |

**Workflows:** `01-web-app-hunt.md`
**Methodologies:** `02-oauth-security-testing.md`
**Skills:** `oauth-security-auditor.md`
**Steering:** `oauth-security-standards.md`

---

## SQL / NoSQL Injection

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **NoSQL injection basics** | #023 | Traceix writeup — first NoSQLi experience |
| **Multi-tenant SQL pod escape** | #071 | SQL injection → cluster pod escape |
| **Drupal pre-auth SQLi (Postgres)** | #169 | CVE-2026-9082 — boolean blind + error-based |
| **Web3 backend injection** | CROSS-DOMAIN-MAP | Web SQLi techniques that work on crypto backends |
| **SQLi reference collection** | #175 | 30+ SQLi writeups from Awesome-Bugbounty-Writeups |
| **XML error-based blind SQLi** | #179 | DeepSeek V4 Pro trick: CASE WHEN + XMLAgg for YES/NO oracle — WAF bypass via XML errors, sqlmap false positive → 19 databases |

**Workflows:** `02-api-security-hunt.md`
**Cross-Domain:** Web SQLi → NoSQLi on Web3 indexer backends (see CROSS-DOMAIN-MAP.md)

---

## Logic Bugs & Business Logic

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Logic bug hunting methodology** | #141 | Deep dive — 0X02MAR / Omar Ahmed |
| **Orange Tsai $175k chain** | #075 | 4 logic bugs → Edge sandbox escape |
| **Multi-agent for logic bugs** | #011 | LLM agents finding 30+ CVEs |
| **ATO/business logic dork** | #107 | Business logic flaw patterns |
| **Logic bug categories** | #075 | State confusion, TOCTOU, atomicity, assumption |
| **Mass assignment = logic** | #007 | Mass assignment privilege escalation |
| **Export/IDOR = logic** | #025 | Export functionality as logic bug surface |
| **Race condition logic** | #088 | Bypass free plan restrictions |
| **Bridge logic patterns** | #131 | Cross-chain bridge accounting logic |
| **Solana router logic ($ drain)** | #016 | Router accounting + decimal precision |

**Workflows:** `04-crypto-hunt.md`, `05-adaptive-hunt.md`
**Methodologies:** `07-logic-bug-hunting.md`
**Skills:** `crypto-defi-auditor.md`

---

## Web3 / DeFi / Smart Contracts

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Oracle manipulation basics** | #166 | $1.22B stolen — complete guide |
| **dYdX v4 oracle hijacking** | #027 | Case-sensitivity → oracle takeover |
| **ElevateFi EFI postmortem** | #171 | Spot price manipulation → $2.5M fake principal |
| **Solana router critical bugs** | #016 | Router accounting + decimal precision |
| **DeFi bridge fake mint ($628k)** | #116 | Signed wrapping abuse |
| **Bridge logic patterns** | #131 | Mapping bridge attack surface |
| **Smart contract audting resources** | #095 | Ethereum/Solidity Security collection |
| **64 DeFi exploit analyses** | #099 | DarkNavy's web3-exploit-analysis |
| **CDSecurity Solidity/Solana skills** | #164 | Audit prep skills for Solidity + Solana |
| **AI x Web3 security tools** | #165 | 49 AI auditor tools for smart contract review |
| **Mezo Network stale overwrite** | #134 | StateDB bug → full L1 bridge drain |
| **Statemind $350M whitehat** | #133 | Avalanche native asset call precompile |
| **Staking vault oracle exploit** | #171 | Live 2026 exploit — spot price in stakeEFI() |
| **Immunefi payout model** | #132 | How 10% of funds-at-risk is calculated |
| **High-ROI crypto targets** | #129 | Memory-style bugs on Immunefi |
| **Lombard BTC.b analysis** | #130 | Full bridge target evaluation |
| **EVMCallbackReentry (NEW)** | User's Nibiru disclosure | **Critical pattern**: Module-originated calls (chain-level precompiles) during user EVM callbacks (ERC20 transfer, etc.) can be re-entered via delegatecall. The chain sets `IsVMSenderCtx` flag; any mutable path that skips the guard = drain. User found $200k bug, $15k bounty. **Virtuals equivalent**: `_swapTax` callback → Uniswap V2 swap → re-enter FPairV2 (V-003). **Trigger**: "Does the system/contract initiate a privileged call during a user callback window?" |
| **Password Reset ATO (NEW)** | ATO-Via-Password-Reset repo | Complete password reset methodology: email manipulation (array, \r\n, JSON), host header poison, token reuse, IDOR, race conditions, rate-limit bypass, hidden API scanning, referrer manipulation, email canonicalization bypass, CSRF. **Apply to**: Strapi admin panels, Web3 dashboards, Privy auth flows. **Our target**: acpx.virtuals.io Strapi forgot-password endpoint. |
| **SquidRouterModule safe drain (~$3M)** | #176 | 86 Gnosis Safes drained via executeSameChainActions() delegatecall impersonation — Foundry exploit contracts |
| **WUSD/GLOVE sybil reward abuse (~$19.7k)** | #177 | _englove() called before fund pull — balance-based gate bypassed with fresh helper addresses |

**Workflows:** `04-crypto-hunt.md`
**Methodologies:** `07-logic-bug-hunting.md`
**Skills:** `crypto-defi-auditor.md`
**Cross-Domain:** Also check SQL/SSRF/IDOR indexes — many web2 techniques apply to web3 off-chain components

---

## Prompt Injection / AI Security

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Prompt injection framework** | #044 | 3-step methodology (extracted as 05-prompt-injection-framework.md) |
| **MCP security deep dive** | #052 | Model Context Protocol vulnerabilities |
| **Google Tasks prompt injection** | #070 | Google Chat → Tasks injection |
| **MCP server list** | #047 | Awesome Bug Bounty MCP Servers |
| **LLM security handbook** | #104 | SecureNexusLab V1.0 |
| **SVEN adversarial testing** | #103 | Hardening + adversarial testing for code LLMs |
| **612 academic papers** | #109 | Awesome-LLM4Cybersecurity |
| **Claude Code source leak** | #087 | What was inside — full analysis |
| **Claude Code + AWS creds leak** | #082 | Critical: creds leaked to every subprocess |
| **Offensive Claude toolkit** | #173 | 25 skills, 6 agents, 47 vuln references |
| **AI scanner indirect prompt injection** | #182 | Full methodology: inject stored content → AI scanner performs destructive actions / exfiltrates data |
| **AI scanner routing-based SSRF** | #182 | Host header manipulation + prompt injection → scanner as programmable SSRF vector inside internal network |
| **PortSwigger AI scanner labs** | #185 | 3 hands-on labs (Apprentice ×2, Practitioner ×1) for AI scanner exploitation |

**Workflows:** `03-ai-app-hunt.md`
**Methodologies:** `05-prompt-injection-framework.md`, `06-mcp-security-audit.md`
**Skills:** `prompt-injection-hunter.md`, `mcp-security-auditor.md`
**Steering:** `ai-security-testing.md`

---

## Race Conditions

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Race condition → free plan bypass** | #088 | API race condition for subscription bypass |
| **RHEL race condition privesc ($20k)** | #076 | Pwn2Own kernel race condition |
| **Web3: flash loan + race** | #171 | ElevateFi — same TOCTOU, block-level |
| **Race in crypto contexts** | CROSS-DOMAIN-MAP | Race condition → reentrancy, flash loan abuse |

**Workflows:** `05-adaptive-hunt.md`
**Methodologies:** `07-logic-bug-hunting.md`

---

## Dependency Confusion / Supply Chain

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Attack file list** | #020 | Classic dependency confusion targets |
| **Extended file list** | #036 | More targets + patterns |
| **npx confusion (new)** | #172 | Binary name ≠ package name — AI agent risk |
| **OWASP CVE Lite** | #029 | Dependency scanner CLI |
| **Supply chain logic chain** | #075 | Orange Tsai supply chain logic chain |

---

## XXE

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **XXE complete guide** | #167 | 8 techniques: basic → second-order XXE, UTF-7, external DTD, PHP wrappers |
| **XXE → SSRF pivot** | #167 | SSRF section within XXE guide |
| **XXE → RCE (PHP)** | #167 | expect://, php://filter, phar:// wrappers |
| **Second-order XXE** | #167 | Store in async queue, execute later |
| **Cross-domain: web3** | CROSS-DOMAIN-MAP | Off-chain oracle XML parsing in DeFi |

**Workflows:** `01-web-app-hunt.md`, `02-api-security-hunt.md`

---

## Operational Security (OpsSec)

| When Using... | Tool/Ref | What It Gives You |
|---|---|---|
| **Command-line obfuscation (EDR bypass)** | ArgFuscator | Obfuscates command-line args for 68 Windows executables to bypass AV/EDR detections. Techniques: character substitution, option char substitution, quote insertion, character deletion, path traversal, URL manipulation. Shell-independent; obfuscation passes through to EDR telemetry. Run exploit tools without getting blocked. |
| **LNK file spoofing** | lnk-it-up | 5 LNK spoofing variants. Target field shows one file, executes another. For phishing-based initial access. Variant 4 (Unicode target) is most powerful: full target spoof + command-line hiding. |

---

## Memory Corruption / Binary Exploitation

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Chrome 0-day V8 RCE ($55k)** | #042 | Omitted write barrier |
| **ESXi memory corruption ($200k)** | #128 | Cross-tenant code execution |
| **Pwn2Own SharePoint chain** | #126 | 2-bug chain |
| **Linux kernel LPE** | #026 / #105 | CVE-2026-31431 — copy fail (basic + deep dive) |
| **Buffer overflow resources** | #175 | 7 buffer overflow refs from ABW |

**Workflows:** `05-adaptive-hunt.md`

---

## Reconnaissance

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Yandex dorking** | #004, #013 | Advanced OSINT via Yandex |
| **Subdomain enumeration** | #112 | Subdomain enum + httpx toolchain |
| **TLS + Wayback + Google dork** | #115 | Hidden subdomains methodology |
| **Subdomain takeover checker** | #081 | mikaww1 tool |
| **WordListeXplorer** | #092 | Local wordlist intelligence |
| **Browser-based recon** | #125 | bugbounty.zip toolkit |
| **Email/user enumeration** | #086 | Hidden API endpoint discovery |
| **Tool list** | #043 / #090 | Burp + ffuf + nuclei consensus |
| **One-liner scripts** | awesome-oneliner-bugbounty | Collection of single-line commands: LFI, XSS, Open Redirect, Prototype Pollution, CVE scan (CVE-2020-5902, CVE-2020-3452, CVE-2022-0378), subdomain enumeration (RapidDNS, crt.sh, BufferOver, VirusTotal, CertSpotter), JS endpoint extraction, CORS misconfig, port scanning (naabu), subdomain takeover, custom wordlist generation, hidden admin panels, swagger.json endpoint extraction |
| **Subdomain takeover playbook** | #181 | Complete: subfinder + amass + crt.sh → dnsx CNAME → subzy/nuclei → confirm → report |
| **CSP header admin takeover** | #180 | CSP connect-src/img-src reveal backend CMS origin → /admin/register open → full admin |

**Workflows:** `01-web-app-hunt.md` (Phase 1)
**Skills:** `recon-basic.md`, `yandex-recon-specialist.md`
**Steering:** `recon-methodology.md`

---

## Target Evaluation & Strategy

| When Stuck On... | INBOX Entry | What It Gives You |
|---|---|---|
| **Full methodology 2026** | #022 | Comprehensive framework |
| **Submission optimization** | #120 | Former H1 triager AMA |
| **Target feasibility ranking** | #135 | Will-it-leak scoring |
| **Lombard bridge analysis** | #130 | Full target evaluation template |
| **MoonPay campaign** | #110 | Active campaign notes |
| **BitMEX evaluation** | bitmex-evaluation.md | External target eval file |
| **High-ROI crypto targets** | #129 | Immunefi-focused target selection |

---

## Generic "I'm Stuck" Recovery

> When nothing above helps, in order:

1. **Run adaptive workflow**: `05-adaptive-hunt.md` — tries everything
2. **Launch parallel agents**: #033 (43 specialized prompts), #001 (multi-agent orchestration)
3. **Change vuln class entirely**: If XSS is blocked, switch to OAuth. If OAuth is hardened, try SSRF.
4. **Change target domain**: Web bugs → same techniques on Web3 off-chain infra
5. **Ask the router**: `00-router.md` — feed it different target characteristics
6. **Check CROSS-DOMAIN-MAP.md**: Web vuln → Web3 equivalent mapping
