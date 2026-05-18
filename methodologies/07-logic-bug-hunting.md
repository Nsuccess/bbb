# Logic Bug & Supply Chain Exploitation Methodology

## Overview

Methodology for discovering and chaining **logic bugs** — vulnerabilities in application logic, not memory corruption. Based on Orange Tsai's $175k Pwn2Own Edge sandbox escape (4 logic bugs chained, Entry #075) and real-world supply chain + logic bug combinations.

**Source:** Entry #075 — Orange Tsai: 4 Logic Bugs → Edge Sandbox Escape, $175k
**Source:** Entry #011 — Multi-agent system (30+ CVEs)
**Source:** Entry #035 — IronCurtain agent runtime
**Academic Backing:** Entry #109 — 83 LLM Assisted Attack papers + 56 Agent4Cyc papers + 94 Vuln Detection papers

---

## Why Logic Bugs Matter

### The Paradigm Shift

> "I have never thought that a browser could be exploited purely with logic bugs without memory corruption." — @bienpnn

**Logic bugs bypass:**
- CFG (Control Flow Guard)
- ACG (Arbitrary Code Guard)
- CIG (Code Integrity Guard)
- ASLR/DEP
- All memory corruption mitigations

**They are harder to detect because:**
- Traditional fuzzing targets memory corruption
- Static analysis misses business logic flaws
- Require deep architecture understanding
- Often span multiple components/subsystems

---

## Phase 1: Logic Bug Identification

### Step 1.1 — Map Architecture & Trust Boundaries

**What to look for:**
- Component boundaries (browser ← renderer → sandbox → kernel)
- IPC mechanisms and message passing
- Permission models and privilege levels
- Data validation at trust boundaries
- State transitions and assumptions

**For Web Apps:**
- Role transitions (user → admin → superadmin)
- Multi-step workflows with state assumptions
- API orchestration and data aggregation
- Race conditions in state-dependent logic

### Step 1.2 — Identify Logic Bug Categories

| Category | Description | Example |
|----------|-------------|---------|
| **State Confusion** | Assumptions about execution state are wrong | Assume renderer is dead when it isn't |
| **TOCTOU** | Time-of-check vs time-of-use gaps | File permission check then use |
| **Privilege Confusion** | Wrong privilege level assumed | High-privilege IPC received from low-privilege caller |
| **Type Confusion (Logic)** | Object treated as wrong type (non-memory) | JSON parser expects array, gets object |
| **Validation Bypass** | Incomplete validation chain | Validate URL but not redirect target |
| **Atomicity Violation** | Multi-step operation not atomic | Step 1 succeeds, step 2 fails → inconsistent state |
| **Assumption Violation** | Code assumes something that isn't guaranteed | "This function is only called from the UI thread" |
| **Supply Chain Logic** | Dependency introduces conflicting logic | Patch in library changes behavior assumptions |
| **Agent-in-the-Middle** | AI agent proxies user requests with escalated privileges | User request → Agent API call with agent's auth context (see Entry #109, Agent4Cyc #40, #52) |
| **Session Desync** | User session state differs from agent session state | User logs out but agent retains session token |
| **Tool Confusion** | Agent uses wrong tool or wrong tool parameters for context | Agent uses read tool where write was intended, bypassing access controls |

### Step 1.3 — Chain Identification

