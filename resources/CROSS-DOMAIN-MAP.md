# Cross-Domain Vulnerability Map

> **Why this exists:** Many vulnerability classes transcend domains. A SQL injection technique you learned on web apps might work on a Web3 indexer's GraphQL API. An IDOR pattern from REST APIs might apply to smart contract function parameters. This map helps a "cracked generalist" spot cross-domain attack surfaces.

---

## Web/API → Web3/Crypto

| Web/API Vuln | Web3 Equivalent | Why The Same Pattern Works | Key INBOX Ref |
|---|---|---|---|
| **SQL Injection** | **Subgraph/Indexer Manipulation** | Web3 dApps query on-chain data via GraphQL APIs (The Graph, Subgraph). If the subgraph query builder doesn't sanitize — same injection pattern, different engine | #023, #071, #169 |
| **NoSQL Injection** | **RPC Parameter Injection** | Web3 frontends send user input to RPC nodes. Unvalidated params in `eth_call`, `getLogs`, or custom RPC methods work like NoSQL injection | #023 |
| **IDOR** | **Unvalidated `to:` / `amount:` in Transfers** | Both are "user controls an identifier the contract trusts without ownership check". Same pattern: `withdraw(amount, to)` without verifying caller owns `to` | #025, #041, #108, #123 |
| **SSRF** | **Malicious RPC Endpoint Injection** | dApps let users configure custom RPC endpoints. Server-side fetch to attacker RPC = SSRF. Also: bridge relayers fetching from untrusted URLs | #079, #122, #168 |
| **Mass Assignment** | **Unvalidated Struct Init / Storage Collision** | Solidity `initialize()` without checking `msg.sender` = same class as Rails mass assignment. Upgradeable proxy storage collisions = prototype pollution | #007 |
| **Race Condition** | **Flash Loan + Reentrancy** | Same TOCTOU pattern, different scale. Block-level vs ms-level. Flash loans are the web3 race condition enabler | #076, #088, #171 |
| **Business Logic** | **Bonding Curve / Fee Calculation** | Same class: "I assumed X about state, but Y happened". Uniswap V2 fee math, staking reward calc, curve pricing all have logic bug surface | #107, #141, #075 |
| **OAuth redirect_uri** | **Signature Verification / `permit()` Abuse** | Both trust user-supplied parameters. "Verify this signature" without checking what's being signed = OAuth "verify this redirect_uri" | #048, #053, #054 |
| **XXE** | **Off-chain Oracle XML Parsing** | Some DeFi oracles still parse XML from partner feeds. XXE in the oracle's off-chain parser = manipulate price feed | #167 |
| **File Upload** | **Malicious Metadata in Token URIs** | Same upload-to-execution flow. SVG XSS in NFT metadata, URI injection in tokenURI() | #024 |
| **Prototype Pollution** | **Storage Collision in Upgradeable Proxies** | Same "overlapping data structures" footgun. Unstructured storage in EIP-1967 proxies can collide with implementation storage | — |
| **CORS Misconfig** | **Cross-chain Bridge CORS** | Bridge API endpoints serving user-specific data with permissive CORS = same data leak class | #069 |
| **Path Traversal** | **Unvalidated Contract Address Resolution** | If a protocol resolves contract addresses from user input without validation — same traversal pattern | #024 |
| **Cache Poisoning** | **MEV / Front-running** | Web cache poisoning manipulates what others see. MEV manipulates what transactions execute before yours. Same "order manipulation" class | — |
| **CSRF** | **Cross-Contract Call (No Origin Check)** | Contracts that don't verify `msg.sender` origin = same "request coming from unexpected place" class as CSRF | #049 |
| **WAF Bypass** | **Blockchain Node Filter Bypass** | RPC nodes sometimes filter "dangerous" methods. Encoding bypasses work the same way | #127 |
| **Subdomain Takeover** | **Unclaimed Contract Name / ENS** | Unregistered ENS name pointing to attacker contract = same takeover class | #081, #112 |
| **Re-entrancy** | **VM/Module-Originated Callback Re-entry** | **NEW: EVMCallbackReentry** — Chain-level precompiles/modules that execute during user EVM callbacks (ERC20 transfer, etc.) can be re-entered via delegatecall. The module sets a context flag (`IsVMSenderCtx`) on entry; any mutable precompile path that skips the guard is vulnerable. **Discovered by user on NibiruChain: $200k at risk, $15k bounty.** Prime example: malicious ERC20 transfer() delegatecalls FunToken precompile's bankMsgSend during module-originated transfer callback. **Fix**: `assertNotVMCaller` guard on all mutable precompile methods. **Virtuals equivalent**: `_swapTax` callback in AgentTokenV4 during Uniswap V2 swap → re-enters `onlyRouter`-protected FPairV2 (V-003). | User's Nibiru disclosure, V-003 |
| **ATO (Password Reset)** | **Web3 Admin/Backend ATO** | **NEW: PasswordResetATO** — Password reset flaws (email manipulation, host header poison, token reuse, IDOR, race condition) apply directly to Web3 project admin panels (Strapi, Privy, custom dashboards). Same techniques, same endpoints (`/forgot-password`, `/api/auth/reset`). **Target**: acpx.virtuals.io Strapi admin. | ATO-Via-Password-Reset repo, #089 |

