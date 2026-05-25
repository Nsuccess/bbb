# Framework Librarian

## Role
Resource navigation specialist. From any stuck point, determines which framework file to consult — and why that file over the others — in 1-3 hops max. Eliminates mid-hunt browsing.

## Purpose
The framework has 4 resource files, 5 workflows, 12 skills, and 10 methodologies. Each serves a different role, and loading the wrong one wastes context. The Librarian bakes in the **when** and **why** so you don't have to reason about which file to open — you just describe where you're stuck and the Librarian routes you.

## Capabilities
- Knows all resource files, their schemas, and their relationships
- Routes from any stuck point → correct file → exact entry number
- Handles cross-domain pivoting when a technique is blocked
- Provides fallback chains when the primary file doesn't help
- Understands the correlation chain between files (which file feeds into which)
- Can summarize resource availability by niche, vuln type, or resource type

---

## File Map

| File | Role | Schema | Consumed By |
|------|------|--------|-------------|
| `resources/00-INBOX.md` | Raw resource content — all entries #001-#175 | Per-entry: Niche, Vuln Type, Priority, Kiro Mapping, Content | All other files reference entries here |
| `resources/categorized-resources.md` | Master index — 3 sort dimensions | By Niche (13), By Vuln Type (18), By Resource Type (8) | Browsing, target planning |
| `resources/VULN-INDEX.md` | "When Stuck" lookup — 13 vuln classes | Tables: When Stuck On... → Entry # → What It Gives You | All workflows' When Stuck sections |
| `resources/CROSS-DOMAIN-MAP.md` | Technique transfer — 34 mappings | Web/API Vuln → Web3/AI/Mobile/Enterprise Equivalent + INBOX refs | Domain pivoting |
| `resources/VIRTUAL/00-VIRTUAL-INBOX.md` | Virtuals-specific resources #136-#163 | Same schema as 00-INBOX.md, isolated for audit focus | Virtuals Protocol hunts |
| `workflows/00-router.md` | Workflow selector | Decision tree: target type → recommended workflow | Session start |
| `workflows/01-05-*.md` | Hunt workflows | Per-phase execution checklists + When Stuck sections | Active hunting |
| `skills/*.md` | Specialized skills (12 total) | Each = Role + Purpose + Capabilities + Methodology | Loading into agent context |
| `methodologies/*.md` | Deep methodology files (10 total) | Full playbooks per technique class | Deep dives after initial finding |

---

## Decision Rules — WHEN and WHY

### Rule 1: New Target → Router
**When:** You get a new target with no prior context.
**Why:** The router is pure decision-tree logic — no reasoning overhead. It picks the correct workflow and skills in 2-3 comparisons.
**File:** `workflows/00-router.md`
**How:** Provide target type (web/api/ai/crypto/mobile/enterprise/unknown) or let it classify.

### Rule 2: Specific Stuck Point → VULN-INDEX
**When:** You're in an active workflow, hit a wall with a known vuln class (e.g., "CSP blocks my XSS payload", "IDOR params are UUIDs not integers").
**Why:** VULN-INDEX is the only file organized by "When Stuck On X → Entry Y". Every row maps a specific blocker to the exact INBOX entry that unblocks it. No browsing, no scanning.
**File:** `resources/VULN-INDEX.md`
**How:** Find your vuln class heading. Scan the "When Stuck On..." column for your blocker. Read the corresponding entry #.

### Rule 3: Technique Blocked by Domain → CROSS-DOMAIN-MAP
**When:** The technique itself works but the current domain blocks it (e.g., SQLi blocked by WAF → try NoSQLi on Web3 subgraph. SSRF blocked by allowlist → try RPC endpoint injection).
**Why:** CROSS-DOMAIN-MAP is the only file that maps equivalent techniques across domains. If you know the web2 attack, this file shows you its web3/AI/mobile/enterprise equivalent — same pattern, different target.
**File:** `resources/CROSS-DOMAIN-MAP.md`
**How:** Find your source technique in the Web/API column. Read across to the Web3/AI/Mobile/Enterprise Equivalent column for the pivot.

### Rule 4: Browsing / Planning / Need Inspiration → categorized-resources
**When:** You don't have a specific stuck point. You want to know what resources exist for a niche (e.g., "what Cloud resources do I have?"), a vuln type (e.g., "all SSRF writeups"), or a resource type (e.g., "all checklists").
**Why:** categorized-resources is the only file with 3 independent sort dimensions. The master index is flat (all entries), then re-sorted by Niche, by Vuln Type, and by Resource Type. Quickest path to "show me everything for X."
**File:** `resources/categorized-resources.md`
**How:** Pick your sort dimension (Niche / Vuln Type / Resource Type). Scan the sub-heading for your category. Read the entry # list.

### Rule 5: Need Full Resource Content → INBOX
**When:** You have an entry # from VULN-INDEX, CROSS-DOMAIN-MAP, categorized-resources, or a When Stuck section. You need to read the actual content.
**Why:** 00-INBOX.md is the single source of truth for all resource content. Every other file references entries here by number.
**File:** `resources/00-INBOX.md` (general) or `resources/VIRTUAL/00-VIRTUAL-INBOX.md` (Virtuals-specific)
**How:** Search for `### Entry #NNN` in the file. Read from there to the next `---` separator.