**Chain Construction (from Entry #075):**
```
Bug 1 → Low-severity info leak
Bug 2 → Medium-severity boundary bypass
Bug 3 → High-severity privilege escalation
Bug 4 → Critical sandbox escape
```

**Chain Patterns:**
- **Progressive escalation:** Each bug increases access
- **Parallel combination:** Multiple bugs targeting same boundary
- **Dependency chain:** Bug B requires Bug A's output
- **Supply chain trigger:** Library update enables new attack path
- **Agent chain:** Multiple AI agents each contribute one step in the chain — validated by Entry #109, Agent4Cyc #36 (Teams of LLM Agents Exploit 0-Day) and Agent4Cyc #40 (Autonomous 1-Day Exploitation)

---

## Phase 2: Supply Chain + Logic Bug Analysis

### Step 2.1 — Map Supply Chain

**Identify:**
- All dependencies and versions
- Recent updates and patch diffs
- Deprecated functions and their replacements
- Configuration defaults and changes
- Behavior differences between versions

### Step 2.2 — Find Logic Conflicts

**Patterns:**
- **Patch introduces new assumption:** Fix for vuln A assumes state B, which may not hold
- **Library change breaks host logic:** Upstream change invalidates security assumption in host
- **Behavioral regression:** New feature bypasses old guard
- **Default inversion:** Secure default in v1 becomes insecure in v2

### Step 2.3 — Supply Chain + Logic Chain

```
Supply Chain Analysis:
  ↓
Library X v2.0 changes how Y behaves
  ↓
Host app assumes old Y behavior (logic bug)
  ↓
Attacker exploits the assumption mismatch
  ↓
Chain with another logic bug for escalation
```

---

## Phase 3: LLM-Agent Logic Bugs (NEW — from Entry #109)

### Step 3.1 — Agent-in-the-Middle Attacks

**Concept:** When an AI agent proxies requests between users and APIs, it can introduce logic bugs at the privilege boundary.

**Academic Reference:** Entry #109, Agent4Cyc #42 — WIPI: New Web Threat for LLM-Driven Web Agents; Entry #109, Agent4Cyc #41 — InjecAgent: Indirect Prompt Injection in Tool-Integrated LLM Agents.

**Test for:**
- Can user make agent perform actions at agent's privilege level?
- Can user poison agent's tool call parameters?
- Does agent verify authorization before each tool call, or cache it?
- Can user feed data to agent that gets interpreted as tool instructions?

### Step 3.2 — Tool Confusion Attacks

**Test for:**
- Agent uses wrong tool for the context
- Agent misinterprets tool output (type confusion in tool results)
- Agent uses cached/outdated tool output
- Race condition between tool result arrival and state change

### Step 3.3 — Smart Contract Logic Bugs

**Academic Reference:** Entry #109, Vuln Detection #82 — GPTScan: combines GPT with program analysis for logic vulnerability detection in smart contracts.

**Logic Categories Specific to Smart Contracts:**
- Access control confusion (onlyOwner bypass, role hierarchy gaps)
- Flash loan + price oracle manipulation (economic logic bugs)
- Precision loss rounding favoring attackers
- Cross-contract invocation order manipulation
- Front-running through transaction ordering dependency

---

## Phase 4: Browser/Application IPC Testing

### Step 4.1 — IPC Surface Mapping

**Identify IPC channels:**
- Process-to-process communication
- Extension APIs and message passing
- Service worker communication
- Shared memory regions
- File-based IPC (pipes, sockets, temp files)

### Step 3.2 — IPC Logic Testing

**Test for:**
- **Message ordering:** Can messages be replayed, reordered, or dropped?
- **Origin validation:** Does receiver verify sender identity/privilege?
- **State assumptions:** Does receiver assume anything about sender state?
- **Resource exhaustion:** Can IPC be used to exhaust resources in another process?
- **Privilege escalation:** Can low-privilege sender spoof high-privilege sender?

### Step 3.3 — Fuzzing IPC (Not Memory)

**Logic-focused IPC fuzzing:**
- Valid messages in invalid order
- Partially complete messages
- Messages with incorrect metadata
- Race conditions in message handlers
- Resource limit testing

---

## Phase 5: Multi-Step Exploit Construction

### Step 5.1 — Find the Entry Point

**Look for:**
- User-controlled input that crosses a trust boundary
- External data parsed by a high-privilege component
- Shared resources writable by low-privilege and read by high-privilege
- Race windows in multi-step operations

### Step 5.2 — Build the Chain

**Chain Construction Process:**
```
Entry Point → Boundary A → Boundary B → Target

Bug 1: Bypass first validation
Bug 2: Cross trust boundary
Bug 3: Escalate privilege
Bug 4: Access target (sandbox escape / data access / RCE)
```

### Step 5.3 — Test Each Link

**For each bug in the chain:**
1. Can it be triggered reliably?
2. Can it be triggered without detection?
3. Is the outcome deterministic?
4. Does it depend on timing/state?
5. Can it be combined with other bugs?

---

## Phase 6: Supply Chain Logic Bug Playbook

### Pattern 1: Dependency Behavior Change

```
Scenario: Library updates validation logic
Old: validate(input) → throws on invalid
New: validate(input) → returns false on invalid
Host code: if (validate(input)) { process(input) }
Result: Invalid input now silently processed
```

### Pattern 2: Configuration Drift

```
Scenario: New feature adds config option
Default: feature_enabled = false
But: Orchestration layer sets feature_enabled = true
Result: Security feature disabled in production
```

### Pattern 3: Missing Update Side Effects

```
Scenario: Dependency fixes vulnerability
Fix: Adds origin check to API
But: Host app never calls the new validation function
Result: Fix is ineffective
```

### Pattern 4: Behavioral Regression

```
Scenario: Library v3.1 → v3.2
v3.1: encrypt(data, key) → returns encrypted bytes
v3.2: encrypt(data, key) → returns base64(encrypted bytes)
Host: expects raw bytes, stores base64 output
Result: Double-encoded data stored
```

---

## Phase 7: Tooling & Automation

### For Logic Bug Discovery

| Tool | Use Case |
|------|----------|
| `ironcurtail/` | Agent runtime with policy engine for testing |
| `tracee/` | Runtime behavior monitoring across processes |
| `Android-Pentesting-Skill/` | Mobile IPC testing, intent analysis |
| `Bug-Bounty-Agents/bizlogic-hunter.md` | Business logic vulnerability hunting |
| `Bug-Bounty-Agents/exploit-chainer.md` | Multi-step exploit chain construction |

### For LLM-Agent Logic Bugs

| Tool | Use Case |
|------|----------|
| Entry #109, Agent4Cyc papers | Academic guidance for agent-specific bug patterns |
| `Bug-Bounty-Agents/llm-redteam.md` | LLM red-teaming for agent testing |
| Prompt injection toolkit | Test agent prompt boundaries |

### For Supply Chain Analysis

| Tool | Use Case |
|------|----------|
| `grype/` | Dependency vulnerability scanning |
| `syft/` | SBOM generation |
| `cve-lite-cli/` | OWASP dependency scanner (offline) |
| `ironcurtail/` | Supply chain policy enforcement |

---

## References

- Entry #075: Orange Tsai Pwn2Own Edge sandbox escape ($175k)
- Entry #011: Multi-agent system for vulnerability research
- Entry #035: IronCurtain secure agent runtime
- Entry #042: Chrome V8 RCE ($55k)
- Entry #036: Big Sleep AI zero-day discovery
- Entry #109, Agent4Cyc #36: Teams of LLM Agents Exploit Zero-Day
- Entry #109, Agent4Cyc #40: LLM Agents Autonomously Exploit One-Day
- Entry #109, Agent4Cyc #42: WIPI — Web Threat for LLM-Driven Agents
- Entry #109, Agent4Cyc #52: LLM Agents Hack Websites
- Entry #109, Vuln Detection #82: GPTScan — Logic Vulns in Smart Contracts
- Entry #109, Vuln Detection #15: Let the Trial Begin — Mock-Court Approach

## Priority Assessment

- **Logic bugs in browser/OS sandbox boundaries:** CRITICAL (P0, $100k+)
- **Logic bugs in web app authorization:** HIGH (P1, $5k-$15k)
- **Supply chain logic conflicts:** HIGH (P1, $3k-$10k)
- **IPC logic flaws:** HIGH (P1, $5k-$20k)
- **State confusion/TOCTOU:** MEDIUM (P2, $2k-$8k)
- **Multi-step workflow bypass:** MEDIUM (P2, $1k-$5k)