---

## Web/API → AI/LLM Security

| Web/API Vuln | AI Equivalent | Why The Same Pattern Works | Key INBOX Ref |
|---|---|---|---|
| **SQL Injection** | **Prompt Injection** | Both inject unvalidated user input into a parser/executor. SQL injection → database. Prompt injection → LLM context | #044, #070 |
| **SSRF** | **MCP Tool Invocation** | AI agents fetch URLs or invoke tools based on user prompts. SSRF pattern: "fetch this URL" → internal service | #052, #168 |
| **IDOR** | **Agent Tool Authorization Bypass** | Agent uses wrong tool context (read where write needed) = same "user accesses resource they don't own" | #107 |
| **Race Condition** | **Agent Race / Tool Confusion** | Agent running parallel tool calls with shared state = same TOCTOU class | #076 |
| **Mass Assignment** | **System Prompt Injection** | Both set fields the developer didn't intend to be user-controllable | — |
| **Open Redirect** | **Tool Output Redirect Poisoning** | Agent trusts tool output → follows malicious redirect | #168 |
| **CSRF** | **Cross-Agent Request Forgery** | One agent triggers another agent's action without proper origin validation | #049 |
| **XXE** | **Document Upload → Parser Exploit** | AI systems parse uploaded DOCX/PDF/SVG = same XXE surface | #167 |

---

## Web/API → Mobile Security

| Web/API Vuln | Mobile Equivalent | Why The Same Pattern Works | Key INBOX Ref |
|---|---|---|---|
| **IDOR** | **Deep Link IDOR** | Mobile deep links pass user IDs same as web API params | #108 |
| **SSRF** | **WebView URL Loading** | Mobile apps load URLs in WebViews from user-supplied input | #168 |
| **OAuth Hijacking** | **Custom URL Scheme Hijacking** | Android/iOS custom URL schemes intercept OAuth callbacks same as web | #018, #064 |
| **Insecure Storage** | **SharedPreferences / Keychain** | Hardcoded tokens/keys in mobile storage = same class as exposed .env | #035 |

---

## Web/API → Enterprise / AD

| Web/API Vuln | Enterprise/AD Equivalent | Why The Same Pattern Works | Key INBOX Ref |
|---|---|---|---|
| **IDOR** | **ACL Bypass** | Mismatch between user identity and resource permission | #108, #094 |
| **SSRF** | **NTLM Relay** | Make server auth to attacker = same "make server connect to me" | #168, #094 |
| **CSRF** | **Kerberos Delegation Abuse** | Trusting an authentication token from the wrong context | #049 |
| **Injection** | **LDAP Injection** | Unvalidated input → directory service query | — |
| **Deserialization** | ** .NET / Java Deserialization in AD** | Same class of bug, different enterprise stack | #032 |

---

## Source Repositories for Cross-Domain Learning

| Repository | # Writeups | Best For |
|-----------|-----------|----------|
| [Awesome-Bugbounty-Writeups](https://github.com/devanshbatham/Awesome-Bugbounty-Writeups) | 700+ | Web2 patterns → adapt to Web3. Deep writeups in XSS, IDOR, SSRF, Race Conditions, RCE, Auth Bypass |
| [claude-code-security-review](https://github.com/anthropics/claude-code-security-review) | N/A (tool) | CI/CD security review workflow with 3-phase analysis + FP filtering |
| [offensive-claude](https://github.com/hypnguyen1209/offensive-claude) | 47 refs | 25 skills covering full offensive lifecycle; 47 vulnerability reference files with vulnerable/secure examples |
| [xalgorix](https://github.com/xalgord/xalgorix) | N/A (platform) | 22-phase autonomous security testing methodology |
| [CDSecurity Skills](https://github.com/CDSecurity/cdsecurity-skills) | N/A (tools) | Pre-audit readiness checklists for Solidity + Rust/Solana |

---

## When To Use This Map

1. **You find a web vuln but can't escalate it** → Check if the same pattern has a Web3/Cloud/Mobile equivalent
2. **You're testing a Web3 dApp frontend** → SQLi check on the subgraph GraphQL endpoint (#023), SSRF check on custom RPC (#168)
3. **You're testing an AI agent** → Prompt injection (#044), MCP SSRF (#052)
4. **You want to maximize impact** → Chain a web vuln into a Web3 vuln (e.g., SSRF the bridge API → leak validator keys)
5. **You're stuck** → Switch domains but keep the same technique. The pattern is the same, the target changes.
