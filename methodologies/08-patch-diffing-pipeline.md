# Patch-Diffing Pipeline for N-Day Exploit Generation

## Overview

Complete methodology for building an automated patch-diffing → exploit generation pipeline, based on Tyler Holmwood's PatchWatch + Pocsmith system (Entry #078). Turns a Patch Tuesday release into verified exploits for ~$300 in API tokens.

**Source:** Entry #078 — Tyler Holmwood: The Mythos We Have At Home
**Cost:** ~$300 in API tokens per CVE (Opus-4.7)
**Open-Source Tools:** PatchWatch, hyperv-mcp, kd-mcp, pocsmith-mcp, pyghidra-mcp

---

## Architecture

```
Patch Tuesday (MSRC)
       │
       ▼
┌─────────────────────────────┐
│      PATCHWATCH (Rust)      │  ← Ingestion & Analysis Engine
│                             │
│  1. Poll MSRC API           │
│  2. Fetch KB + CVE metadata │
│  3. Pull binaries (Winbindex│
│  4. Ghidriff binary diff    │
│  5. LLM synthesis + analysis│
│  6. Output report.md        │
└──────────┬──────────────────┘
           │ report.md
           ▼
┌─────────────────────────────┐
│       POCSMITH (Claude SDK) │  ← Exploit Generation Harness
│                             │
│  MCP Servers:               │
│  ├─ hyperv-mcp (VM mgmt)    │
│  ├─ kd-mcp (kernel debug)   │
│  ├─ pyghidra-mcp (analysis) │
│  └─ pocsmith-mcp (tools)    │
│                             │
│  3 Levels:                  │
│  A → Crash reproduction    │
│  B → Controlled primitive   │
│  C → Full exploit           │
└─────────────────────────────┘
```

---

## Stage 1: PatchWatch — Ingestion & Analysis

### Step 1.1 — Poll MSRC

**On Patch Tuesday:**
- Query MSRC Security Update Guide API for all CVEs in the release
- Store CVE metadata (CVSS, affected products, KB number)

**Tiered Triage:**
| Tier | Criteria | Action |
|------|----------|--------|
| 1 | CVSS ≥ 9.0 or actively exploited | Immediate analysis |
| 2 | CVSS 7.0-8.9 | Queue for review |
| 3 | CVSS < 7.0 | Store for later |

### Step 1.2 — Fetch Binaries

**Use Winbindex** (@m417z) to query pre- and post-patch binaries:
- Query by KB, version, and hash
- Returns direct download URLs for both versions

**Fallback:** Download MSU directly and extract when CSV is missing from Microsoft support feed.

### Step 1.3 — Binary Diffing

