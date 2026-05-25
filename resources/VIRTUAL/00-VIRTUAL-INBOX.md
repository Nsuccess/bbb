# Virtuals Protocol — Dedicated Resource Inbox

Entries extracted from main INBOX.md for Virtuals Protocol audit.

---

### Entry #136 — Virtuals Protocol: 17,000 AI Agents, One Critical Bug Ignored

**Source:** CoinSpeaker, BitcoinInsider, Hindenrank risk grade, Cantina audit
**Date Added:** 2026-05-17
**Type:** Writeup, AI Agent Platform, Bug Bounty
**Priority:** High

**Content:**

Virtuals Protocol is an AI agent tokenization platform on Base (Coinbase L2). Users create, launch, and monetize AI agents as tokenized entities. 17,000+ agents created, $39.5M cumulative revenue.

**The Bug (January 2025):**
- Pseudonymous researcher Jinu found a critical bug in audited smart contract
- Insufficient validation in AgentToken creation — internal bond threshold
- If exploited, would block ALL new agent token creation
- Team initially had NO bug bounty, closed the vulnerability-reporting Discord
- Jinu went public on X
- Team finally fixed it, apologized, promised bounty
- VIRTUAL token dropped 8%

**Current Security Status:**
- Active bug bounty at security@virtuals.io
- Working with Immunefi on formal program
- Cantina audit completed (May 2025)
- Hindenrank risk grade: C (high risk)
- Risk scenarios identified: VIRTUAL death spiral via agent ecosystem contagion

**Why This Matters:**
- 17,000+ agent tokens = enormous attack surface
- Bonding curve + Uniswap V2 = DeFi mechanics with AI agents = novel risk
- Team's initial response was poor (ignored researcher) — suggests other bugs may exist
- Prompt injection in agent interactions could lead to financial manipulation
- All agent tokens paired exclusively against VIRTUAL = single point of failure

**Attack Vectors:**
1. Agent token creation validation bypass (already found once, likely more variants)
2. Bonding curve manipulation (price oracle for agent tokens)
3. Cross-agent prompt injection leading to unauthorized trades
4. veVIRTUAL governance not yet live — centralized treasury control
5. Agent revenue settlement logic flaws

**Relevance:** High-volume, high-surface target with proven bug history and poor initial security response. Agent tokenization is novel = less battle-tested. Team now more receptive. Good parallel target to bridges.

---

### Entry #137 — Hybrid Attack: Memory Corruption + Morse/Encoded Prompt Injection on AI Agent Platforms

**Source:** NeuralTrust, Cyera Bleeding Llama, Grok/Bankrbot incident (May 2026)
**Date Added:** 2026-05-17
**Type:** Attack Vector, AI Agents, Prompt Injection, Memory Corruption
**Priority:** Medium

**Content:**