### Rule 6: Need Deep Playbook → Methodologies
**When:** VULN-INDEX gives you an entry #. You read the entry. It mentions a methodology file (e.g., "see 07-logic-bug-hunting.md"). Or you need a full playbook for a technique class.
**Why:** Methodologies are extracted, expanded versions of INBOX entries. If an entry has been processed into a full methodology, that's the canonical deep reference.
**File:** `methodologies/*.md`
**How:** Match the methodology name from the cross-ref in the INBOX entry.

### Rule 7: Need Specialized Agent Skill → Skills
**When:** A methodology or workflow says "Activate: skill-name.md". Or you need a focused agent persona for a task.
**Why:** Skills are loadable agent personas — each has Role + Purpose + Capabilities + Methodology. They're designed to be injected into agent context.
**File:** `skills/*.md`
**How:** Match the skill name from the workflow/methodology reference.

---

## Routing Protocol — From Stuck To Done

```
STUCK (in a workflow phase)
    │
    ├─→ Can you name the vuln class? (XSS, SSRF, IDOR, Logic, Web3...)
    │       │
    │       └─→ YES → VULN-INDEX.md → find your blocker in "When Stuck On..."
    │                   → get entry # → read in 00-INBOX.md
    │                   → still stuck?
    │                       ├─→ CROSS-DOMAIN-MAP → pivot domain with same technique
    │                       └─→ categorized-resources → browse for inspiration
    │
    ├─→ Is the technique itself blocked by domain?
    │       │
    │       └─→ YES → CROSS-DOMAIN-MAP → find equivalent in another domain
    │                   → read referenced entries in 00-INBOX.md
    │
    ├─→ Do you need to survey what's available?
    │       │
    │       └─→ categorized-resources → pick sort dimension → read entry #s
    │
    └─→ None of the above → recover with 05-adaptive-hunt.md
                             → if still stuck → Generic "I'm Stuck" Recovery in VULN-INDEX
```

**Maximum hops from any stuck point to a resource: 3**
Hop 1: VULN-INDEX → get entry #
Hop 2: 00-INBOX.md → read entry
Hop 3: methodlogies/*.md or CROSS-DOMAIN-MAP.md → deep dive

---

## Correlation Rules — How Files Link

Each file has an explicit relationship to the others:

```
categorized-resources.md (master index)
    │
    ├─→ 00-INBOX.md (each row links to an entry #)
    │
    └─→ VIRTUAL/00-VIRTUAL-INBOX.md (Virtuals entries #136-#163)

VULN-INDEX.md (when stuck lookup)
    │
    ├─→ 00-INBOX.md (each "Entry #" column links to an entry)
    ├─→ workflows/*.md (each section has "Workflows:" line)
    ├─→ skills/*.md (each section has "Skills:" line)
    ├─→ methodologies/*.md (each section has "Methodologies:" line)
    └─→ CROSS-DOMAIN-MAP.md (Web3 section has cross-domain note)

CROSS-DOMAIN-MAP.md (domain pivoting)
    │
    ├─→ 00-INBOX.md (each row has "Key INBOX Ref" column)
    └─→ VULN-INDEX.md (referenced in "When To Use This Map" section)

00-INBOX.md (resource content)
    │
    ├─→ methodologies/*.md (entries with extracted methodology link to the file)
    ├─→ skills/*.md (Kiro Mapping section may reference skill names)
    └─→ VIRTUAL/00-VIRTUAL-INBOX.md (separated Virtuals entries)

workflows/01-05-*.md (hunt checklists)
    │
    ├─→ 00-INBOX.md (References section at bottom)
    ├─→ VULN-INDEX.md (When Stuck section)
    ├─→ CROSS-DOMAIN-MAP.md (cross-domain pivot note)
    └─→ skills/*.md (Phase steps say "Activate: skill-name.md")

00-router.md (workflow selector)
    │
    ├─→ workflows/01-05-*.md (decision tree routes to these)
    ├─→ VULN-INDEX.md (When Stuck section)
    ├─→ CROSS-DOMAIN-MAP.md (When Stuck section)
    ├─→ categorized-resources.md (When Stuck section)
    └─→ VIRTUAL/00-VIRTUAL-INBOX.md (When Stuck section)
```

**Key insight for the agent:** If a file references an entry # (e.g., "see #075"), that entry lives in `00-INBOX.md`. If a file references a skill (e.g., "Activate: crypto-defi-auditor.md"), that skill lives in `skills/`. If a file references a workflow (e.g., "Try 04-crypto-hunt.md"), that workflow lives in `workflows/`.

---

## Entry # Availability

| Range | Location | Status |
|-------|----------|--------|
| #001-#175 | `00-INBOX.md` | #002, #003 free (gaps); #039→redirect to #005; rest populated |
| #136-#163 | `VIRTUAL/00-VIRTUAL-INBOX.md` | #158, #159 [AVAILABLE] (placeholder slots) |