**Tool:** **Ghidriff** (@clearbluejar's CVE North Stars workflow)

**Requirements:**
- CLI-driven (fully automated)
- Fast batch processing
- Natural language output for LLM ingestion

**Output per binary:**
| Artifact | Content | Use |
|----------|---------|-----|
| DiffSummary | Changed functions, similarity ratios, string changes | Cheap LLM synthesis pass |
| DiffIndex | Full pre/post-patch decompiled C for every modified function | Deep analysis engine |

### Step 1.4 — LLM Analysis Passes

**Pass 1: Synthesis**
- Feed DiffSummary through LLM
- Rank files by likelihood of containing the actual fix
- Brief justification per file

**Pass 2: Deep Analysis**
- Feed DiffIndex (decompiled C) for top-ranked functions
- Walk through pre/post change
- Produce concrete findings per function

### Step 1.5 — Output `report.md`

**Contains:**
- Narrative of what the patch does
- Relevant functions with pre/post decompiled code
- Confidence-ranked list of where the fix lives
- Binary hashes for verification

**This file is the handoff to Pocsmith.**

---

## Stage 2: Pocsmith — Exploit Generation

### Step 2.1 — Environment

**MCP Servers:**
| Server | Purpose |
|--------|---------|
| `hyperv-mcp` | VM lifecycle: create, checkpoint, restore, copy files, execute, reboot |
| `kd-mcp` | Kernel debugger: attach, breakpoint, read, write, step, resume, crash dump |
| `pyghidra-mcp` | Static analysis: function structure, offsets, code verification |
| `pocsmith-mcp` | Compile C, run Python, state tracking: record_attempt, report_outcome, end_phase |

**VM Configuration:**
- KDNET-attached Hyper-V VM
- Ghidra project (from diffing step)
- C compiler (MSVC via vcvarsall)
- VR tools (impacket, sysinternals, Python venv)
- Pre/post-patch binaries cached locally

### Step 2.2 — Three-Level Exploit Framework

| Level | Goal | Success Signal |
|-------|------|---------------|
| **A** | Crash reproduction | Kernel bugcheck or exploitable exception |
| **B** | Controlled primitive | Reliable read/write or controlled corruption |
| **C** | Full exploit | Code execution or privilege escalation |

**Each level has:**
- Time budget
- Iteration budget
- Dollar budget (configured in pocsmith.yaml)
- Hard ceilings — agent stops when exceeded

### Step 2.3 — Phase-Based Execution

**Phase structure:**
```
Phase 1: Read report.md → Analyze patch diff → Form hypothesis
         ↓
Phase 2: Set breakpoints → Trigger bug → Observe behavior
         ↓
Phase 3: Write POC → Compile → Execute → Capture result
         ↓
Phase 4: If success → Restore clean VM → Re-verify (2x)
         If fail → Write notes.md → Reset context → New phase
```

**Key Design Decisions:**
- **Phase boundary** = checkpoint where agent writes state to `notes.md`
- **Agent's own notes are its memory** — Pocsmith doesn't summarize or interpret
- **Context window reset** at each phase boundary
- **Verification pass:** 2 independent runs from clean state before promotion

### Step 2.4 — Human-in-the-Loop

- All workspace artifacts persist between runs
- Human can drop in with Claude instance inheriting MCP config
- Manual work whenever agent gets stuck
- Resume support: `--resume` flag
- Context injection: `--hint` flag

---

## Stage 3: Windows-Specific Patch Diffing

### Understanding Windows Update Structure

**Patch Tuesday:** Second Tuesday of every month
**Cumulative updates:** KB5083768 contains 28,000+ file changes
**Challenge:** Cannot diff everything — token bankruptcy

**Solution:**
- Winbindex handles binary cataloguing
- Tiered triage filters to high-value CVEs
- Per-binary diffing (not per-file-set)

### Common Windows Vulnerability Patterns

| Pattern | What to Look For |
|---------|-----------------|
| String length hardening | Manual NUL walks → bounded helpers |
| Integer overflow guards | Missing wrap checks → STATUS_INTEGER_OVERFLOW |
| Buffer size bumps | 0x48 → 0x50 style allocation changes |
| Function replacement | Entire function replaced with safer variant |
| WIL/telemetry changes | Usually noise, filter out |
| Feature flag gating | New code paths behind flags |

### From the Demo: CVE-2026-41096

**ws2_32.dll pattern:** Unsafe inline NUL-walk → `StringLengthWorkerW` bounded helper
**webio.dll pattern:** Missing integer-overflow guards → explicit wrap checks + allocation size bump (0x48 → 0x50)

---

## Cost Optimization

### Current Costs (~$300/CVE)
- Bulk: Opus-4.7 inference
- PatchWatch: modest (summary + synthesis passes)
- Pocsmith: bulk (exploit iteration)

### Optimization Strategies

| Strategy | Savings | Effort |
|----------|---------|--------|
| Prompt caching across diff passes | High | Low |
| Tiered model selection (Haiku/Sonnet/Opus) | High | Medium |
| Decouple from Anthropic (arbitrary models) | Variable | High |
| Reduce iteration budget | Proportional | Low |

---

## Tooling Reference

### Required Tools

| Tool | Purpose | Source |
|------|---------|--------|
| Ghidriff | Binary diffing engine | @clearbluejar |
| Winbindex | Windows binary index | @m417z |
| Ghidra | Static analysis | NSA |
| Claude Agent SDK | Agent orchestration | Anthropic |
| Hyper-V | VM isolation | Microsoft |
| KDNET | Kernel debugging | Microsoft |

### MCP Servers (Open-Sourced)

| Server | GitHub |
|--------|--------|
| hyperv-mcp | Available in Entry #078 |
| kd-mcp | Available in Entry #078 |
| pocsmith-mcp | Available in Entry #078 |
| pyghidra-mcp | @clearbluejar |

---

## References

- Entry #078: Tyler Holmwood — Patch-Diffing Pipeline (primary source)
- Entry #011: Multi-agent orchestration
- Entry #077: Microsoft debate/dedup/prove pipeline
- Entry #036: Big Sleep AI zero-day
- Entry #042: Chrome V8 RCE $55k

## Priority Assessment

- **N-day exploit generation from Patch Tuesday:** CRITICAL (P0, $5k-$175k)
- **Binary diffing for variant analysis:** HIGH (P1, $3k-$20k)
- **Automated crash reproduction:** HIGH (P1, $1k-$10k)
- **Full exploit chain from diff:** CRITICAL (P0, $20k-$175k)