**Real Precedent (May 2026):**
Attacker used Morse code in a tweet posted to Grok (X's AI). Grok translated the Morse, output the malicious instruction ("transfer all funds to attacker"), which triggered Bankrbot (an autonomous crypto agent) to execute a ~$150–$200k drain. No key theft, no smart contract bug — pure prompt injection via obfuscated encoding.

**Theoretical Chain (Memory + Obfuscation):**
1. Attacker feeds obfuscated input (Morse, base64, emoji encoding) to an AI agent platform (Kite, Virtuals, OpenClaw)
2. LLM decodes the input and generates a malicious intent/transaction
3. If the agent runs in Wasm or a runtime with memory safety issues (Ollama's Bleeding Llama heap OOB — May 2026), the crafted input triggers a buffer overflow/UAF
4. Memory corruption leaks session keys or overwrites permission checks
5. Agent's wallet drained within delegated spending limits

**Brutal Rating: 4.5/10**
- Morse code is a gimmick, not a killer technique (filters adapt fast)
- Memory corruption in production AI runtimes is hard to trigger reliably
- Impact is narrower than protocol drains (limited to agent wallets)
- But: Novel surface, works on fresh/unaudited platforms
- Best used as: "prompt injection with fancy encoding" rather than expecting reliable memory chains

**Practical Application:**
- Test on OpenClaw (CVE-2026-25253 — RCE/token exfiltration already proven)
- Test on Virtuals Protocol (agent-to-agent interactions)
- Test on Kite Passport delegation flows with obfuscated inputs
- Don't expect memory corruption chain — focus on obfuscated prompt injection bypassing filters

**Relevance:** The Grok/Bankrbot incident proves obfuscated prompt injection works in the wild. For our purposes, this is a supplementary attack vector, not primary. Focus on bridge logic bugs for highest ROI, use obfuscated prompt testing as a secondary technique on agent platforms.

---

### Entry #138 — Target Synthesis: Where to Hunt After MoonPay

**Source:** All entries #124–#137 synthesis
**Date Added:** 2026-05-17
**Type:** Strategy, Decision
**Priority:** HIGH

**Content:**

#### Recommendation Matrix

| Target | Why | Attack Surface | Leak Probability | Effort |
|--------|-----|---------------|-----------------|--------|
| **Mezo** | Already leaked (Critical stale state bug), Cantina bounty, BTC bridge + hybrid stack | Bridge precompile, Cosmos/EVM state, Wormhole NTT | 🔥 HIGHEST | MEDIUM |
| **Lombard BTC.b** | $230M+ TVL, recent CCIP migration, Medium audit findings = deeper bugs exist | UTXO→EVM, Consortium consensus, CCIP message validation | 🔥 HIGH | HIGH |
| **Virtuals Protocol** | 17K agents, poor initial security response, novel agent tokenization | Bonding curves, agent creation, cross-agent interactions | 🟡 HIGH | MEDIUM |
| **Kite AI** | Fresh mainnet, complex delegation logic, Halborn found 2 Criticals | Agent Passport, x402, state channels, delegation | 🟡 MED | HIGH |
| **Somnia** | Recent contest zero findings — harder | High-perf EVM, PBFT consensus | 🟢 LOW | HIGH |
| **Canton** | Institutional, permissioned, Daml — gated | Daml smart contracts, synchronizer | 🟢 LOW | VERY HIGH |

#### Suggested Order of Operations

**Phase 1 (Immediate): Mezo + Virtuals Protocol**
- Mezo: Study the stale state advisory (GHSA-6447). Look for similar state desync patterns in Lombard and other bridges. BTC vs ERC-20 asymmetry is a pattern to hunt.
- Virtuals: Test agent creation flows, bonding curve math, prompt injection in agent interactions.

**Phase 2 (Parallel): Lombard BTC.b Bridge**
- Map the full deposit → validation → mint → redeem flow
- Fuzz CCIP message handling (offchain data validation — already had Medium findings)
- Test Consortium approval edge cases
- Check for BTC/ERC-20 asymmetry in their bridge code

**Phase 3 (If Time): Kite AI — Obufscated Prompt Testing**
- Test Passport delegation flows with encoded inputs
- Check agent session key handling
- Test x402 protocol edge cases

**Techniques to Apply (From Our Framework):**
- `02-api-security-hunt.md` — API endpoint discovery for bridge infrastructure
- `07-logic-bug-hunting.md` — State confusion, TOCTOU, privilege confusion on bridge flows
- `09-submission-format.md` — Raw HTTP format for all submissions
- Entry #131 — Bridge logic bug patterns (burn/mint desync, confirmation races)
- Entry #137 — Obfuscated prompt injection for AI agent platforms

---

### Entry #139 — Verus-Ethereum Bridge $11.58M Exploit (May 18, 2026): Missing Source-Value Validation

**Source:** Cointelegraph, Blockaid, PeckShield, ExVul, X posts
**Date Added:** 2026-05-19
**Type:** Bridge Exploit, Case Study, Solidity
**Priority:** CRITICAL

**Content:**

Verus Protocol's Ethereum bridge was exploited on May 18, 2026 for ~$11.58M. The attacker made one tiny real transaction on Verus (~$10 in fees) to get a real `txid`, crafted a `PartialTransactionProof`, and submitted it to the Ethereum bridge contract via `submitImports()` → `proveImports()`.

**What the bridge checked:**
- ✅ Proof's state root matches Verus chain
- ✅ Hash matches (keccak256(serializedTransfers) matches export's hashtransfers commitment)

**What the bridge NEVER checked:**
- ❌ "Is this txid actually backed by $11.58M locked on Verus?"
- ❌ Source-chain export's actual economic backing before releasing assets

**Root Cause:**
Missing source-amount validation in `checkCCEValues` — ~10 lines of Solidity to fix. The bridge verified proof validity and hash commitment matching, but did NOT validate that the source-chain export carried sufficient locked/burned value. Fork of Nomad/Wormhole exploit pattern (fake transfer instructions believed real).

**Stolen:**
- 1,625 ETH, 103 tBTC, 147,000 USDC → all swapped to 5,402 ETH (~$11.4M)
- Attacker funded via Tornado Cash

**Contract:** Verus-Ethereum bridge at 0x715185
**Repository:** https://github.com/VerusCoin/Verus-Ethereum-Contracts (fully open source — confirmed by lead dev)
**Detection:** Blockaid + PeckShield identified within hours

**Key Lessons:**
1. Bridges must validate that source exports carry sufficient economic backing, not just proof validity and hash matching
2. "The proof was real. The money behind it wasn't." — attacker exploited trust in proof verification without value verification
3. 10 lines of missing Solidity = $11.58M loss. This is the exact class of bug to hunt in Lombard, Mezo, and all bridges
4. Pattern identical to Nomad $190M and Wormhole $325M exploits from 2022
5. Follows Kelp DAO $292M LayerZero exploit (April 2026) — bridge bugs are the #1 crypto hack vector in 2026
6. ExVul recommendation: "Cross-chain import proofs must bind every downstream transfer effect to authenticated payload data before execution"

**Relevance:** Directly applicable to every bridge target (Lombard CCIP, Mezo Wormhole NTT). Check if source-value backing is validated against destination payouts. The "missing ~10 lines of Solidity" pattern is low-hanging fruit.

---

### Entry #140 — Pwn2Own Berlin 2026: Orange Tsai Logic Bug Chaining Dominates

**Source:** ZDI blog (Days 1-3), various X posts
**Date Added:** 2026-05-19
**Type:** Exploit Development, Logic Bugs, Contests
**Priority:** HIGH

**Content:**

Pwn2Own Berlin 2026: 47 zero days, ~$1.3M total payouts over 3 days. DEVCORE (Orange Tsai) won Master of Pwn with 50.5 points / $505k+.

**Day 1 ($523k, 24 zero days):**
- Orange Tsai: **4 logic bug chain** for Microsoft Edge sandbox escape ($175k) — NOT memory corruption. Abused permission handling and data flow inside the sandbox. No crashes, no traditional exploits. Pure logic.
- Also: LiteLLM, OpenAI Codex, NVIDIA, Windows 11 PE

**Day 2 ($385k, 15 zero days):**
- Orange Tsai: **3-bug chain** for full RCE as SYSTEM on Microsoft Exchange ($200k). Attacker could take over entire Exchange server remotely.

**Day 3 ($390k, 8 zero days):**
- STAR Labs (Nguyen Hoang Thach): VMware ESXi **cross-tenant memory corruption** ($200k) — memory corruption bug breaking VM isolation
- Orange Tsai: SharePoint exploit

**Key Takeaway for Us:**
1. **Logic bugs are beating memory corruption** in payout value at Pwn2Own. Orange Tsai's 4-logic-bug chain for Edge sandbox escape proves pure logic can bypass sandboxes without any memory corruption.
2. This validates our Orange Tsai-style chaining methodology from `07-logic-bug-hunting.md`
3. Bridge logic bugs (Verus-style) are the crypto equivalent — validation flow abuse without memory corruption
4. VMware memory corruption cross-tenant = relevant for crypto node infrastructure (validators, bridge keepers)
5. AI tools (LiteLLM, Codex) already being targeted — agent platforms will follow

**Relevance:** Pwn2Own 2026 is a data point: logic bugs are the highest-ROI skill. Orange Tsai made $505k in 3 days chaining logic bugs. Apply same mindset to bridge flows — chain validation gaps for critical impact.

---

### Entry #141 — Logic Bug Hunting Methodology Deep Dive (0X02MAR / Omar Ahmed)

**Source:** Medium article by Omar Ahmed (0X02MAR), Sep 17 2024
**Date Added:** 2026-05-19
**Type:** Methodology, Logic Bugs, Recon
**Priority:** HIGH

**Content:**

Detailed methodology from a Bugcrowd hunter who focuses exclusively on logic bugs (IDOR, privilege escalation, race conditions).

**Core Principle: Recon is 90% of finding bugs.**

**Phase 1: Deep Recon (10-14 days)**
- Read ALL getting started articles, help center, how-to articles, academy courses
- Understand the application as a professional user — not a hacker
- Look for "things between the lines" that hint at edge cases
- **Tool: Xmind** — take organized notes mapping user types, plans, features, and relationships between them
- "I use Xmind more than Burp Suite"
- Map: different account types (Business vs General), different plans (Premium vs Free), and which features belong to each

**Phase 2: Scenario Generation**
- Draw attack trees in Xmind: which user type can access which feature?
- Test cases for each function (read/edit/delete):
  - High-Priv user → different High-Priv user
  - Low-Priv user → High-Priv user
  - Low-Priv user → different Low-Priv user
- Test blocked features on unconfirmed accounts (ID, email, phone)
- Test premium features on free accounts (capture premium API requests, replay on free)
- Race conditions on creation limits
- Re-test previously fixed vulnerabilities

**Phase 3: Testing**
- "When things are clear, testing will be the easiest stage"
- Implement 5-10 scenarios per day
- Document everything

**Why Logic Bugs Are Better:**
- Harder to fix than injection bugs — teams often can't properly fix privilege escalation
- Old public programs still infected with them
- New/recently added functions are most likely to have them

**Key Quotes:**
- "Accept boredom, maybe it will be with you all the way"
- "Read until you feel that you understand why users use this application"

**Relevance:** Adapt this methodology for bridge/agent platform testing. Spend 10-14 days reading docs, mapping architecture, and generating scenarios in Xmind before writing a single test. For Virtuals: read all docs, map user roles vs agent roles, map token types vs permission levels.

---

### Entry #142 — Web3 Hacks Dashboard: Live Incident Patterns (May 2026)

**Source:** JohnnyTime Web3 Hacks Dashboard (realtime)
**Date Added:** 2026-05-19
**Type:** Threat Intel, Statistics
**Priority:** MEDIUM

**Content:**

$100B+ total value lost across 3,257 incidents, 74 chains, 15 attack classes.

**May 2026 Incidents (Last 7 Days):**
1. Verus — $11.6M — Bridge exploit (forged cross-chain import)
2. THORChain — $10.7M — Confirmed May 15
3. TrustedVolumes — $5.9M (May 14) + $6.7M (May 7) — Two incidents in one month
4. Transit Finance — $1.9M — May 13
5. Aurellion — $456K — Access Control
6. Ink Finance — $140K — Access Control
7. Renegade — $209K — Access Control
8. Ekubo Protocol — $1.4M — Access Control
9. Wasabi Protocol — $5.9M — May 4
10. Bisq — $850K

**April 2026:**
- Kelp DAO — $292M (LayerZero message spoofing)
- Drift Protocol — $1.0M
- Rhea Finance — $18.4M
- Hyperbridge — $2.5M
- Volo — $3.5M
- Aethir — $423K (bridge exploit)

**Attack Class Distribution:**
- Access Control: $14,262M stolen (most lucrative category)
- Phishing: $3,345M
- Flash Loans: $1,844M
- Oracle Manipulation: $1,229M
- Reentrancy: $562M (declining — May 2025 was last major)

**Notable Patterns:**
- Bridges are the dominant vector in 2026 (Kelp $292M, Verus $11.6M, THORChain $10.7M)
- Access Control bugs are the most common individual class
- Same projects being hit twice (TrustedVolumes, Rhea Finance, Volo, Hyperbridge)
- Verus exploit root cause (missing value validation) is identical class to Kelp/Nomad/Wormhole

**Relevance:** Confirms bridge logic bugs are the #1 most impactful attack class right now. May 2026 alone has $30M+ in bridge exploits. Our focus on Lombard/Mezo/Virtuals bridge surfaces is timed correctly.

---

### Entry #143 — Security Mindset: "Assume the Attacker Controls This Input"

**Source:** X post (anon), Paul Frambot (Morpho), Jon Wu
**Date Added:** 2026-05-19
**Type:** Mindset, Security Philosophy
**Priority:** MEDIUM

**Content:**

**Golden Question:**
"Don't ask 'Is this safe?' Ask: 'What if the attacker controls this input?'"
— That question scales across every codebase.

**Assume at least one endpoint, private key, team member, or account are compromised.**

**On Autonomous AI Audit Agents:**
"A good thing about fully autonomous AI audit agents is you can generate submissions, validate them first, send them to bug bounties, and observe their response to the finding to determine whether you wanna spend more tokens there."

**Paul Frambot (Morpho) on Solidity Bug Classes:**
- EVM resource constraints force gas-efficient but bug-prone patterns
- Solidity compiler is inefficient, but real constraints are from EVM design
- Basic operations during Ethereum's peak were so expensive you had to design for both correctness AND gas efficiency
- Bug classes could be removed at compiler level
- Contract size limitations remain a personal pain point — worked on a Solidity PR for 3% bytecode reduction

**Jon Wu on Crypto vs AI Talent:**
- Deep technical talent doesn't want to work in crypto — they don't see the impact
- AI companies about to go public at 1-2 orders of magnitude bigger outcomes than crypto

**Relevance:** The "assume attacker controls this input" question should be applied to every bridge validation step, every cross-chain message handler, and every agent delegation flow. For Virtuals specifically: assume the agent's input is attacker-controlled and trace the impact through the entire execution flow.

---

### Entry #144 — BlindXSS Dorker: Google Dork Recon Tool for Blind XSS Entry Points

**Source:** https://github.com/micho0x/BlindXss (republished from Coffinxp/Lostsec)
**Date Added:** 2026-05-19
**Type:** Tool, Recon, Blind XSS
**Priority:** MEDIUM

**Content:**

A Google Dork search tool specifically designed for finding Blind XSS entry points. Originally created by Coffinxp (Lostsec), republished by micho0x after original site went down.

**Features:**
- Pre-configured Google Dorks targeting: Contact Forms, Feedback pages, Job Applications, Support Tickets, User-Agent headers, Referrer headers
- One-click execution: enter target domain, click a card, auto-runs dork in Google
- Dark/Light mode

**Relevance:** Useful for finding Blind XSS entry points in web applications during recon phase. Can be applied to Virtuals, Kite, or any web-based target. Blind XSS on admin panels/dashboards where agents or users submit data can chain into session theft or account takeover.

**How to Use:**
1. Clone or copy the HTML file
2. Open in browser
3. Enter target domain (e.g., `virtuals.io`)
4. Click dork cards to auto-search Google for forms, tickets, feedback pages
5. Test identified pages with XSS payloads pointing to a Bling collaborator (XSSHunter, Burp Collaborator)

---

### Entry #145 — Semble: MCP Code Search for Agents (98% Fewer Tokens Than grep+read)

**Source:** https://github.com/MinishLab/semble, https://minish.ai/packages/semble/introduction/
**Date Added:** 2026-05-19
**Type:** Tool, MCP, Code Search, Agents
**Priority:** MEDIUM

**Content:**

Semble is a code search library built for agents that returns exact code snippets using ~98% fewer tokens than grep+read. Indexing and searching a full codebase takes under a second. Runs entirely on CPU with no API keys, GPU, or external services. Can run as MCP server or via shell/AGENTS.md.

**Key Features:**
- Indexes average repo in ~250ms, answers queries in ~1.5ms
- NDCG@10 of 0.854 (99% of CodeRankEmbed Hybrid quality)
- 98% fewer tokens than grep+read at equivalent recall
- Splits files with tree-sitter, retrieves with Model2Vec embeddings + BM25, fused with RRF
- Reranked with code-aware signals (no transformer forward pass = fast)
- MCP server works with Claude Code, Cursor, Codex, OpenCode
- Supports local paths and git URLs

**MCP Setup:**
- Claude Code: `claude mcp add semble -s user -- uvx --from "semble[mcp]" semble`
- OpenCode: Add to `~/.opencode/config.json` as MCP server
- Codex/Cursor: Similar config

**Relevance:** Directly useful for our workflow. Running Semble as an MCP server would let us search codebases (Virtuals contracts, Injective Agents repos, BotNode SDKs) with natural language queries without reading full files. Massive token savings when analyzing large codebases.

**Install:** `pip install semble` or `uv tool install semble`

---

### Entry #146 — Pwn2Own Berlin 2026: Official Blog Recaps (All 3 Days)

**Source:** ZDI Blog
**Date Added:** 2026-05-19
**Type:** Contest, Exploit Development, References
**Priority:** MEDIUM

**Content:**

Official ZDI blog posts with full details of every Pwn2Own Berlin 2026 exploit chain.

**Day 1 (May 13):** $523,750 paid, 24 zero days
- Orange Tsai: 4 logic bugs → Microsoft Edge sandbox escape ($175k)
- AI targets hit hard: LiteLLM, OpenAI Codex, NVIDIA
https://www.zerodayinitiative.com/blog/2026/5/13/pwn2own-berlin-2026-day-one-results

**Day 2 (May 15):** $385,000 paid, 15 zero days
- Orange Tsai: 3-bug chain → Exchange RCE as SYSTEM ($200k)
- More Windows 11 PE, Red Hat Enterprise Linux attempts
https://www.zerodayinitiative.com/blog/2026/5/15/pwn2own-berlin-2026-day-two-results

**Day 3 (May 16):** $389,500 paid, 8 zero days
- STAR Labs (Nguyen Hoang Thach): VMware ESXi cross-tenant memory corruption ($200k)
- Orange Tsai: SharePoint exploit
https://www.zerodayinitiative.com/blog/2026/5/16/pwn2own-berlin-2026-day-three-results-and-master-of-pwn

**Relevance:** Full technical details of each exploit chain will be published as writeups. Follow for:
- Logic bug chaining patterns (Orange Tsai's Edge sandbox escape — 4 pure logic bugs, no memory corruption)
- VMware cross-tenant isolation break (memory corruption applicable to bridge keeper/validator node infrastructure)
- AI tool vulnerabilities (LiteLLM, Codex) — directly relevant to agent platform security

---

### Entry #147 — EchoProtocol Hack on Monad (May 2026): Admin Compromise → Mint 1,000 eBTC → Drain WBTC Pool

**Source:** X posts from DCF GOD, on-chain analysis
**Date Added:** 2026-05-19
**Type:** DeFi Exploit, Access Control, Admin Abuse
**Priority:** HIGH

**Content:**

EchoProtocol on Monad was exploited via a compromised admin key. The attacker tested the flow first (swapped MON → eBTC on Uniswap, deposited into Curvance, borrowed tiny WBTC to confirm flow worked), then used admin access to drain the pool.

**Attack Flow:**
1. Compromised admin granted `DEFAULT_ADMIN_ROLE` to attacker
2. Attacker revoked old admin
3. Granted himself `MINTER_ROLE`
4. Minted 1,000 eBTC out of nowhere
5. Deposited 45 eBTC into Curvance ceBTC vault (pre-tested flow)
6. First borrow attempt reverted; retry went through
7. Pulled ~11.29 WBTC — basically the entire WBTC pool (left ~$60)
8. Within 4 minutes, bridged out via LiFi
9. Still holds 955 eBTC + 45 ceBTC (thin liquidity on Monad limited damage)

**Total Drained:** ~11.29 WBTC (~$770k at time)
**Chain:** Monad

**Key Lessons:**
1. **Admin keys are the single point of failure** — one compromised admin key = unlimited minting
2. **Role-based access control bugs** — if `DEFAULT_ADMIN_ROLE` can be granted by a compromised key, everything falls
3. **Test flow then exploit** — attacker ran a small test first to confirm the bridge/borrow flow worked, then did the actual drain
4. **Thin liquidity as natural circuit breaker** — Monad's thin liquidity meant only ~11 WBTC was borrowable, limiting the damage
5. **Speed matters** — bridged out via LiFi within 4 minutes of borrowing

**Relevance for Virtuals:**
- Check Virtuals' role-based access control in protocol-contracts — who has `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, etc.?
- Are admin keys in a multisig or HSM? Or a single EOA?
- Can agent tokens be minted by an admin without user consent?
- The "test flow then exploit" pattern is exactly what a white-hat would do to verify a finding — test small, prove the chain works, report it

---

### Entry #148 — Hacking Tip: Never Assume Security Because a Feature Exists

**Source:** Anonymous security researcher (X post)
**Date Added:** 2026-05-19
**Type:** Methodology, Mindset, 2FA Bypass
**Priority:** HIGH

**Content:**

**The Golden Rule:** "Don't assume that something is secure just because the feature exists."

**Real-World Example:**
- An application had custom auth: password → 6-digit email code (2FA)
- The endpoint had throttling enabled
- Most hackers stopped there
- One researcher found:
  1. The password step could be **skipped completely** — the 2FA endpoint didn't verify you had passed password auth
  2. The throttling was **by IP, not by account**
- Result: full ATO on ANY account by rotating IP on every request and brute-forcing the 6-digit code

**Key Insights:**
1. **Features are not guarantees** — just because 2FA exists doesn't mean the flow is secure
2. **Check state transitions** — does the 2FA endpoint verify you completed the password step? (Spoiler: often no)
3. **Throttling granularity matters** — IP-based throttling is useless against rotating proxies. Per-account throttling with exponential backoff is the minimum
4. **Assumption is the enemy** — "surely they check X" is how bugs are missed
5. **Rotating IP + brute force** — classic technique that works when throttling is per-IP, not per-credential

**Application to Virtuals:**
- Agent creation/deployment endpoints — are there auth checks that can be skipped?
- Token minting/burning — does the endpoint verify proper authorization, or just check "is caller authenticated"?
- Agent delegation — can you skip the user-approval step and directly set delegation permissions?
- Throttling on sensitive endpoints — is it per-account or per-IP?

**Relevance:** This mindset is why bridge logic bugs exist (Verus $11.58M — "surely they check source value backing" — they didn't). Apply the same assumption-killing to every Virtuals endpoint.

---

### Entry #149 — NibiruChain $200K Delegate Call Drain (ERC20 Callback Exploit)

**Source:** GitHub — NibiruChain/nibiru commit c239445 (v2.12.0 security patch)
**Date Added:** 2026-05-19
**Type:** Exploit Writeup, Smart Contract, Privilege Escalation
**Chain:** Nibiru (Cosmos EVM)
**Bounty:** $15K
**Content:**

**Overview:**
A critical draining bug where a malicious ERC20 token's `transfer()` function could `delegatecall` into a privileged precompile (FunToken) to drain ~$200K in assets. The vulnerability existed in the module-originated ERC20 transfer callback path.

**The Vulnerability:**
```solidity
// Malicious ERC20 contract
contract TestERC20MaliciousCallback is ERC20 {
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // During module-originated callback, delegatecall into privileged precompile
        (bool ok, bytes memory ret) = address(FUNTOKEN_PRECOMPILE).delegatecall(
            abi.encodeWithSignature(
                "bankMsgSend(string,string,uint256)",
                "nibi1zaavvzxez0elundtn32qnk9lkm8kmcsz44g7xl",
                "unibi",
                1
            )
        );
        // If guard not active, this drains funds
        return super.transfer(recipient, amount);
    }
}
```

**Root Cause:**
- During module-originated ERC20 transfers (e.g., `ConvertCoinToEvm`), the EVM module was the caller
- The module had privileged access to precompile functions (bankMsgSend, sendToEvm)
- A malicious token's transfer callback could `delegatecall` into the precompile, inheriting the module's privileges
- No "VM-sender guard" prevented mutable precompile calls during module-originated callbacks

**Fix:**
- Added `CtxKeyVMSenderGuard` context flag
- `assertNotVMCaller()` check on all mutable precompile methods
- Guard is set during `CallContract` when `fromAcc == EVM_MODULE_ADDRESS`
- Guard is restored after `ApplyEvmMsg` returns

**Attack Pattern:**
1. Attacker deploys malicious ERC20 with callback in `transfer()`
2. Creates a FunToken mapping for the malicious ERC20
3. Calls `ConvertCoinToEvm` → triggers module-originated ERC20 transfer
4. Malicious `transfer()` callback `delegatecall`s into FunToken precompile
5. Precompile executes `bankMsgSend` with module privileges → drains funds

**Relevance to Virtuals:**
- **Direct parallel:** AgentTokenV4 has `_swapTax()` inside `_transfer()` that calls external `taxAccountingAdapter.swapTaxAndDeposit()`
- During `launch()`, the bonding curve contract (privileged caller) transfers tokens
- If the agentToken's transfer hook calls back into the bonding curve, it could re-enter with bonding curve privileges
- **Key question:** Can the `taxAccountingAdapter` or `_uniswapRouter` be set to a malicious contract?
- The `taxAccountingAdapter` is admin-controlled (set by `setTaxAccountingAdapter`)
- But `_uniswapRouter` is set from `factory.uniswapRouter()` during initialization
- **Additional vector:** The `executeBondingCurveApplicationSalt` creates agentTokens with a predictable salt — same pattern as Verus $11.58M

**Key Techniques:**
- Delegatecall privilege escalation during callbacks
- Module-originated transfer exploitation
- VM-sender guard pattern for defense
- Try-catch for graceful error handling (doesn't stop transfers)

**Similar References:**
- Entry #099 (64 DeFi exploit analyses — oracle manipulation, access control)
- Entry #147 (EchoProtocol admin compromise — similar role escalation)
- Entry #016 (Solana router drain — accounting error exploitation)

---

### Entry #150 — A White Mage's Guide to Web3 Bug Hunting (Professional Methodology)

**Source:** Blog post (Feb 2, 2026)
**Date Added:** 2026-05-19
**Type:** Methodology, Strategy, Professional Development
**Content:**

**Overview:**
Comprehensive guide from a professional web3 bug bounty hunter covering target selection, hunting methodology, mindset, and getting paid. Focuses on finding Critical vulnerabilities that lead to real loss of funds.

**Key Methodology Insights:**

**Target Selection (Risk Assessment):**
- **Complexity** — Bugs hide in complex systems. Simple codebases rarely have meaningful exploit paths
- **Innovation** — New approaches have unconsidered attack surfaces. RWAs, ZK systems, privacy tech, AI integrations
- **Optimization** — Gas optimizations, assembly, manual memory management introduce subtle bugs
- **Code Quality** — Poor code correlates with deeper issues. Audit findings of many basic issues = weak implementation

**Hunting Approach:**
> "I have found severe vulnerabilities in systems I did not fully understand. Not simple bugs, but complex paths. I ignored most of the code and obsessed over one execution path, checking every assumption and branch."

- Go deep on ONE execution path, not broad across the whole codebase
- Check every assumption and branch in that path
- Research unfamiliar concepts, read docs, build understanding slowly
- Come back later — see code differently after time away
- Compare mechanisms across projects — "How does liquidation work here versus elsewhere?"

**Hunter Archetypes:**
- **The Digger** — Goes deep on a single program
- **The Differ** — Compares one mechanism across many projects
- **The Speedrunner** — Reviews new programs immediately
- **The Watchman** — Monitors deployments and upgrades
- **The Lead Hunter** — Develops ideas around less known vulnerability types
- **The Scavenger** — Gets inspired by obscure writeups or little known incidents

**What NOT to Hunt:**
- Deprecated or unused code
- Old contract implementations behind proxies
- Repository code that does not match deployed code
- Issues requiring trusted roles (admin keys, centralized control)
- Temporary DOS or griefing
- Issues gated on third party conditions

**Getting Paid:**
- Always archive bounty rules before submitting
- Red flags: vague rules, very low caps, prior disputes, lack of response
- Platforms: Immunefi, HackenProof, Cantina
- Bounties follow a power law — one Critical = dozens of Highs

**Application to Virtuals:**
- Focus on ONE execution path: bonding curve graduation (preLaunch → launch → buy → graduate → Uniswap)
- Check every assumption in that path
- Don't hunt admin key issues (trusted roles = not bounty-worthy)
- Compare Virtuals' bonding curve to other launchpads (pump.fun, friend.tech, etc.)
- The "Scavenger" archetype — use obscure writeups (like Nibiru) to find patterns

**Similar References:**
- Entry #099 (64 DeFi exploit analyses)
- Entry #011 (Multi-agent bug hunting — 20+ CVEs)
- Entry #148 (Never assume because feature exists)

---

### Entry #151 — Claude-BugHunter: 51-Skill Bug Hunting Bundle (574+ Disclosed Reports)

**Source:** GitHub — elementalsouls/Claude-BugHunter
**Date Added:** 2026-05-19
**Type:** Tool, Skills, Methodology, Payloads
**Repo:** https://github.com/elementalsouls/Claude-BugHunter
**Content:**

**Overview:**
A self-contained Claude skill bundle for bug hunting and red-team work. 51 skills, 15 slash commands, 574+ disclosed report patterns across 24 vulnerability classes. Enterprise identity + infrastructure attack matrices. Battle-tested across authorized engagements and public training platforms (DVWA, OWASP Juice Shop, Hacker101).

**Key Components:**
- **Bug Bounty + Methodology + Red Team Mindset** — 5-phase non-linear hunting workflow, critical-thinking framework, developer-psychology heuristics, anomaly detection patterns
- **24 hunt-* skills + security-arsenal** — Per-class detection patterns, payloads, bypass tables, chain templates from 574+ HackerOne reports
- **Enterprise platform attack chains** — M365/Entra ID, Okta, SharePoint, VMware vCenter, SSL VPN appliances (Cisco/Fortinet/Citrix/Palo Alto/Pulse/SonicWall/F5), Android APK red-team, supply-chain recon
- **Triage + Reporting** — 7-Question Gate, VRT category fallback, severity-request paragraphs, OOS rebuttals

**Skill Categories:**
- Recon & Intelligence (3): offensive-osint, web2-recon, osint-methodology
- Hunt — Web App (27): hunt-idor, hunt-ssrf, hunt-xss, hunt-sqli, hunt-rce, hunt-auth-bypass, hunt-oauth, hunt-jwt, hunt-graphql, hunt-file-upload, etc.
- Platform Attack (7): m365-entra-attack, okta-attack, cloud-iam-deep, vmware-vcenter-attack, enterprise-vpn-attack, hunt-sharepoint, hunt-aspnet
- Workflow (5): bug-bounty, bb-methodology, redteam-mindset, triage-validation, evidence-hygiene
- Reporting (3): bugcrowd-reporting, redteam-report-template, mid-engagement-ir-detection

**Relevance to Virtuals:**
- **hunt-ssrf** — Test Virtuals API endpoints for SSRF (ab-api.virtuals.gg, claw-api)
- **hunt-oauth** — Test Privy token exchange flow for OAuth vulnerabilities
- **hunt-idor** — Test agent management endpoints for IDOR
- **hunt-graphql** — Test ACP APIs for GraphQL injection
- **supply-chain-attack-recon** — Test agent plugin supply chain
- **triage-validation** — Use 7-Question Gate to validate findings before reporting

**Similar References:**
- Entry #002 (Awesome AI Hacking Agents)
- Entry #011 (Multi-agent bug hunting)
- Entry #150 (White Mage's Guide)

---

### Entry #152 — src-hunter-skill: Chinese SRC/Bounty Hunting Workflow (2887 H1 Reports)

**Source:** GitHub — MyuriKanao/src-hunter-skill
**Date Added:** 2026-05-19
**Type:** Skill, Methodology, Payloads, Case Studies
**Repo:** https://github.com/MyuriKanao/src-hunter-skill
**Content:**

**Overview:**
实战 SRC / 众测 / Bug bounty 漏洞挖掘工作流 skill. Contains 5-phase methodology (intake → recon → enum → hunt → report), 19 attack class playbooks, 305 structured payloads, 263 WAF/EDR bypass variants, 2887 HackerOne real High/Critical disclosed cases, 77,000+ WooYun case statistics.

**5-Phase Methodology:**
1. **Intake** — Scope confirmation, rules, timeboxing
2. **Recon** — Passive (CT logs, Wayback, GitHub dorks, FOFA/Shodan, DNS history)
3. **Enum** — Active probing (port scan, service fingerprint, JS endpoint extraction)
4. **Hunt** — Attack execution with playbooks
5. **Report** — Structured output with evidence

**Anti-Hallucination Hard Constraints:**
1. Never output payloads from memory — must Read from reference files
2. Never fabricate case numbers — must verify from actual files
3. No evidence = no conclusion — only "pending verification" without HTTP packets
4. Out of scope = stop immediately

**19 Attack Class Playbooks:**
SQLi, XSS, RCE, SSRF, IDOR, CSRF, Path Traversal, File Upload, SSTI, XXE, Race Condition, HTTP Smuggling, OAuth, JWT, SAML, GraphQL, Mobile, LLM, DoS

**Key References:**
- 2887 H1 disclosed High/Critical reports organized by weakness
- 77,000+ WooYun case statistics
- Chinese OA/middleware fingerprint database (weaver/seeyon/tongda/landray/yongyou/kingdee/hikvision/dahua)
- Banking/telecom industry vertical playbooks

**Relevance to Virtuals:**
- **LLM playbook** — Test G.A.M.E agent inference for prompt injection
- **Race Condition playbook** — Test bonding curve for race conditions in buy/sell
- **SSRF playbook** — Test API endpoints for SSRF
- **OAuth playbook** — Test Privy token exchange
- **Anti-hallucination constraints** — Apply to our own findings validation

**Similar References:**
- Entry #097 (HackerOne disclosed reports)
- Entry #151 (Claude-BugHunter)
- Entry #150 (White Mage's Guide)

---

### Entry #153 — ZK-Resources: Zero-Knowledge Security & Learning Resources

**Source:** GitHub — 0xluk3/ZK-resources
**Date Added:** 2026-05-19
**Type:** Resource List, ZK Security, Audit Reports
**Repo:** https://github.com/0xluk3/ZK-resources
**Content:**

**Overview:**
Curated list of ZK security and learning resources including bug trackers, audit reports, and tutorials for zkVMs (RISC Zero, SP1), ZK circuits, and ZK protocol security.

**Key Bug Trackers:**
- 0xPARC / zk-bug-tracker — Community ZK bug tracker
- zksecurity / zkbugs — ZK vulnerability database
- thogiti / ZK-Audits — Spartan-ECDSA audit

**Key Audit Reports:**
- **RISC Zero** — Veridise Round 2 V4 audit, Hexens Dec 2024 audit, HackenProof RISCZKVM-25 report
- **SP1** — LambdaClass responsible disclosure of SP1 zkVM exploit (with 3MI Labs & Aligned), Veridise call_contracts audit
- **zkVMs** — Veridise "Identifying common vulnerabilities in zkVMs", Sigma Prime SP1 & zkVMs auditor's guide, 7BlockLabs auditing zkVM guest programs checklist

**Key Tutorials:**
- Sumcheck interactive tutorial (zkSecurity, SageMath)
- ZK Whiteboard Sessions (ZK Hack)
- RareSkills ZK Book
- floatingpragma - awesome ZK proofs (math fundamentals)

**Aggregated Resources:**
- timimm / awesome-zero-knowledge-proofs-security
- StefanosChaliasos / Awesome-ZKP-Security
- sCrypt-Inc / awesome-zero-knowledge-proofs

**Relevance to Virtuals:**
- **Entry #099 Veil Cash Groth16 forgery on Base** — ZK circuit bugs are relevant if Virtuals uses ZK proofs for any component
- **zkVM security patterns** — If Virtuals uses zkVMs for agent computation, these patterns apply
- **General ZK security methodology** — Useful for auditing any ZK-based DeFi protocol

**Similar References:**
- Entry #099 (64 DeFi exploit analyses — Veil Cash Groth16 forgery)
- Entry #027 (dYdX oracle manipulation)

---

### Entry #154 — Claude-BugHunter Skills: web3-audit, meme-coin-audit, hunt-business-logic, hunt-race-condition

**Source:** GitHub — elementalsouls/Claude-BugHunter (skills directory)
**Date Added:** 2026-05-19
**Type:** Skills, Methodology, Payloads, DeFi Security
**Content:**

**web3-audit skill — 10 DeFi Bug Classes:**
1. Accounting State Desynchronization (28% of Criticals)
2. Access Control (19% of Criticals)
3. Incomplete Code Path (17% of Criticals)
4. Off-by-One and Boundary Conditions (22% of Highs)
5. Oracle / Price Manipulation (12% of all reports)
6. ERC4626 Vault Attacks
7. Reentrancy (still paying in 2026)
8. Flash Loan Attacks
9. Signature Replay
10. Proxy / Upgrade Issues

**THE ONE RULE:** "Read ALL sibling functions. If vote() has a modifier, check poke(), reset(), harvest(). The missing modifier on the sibling IS the bug." — explains 19% of all Critical findings.

**meme-coin-audit skill — 8 Token Bug Classes:**
1. Hidden Mint / Unlimited Supply (35% of rugs)
2. Honeypot / Transfer Restriction (25% of scams)
3. Fee Manipulation (20% of rugs)
4. Liquidity Pool Drain
5. Bonding Curve Manipulation — virtualReserve, setCurve, graduate — Kill if: Curve parameters immutable, graduation permissionless
6. Authority Retention (Solana)
7. Fake Renounce / Hidden Ownership
8. Sandwich Amplification by Design

**hunt-business-logic skill — 7 H1 Reports:**
- Payment flow manipulation, verification bypass, rate-limit bypass
- Key: "Check state transitions — does the 2FA endpoint verify you completed the password step?"
- Key: "Rotating IP + brute force — classic technique when throttling is per-IP, not per-credential"

**hunt-race-condition skill — 3 H1 Reports:**
- Double-spending gift cards, coupons, referral bonuses
- Key: "Pre-connect and buffer all requests, release the final byte of all simultaneously"
- Key: "The gap between read and write is your window"

**Relevance to Virtuals:**
- ONE RULE applied to FRouterV3: addInitialLiquidity has EXECUTOR_ROLE but NO nonReentrant — potential reentrancy during liquidity addition
- Bonding Curve Manipulation: Virtuals uses virtualReserve and graduate — exactly the patterns meme-coin-audit flags
- Race Condition: preLaunch to launch timing gap (6-60 seconds) is a race window
- Accounting Desync: BondingV5 tracks tokenInfo[tokenAddress_].data.supply separately from actual pair reserves — potential desync

---

### Entry #155 — Claude-BugHunter Skills: hunt-llm-ai, hunt-ssrf, hunt-idor, security-arsenal, triage-validation

**Source:** GitHub — elementalsouls/Claude-BugHunter (skills directory)
**Date Added:** 2026-05-19
**Type:** Skills, Payloads, Methodology
**Content:**

**hunt-llm-ai skill — OWASP ASI 2026 (Agentic AI Security):**
- ASI01: Goal Hijack — prompt injection alters agent objectives
- ASI02: Tool Misuse — SSRF via "fetch this URL", RCE via code tool
- ASI03: Privilege Abuse — credential escalation across agents
- ASI04: Supply Chain — compromised plugins/MCP servers
- ASI05: Code Execution — sandbox escape via code interpreter
- ASI06: Memory Poisoning — corrupted RAG/context data
- ASI07: Agent Comms — spoofing between agents
- ASI08: Cascading Failures — errors propagate across systems
- ASI09: Trust Exploitation — AI output rendered as HTML (XSS via AI)
- ASI10: Rogue Agents — no kill switch, no rate limiting on tool calls

**hunt-ssrf skill — 9 H1 Reports:**
- Cloud metadata (169.254.169.254), Kubernetes, internal APIs
- Key: "OOB-Or-It-Didnt-Happen Gate — Claims of blind SSRF require OOB confirmation"
- Key: "Server echoing URL in error message is NOT SSRF — its string formatting"

**hunt-idor skill — 26 H1 Reports:**
- Financial documents, private repos, user messages, account management
- Key: "Direct access to other users data without authentication bypass"
- Key: "Chains easily with privilege escalation, financial fraud, and account takeover"

**security-arsenal skill:**
- XSS payloads (basic, cookie theft, CSP bypass, DOM XSS)
- SSRF payloads (cloud metadata, internal services)
- WAF bypass techniques
- Always-rejected bug list

**triage-validation skill — 7-Question Gate:**
1. Can an attacker use this RIGHT NOW, step by step?
2. Is the impact on the programs accepted impact list?
3. Is the root cause in an in-scope asset?
4. Does it require privileged access that an attacker cant realistically get?
5. Is this already known or accepted behavior?
6. Can you demonstrate the impact with a PoC?
7. Is the severity correctly assessed?

**Relevance to Virtuals:**
- hunt-llm-ai: Test G.A.M.E agent inference for prompt injection (ASI01-ASI10)
- hunt-ssrf: Test ab-api.virtuals.gg, claw-api for SSRF
- hunt-idor: Test agent management endpoints for IDOR
- triage-validation: Apply 7-Question Gate to all Virtuals findings before reporting

---

### Entry #156 — src-hunter-skill: LLM Prompt Injection, Race Conditions, Business Logic Playbooks

**Source:** GitHub — MyuriKanao/src-hunter-skill (references/playbooks)
**Date Added:** 2026-05-19
**Type:** Playbooks, Payloads, Attack Chains
**Content:**

**LLM Prompt Injection Playbooks (5 files):**
- 10-direct-prompt.md — System prompt extraction, safety guardrail bypass, indirect injection
- 11-indirect-rag.md — RAG poisoning, knowledge base injection, vector database attacks
- 12-agent-vulns.md — 10 agent vulnerability classes (AGENT-001 to AGENT-010):
  - AGENT-001: Prompt Injection (high)
  - AGENT-002: Code Execution / Sandbox Escape (high)
  - AGENT-003: Agent-triggered SSRF (high)
  - AGENT-004: Tool misuse
  - AGENT-005: Memory poisoning
  - AGENT-006: Supply chain
  - AGENT-007: Agent comms spoofing
  - AGENT-008: Cascading failures
  - AGENT-009: Trust exploitation
  - AGENT-010: Rogue agents
- 13-model-attacks.md — Model-level attacks
- 14-techniques.md — Advanced bypass techniques

**Race Conditions Playbook:**
- Balance overdraft, coupon double-spend, limited-quantity bypass
- Key: "Race = program assumes read-modify-write is atomic, but concurrent requests make it not"
- Burp Turbo Intruder template for parallel requests
- Python PoC for balance withdrawal race

**Business Logic Playbook:**
- IDOR, CSRF, payment logic tampering, password reset flaws
- Key: "Identify API endpoints using numeric/UUID as resource identifiers"
- Horizontal and vertical privilege escalation
- Parameter pollution bypass

**Relevance to Virtuals:**
- AGENT-001/002: Test G.A.M.E agent for prompt injection and code execution
- AGENT-003: Test agent tool-use for SSRF (can agents fetch arbitrary URLs?)
- Race Conditions: preLaunch to launch timing gap (6-60 seconds) is exploitable
- Business Logic: Test agent management APIs for IDOR and privilege escalation

---

### Entry #157 — Claude-BugHunter: bb-methodology, redteam-mindset, triage-validation

**Source:** GitHub — elementalsouls/Claude-BugHunter (skills directory)
**Date Added:** 2026-05-19
**Type:** Methodology, Mindset, Professional Development
**Content:**

**bb-methodology — 5-Phase Non-Linear Hunting Workflow:**
- PART 0: Mode Confirmation (bug bounty vs red team vs pentest vs internal audit)
- PART 1: Mindset (critical thinking, multi-perspective, tactical thinking, strategic thinking)
- Core Principle: "Hunting is not find a bug — it is prove an attack scenario"
- 5 Ultimate Goals: Confidentiality, Integrity, Availability, Account Takeover, RCE
- 4 Thinking Domains: Critical, Multi-Perspective, Tactical, Strategic

**Key Mindset Insights:**
- "Feature A has auth checks — Similar feature B (newly added) probably doesnt"
- "Complex flows (coupon + points + refund) — Edge cases have bugs"
- "Replace guid=f8a2... with id=100 on sibling endpoint — IDOR?"
- "Naming anomaly: userId everywhere but suddenly user_id — different dev, weaker security"

**redteam-mindset — 9 Corrections:**
1. Authorization given at engagement start covers the entire engagement
2. DO NOT STOP — primary directive
3. "Stop at PoC" means stop ESCALATING, not stop TESTING
4. Marker Discipline is not "one probe per surface"
5. Self-throttling anti-patterns (10 explicit failure modes)
6. Real-engagement cadence — what a complete sweep per live host looks like

**Key Anti-Patterns:**
- "Asking want me to continue? mid-run after the user already chose Option D"
- "Stopping at first-class-returning-401/403"
- "Volume framed as a problem — 3,000 well-tagged requests through Burp is normal cadence"

**Relevance to Virtuals:**
- Mode: This is a white-hat engagement with signed NDA — apply bug bounty rules
- Mindset: "Hunting is not find a bug — it is prove an attack scenario" — we need to prove the drain scenario
- Anti-pattern: Dont stop at "admin key required" — find the path that doesnt need it
- Cadence: Run every test class on every live surface — bonding curve, API, agent management

---

### Entry #158 — [AVAILABLE]

*Slot reserved for future Virtuals-specific resource.*

---

### Entry #159 — [AVAILABLE]

*Slot reserved for future Virtuals-specific resource.*

---

### Entry #160 — Happy Path Auditing Trap: Force the Pessimistic View

**Source:** Twitter
**Date Added:** 2026-05-21
**Type:** Methodology, Mindset
**Content:**

"Was auditing a protocol today and caught myself in a classic trap within the first 10 minutes. Wasn't finding any bugs. The code looked fine. Then I realized — I was only tracing happy paths. As soon as I noticed, I stopped and went back with the right mindset: error cases, reverts, edge states, and what happens when assumptions break. Bugs started surfacing immediately."

**Key Insight:** Happy path auditing is one of the easiest ways to miss critical issues. Force the pessimistic view early.

**Application to Virtuals:**
- We've been tracing the happy path: preLaunch -> launch -> buy -> graduate -> Uniswap
- Need to force the NEGATIVE path: What happens when preLaunch reverts? When launch fails? When buy returns 0?
- What happens when the pair has 0 reserves? When kLast is 0? When the token is blacklisted?
- What happens when two preLaunch calls happen in the same block? When launch is called before startTime?
- What happens when the agentFactory.executeBondingCurveApplicationSalt fails? Does the VIRTUAL get stuck?

---

### Entry #161 — Blend Capital YieldBlox $10M Oracle Manipulation (Stellar)

**Source:** Twitter + Blockaid Report (May 20, 2026)
**Date Added:** 2026-05-21
**Type:** Exploit, Oracle Manipulation, DeFi
**Amount:** ~$10M (USDC + XLM)
**Chain:** Stellar
**Content:**

**Attack Flow:**
1. USTRY (tokenized US Treasury) had almost zero trading volume (~$1/hour)
2. Single market-maker pulled all liquidity from orderbook
3. Attacker executed ONE trade pushing price from $1.05 to $106.74 (100x)
4. Reflector oracle used VWAP — the manipulated trade dominated the 300-second aggregation window
5. Oracle wrapper enforced max_dev = 10% deviation check, but compared to PREVIOUS window (also manipulated) — deviation was 0%
6. Attacker deposited inflated USTRY as collateral into Blend pool
7. Borrowed 61M XLM + 1M USDC against the manipulated collateral value
8. Position appeared solvent (health factor 1.0985) at manipulated price, but massively undercollateralized at true value

**Root Cause:** Oracle compared each new price only to the immediately preceding window. Since both consecutive windows reflected the manipulated price, the calculated deviation was zero. The inflated price passed validation.

**Key Vulnerability Chain:**
Illiquid asset -> single market-maker -> orderbook emptied -> price manipulation -> oracle poisoning (deviation check bypassed) -> collateral inflation -> fraudulent loan

**Application to Virtuals:**
- Virtuals uses fakeInitialVirtualLiq = 6300 VIRTUAL as "virtual" liquidity — this creates an artificial price floor
- The bonding curve has REAL liquidity only from purchases — before anyone buys, the virtual reserves are dominant
- If someone can manipulate the ratio of virtual:real reserves, they can manipulate the graduation price
- The kLast value is set during mint() but NEVER updated during swap() — the stored k can diverge from actual reserves

---

### Entry #162 — LayerZero KelpDAO $292M Exploit (DPRK Social Engineering + RPC Poisoning)

**Source:** LayerZero Labs Post-Mortem + Mandiant + CrowdStrike (May 18, 2026)
**Date Added:** 2026-05-21
**Type:** Exploit, Infrastructure, Social Engineering
**Amount:** 116,500 rsETH (~$292M)
**Attribution:** DPRK / UNC4899 (TraderTraitor)
**Content:**

**Attack Chain:**
1. March 6: Social engineered a LayerZero Labs developer to clone a malicious GitHub repo
2. Malware (FLATROOF + ROOFDECK) dropped on developer's macOS — EDR did NOT detect
3. Harvested session keys to access LayerZero's RPC cloud environment
4. March 30 - April 16: Accessed GCP using session keys, performed reconnaissance
5. April 16-18: Lateral movement to GKE clusters, poisoned op-geth running process IN MEMORY
6. Patched running RPC with ELF PIE that returned correct responses to monitoring tools but tampered responses to the DVN
7. April 18 16:30: DoS attack against external RPC providers
8. This forced LayerZero's failover logic to rely exclusively on compromised internal nodes
9. April 18 17:35: DVN signed attestation for forged crosschain message
10. KelpDAO had 1-of-1 DVN config (previously 2-of-2) — single valid attestation was enough
11. 116,500 rsETH unlocked on Ethereum

**Key Vulnerability Chain:**
Social engineering -> malware (undetected by EDR) -> session keys -> RPC access -> in-memory patching (no disk artifacts) -> DoS external RPC -> DVN signs forged message -> single-DVN config allows unlock

**Critical Lessons:**
- The attacker patched running PROCESS MEMORY — no files on disk
- The malware returned correct responses to monitoring tools, tampered only to DVN
- The OApp owner had changed from 2-of-2 to 1-of-1 DVN config
- "Decentralized" Verifier Network used the same team's RPCs under DoS

**Application to Virtuals:**
- Virtuals' backend bot (0x81f7) is a single point of failure — if compromised, all agent launches are controlled
- The admin key (e2203) is an EOA — single key compromise = total drain
- No monitoring or anomaly detection on the admin's transactions
- The prev chat mentioned ab-api.virtuals.gg has no CSRF — session hijacking possible

---

### Entry #163 — MAPO Bridge Exploit: abi.encodePacked Footgun (Hash Collision)

**Source:** Twitter (@WhiteHatMage)
**Date Added:** 2026-05-21
**Type:** Exploit, Solidity, Hash Collision
**Content:**

**Root Cause:**
The bridge authenticates cross-chain message retries with keccak256(abi.encodePacked(...)) over four consecutive dynamic-bytes fields (initiator, from, to, swapData). abi.encodePacked has NO length prefixes, so field boundaries aren't encoded — different field allocations can pack to the identical byte string and therefore the identical keccak.

**Attack:**
1. Originated a real, oracle-multisig-signed message to a precomputed CREATE address (no code yet)
2. Bridge cached a "NotContract" retry commitment
3. Deployed exploit contract at that exact address
4. Called retryMessageIn with rearranged bytes-field boundaries that pack to the IDENTICAL 601-byte string as the planted message
5. Same keccak -> guard passes -> bridge mints 10^15 MAPO (~4.8M x supply) to attacker

**The Bug:**
Solidity keccak256(abi.encodePacked(dynamic1, dynamic2, dynamic3, dynamic4)) — different boundaries produce identical hash. Fix: use abi.encode (with length prefixes).

**Application to Virtuals:**
- Need to check ALL keccak256/abi.encodePacked usage in Virtuals contracts
- The predictable salt in graduation: keccak256(abi.encodePacked(msg.sender, block.timestamp, tokenAddress_)) — is this vulnerable to hash collision?
- Check if any message authentication uses abi.encodePacked over dynamic types
- The executeBondingCurveApplicationSalt takes a bytes32 salt — is it derived from abi.encodePacked?

**General Rule:** NEVER use abi.encodePacked with multiple dynamic types. Always use abi.encode for hash computation over dynamic fields.

---
