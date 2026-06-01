# How to Add New Resources

This file explains how to add new findings, writeups, tools, or techniques to the framework. The process is designed to be **paste-and-update** — drop the content and we'll handle the indexing.

---

## Quick Add (Recommended)

**Just paste your content in chat with the new finding, like:**

> "Blockaid found X targeting Y on chain Z, $amount drained..."
>
> "New writeup: @researcher did ATO via B technique, $C bounty..."
>
> "New tool: github.com/foo/bar for X vulnerability class..."

The AI assistant will:
1. Detect this is a new resource
2. Append a properly-formatted entry to `resources/00-INBOX.md` (next available number)
3. Update `inbox-metadata.json` (entries array, statistics, critical list, high-value bounties)
4. Update `resources/categorized-resources.md` (master index + by-niche + by-vuln-type + by-resource-type)
5. Update `resources/VULN-INDEX.md` (cross-references in the appropriate section)
6. Reference the new entry in any relevant workflow (01-08)
7. Commit + push to GitHub

---

## Manual Add (If You Prefer to Edit Directly)

### Step 1: Pick the next entry number

Check the last entry in `resources/00-INBOX.md`:
```bash
# Last entry
Select-String -Path "resources\00-INBOX.md" -Pattern "^### Entry #" | Select-Object -Last 1
# Use the next number
```

### Step 2: Append to `resources/00-INBOX.md`

Use this template (copy-paste and fill in):

```markdown
### Entry #XXX — [Short Title] ([Bounty Amount])

**Source:** [URL or @handle]
**Date Added:** YYYY-MM-DD
**Type:** [Writeup/Methodology/Tool/Resource List/Case Study]
**Priority:** [CRITICAL/HIGH/MEDIUM/LOW]

**Content:**
[Full description, attack flow, PoC, addresses, code snippets]

**Niche:** [Web/API/AI/Crypto/Cloud/Mobile/Browser/Enterprise/Kernel/MCP]
**Vuln Type:** [OAuth Hijacking/IDOR/SQLi/XSS/SSRF/Logic/...]
**Priority:** [CRITICAL/HIGH/MEDIUM/LOW]
**Kiro Mapping:**
- Skill: [which skill applies]
- Methodology: [which methodology]
- Workflow: [which workflow]
- Template: [any new template]
- Steering: [any steering update]

**Notes:** [Anything else relevant]

---
```

### Step 3: Update `inbox-metadata.json`

Add the entry to the `entries` array, and (if CRITICAL) to `critical_entries` and (if high bounty) to `high_value_bounties`. Increment `total_entries` and update relevant `statistics`.

### Step 4: Update `resources/categorized-resources.md`

Add a row to the master index, and add the number to the relevant "By Niche" / "By Vuln Type" / "By Resource Type" sections.

### Step 5: Update `resources/VULN-INDEX.md`

Add a row to the relevant vuln class section (XSS, SSRF, IDOR, OAuth, etc.).

### Step 6: (Optional) Reference in Workflows

If the finding warrants a new technique, reference it in the relevant workflow file (01-08) and add a phase or test case.

### Step 7: Commit + Push

```bash
git add .
git commit -m "Add Entry #XXX — [short title]"
git push origin main
```

---

## Bulk Add

If you have a list of findings to add at once (e.g., from a Twitter thread, blog post, or conference), just paste the whole thing in chat with a note like:

> "Add these 5 findings to the inbox: ..."

The AI will:
- Detect each distinct finding
- Number them sequentially
- Process each through steps 2-6 above
- Single commit + push

---

## What Gets Updated Automatically

| File | Auto-Update |
|---|---|
| `resources/00-INBOX.md` | New entry appended |
| `inbox-metadata.json` | New entry in array, stats, critical list, high-value bounties |
| `resources/categorized-resources.md` | Master index row, by-niche/vuln/resource sections |
| `resources/VULN-INDEX.md` | Cross-reference in vuln class section |
| `README.md` | Resource count if needed |
| Relevant workflows | Phase or test case added |
| `inbox-metadata.json` extraction date | Updated to today |

---

## What Doesn't Get Updated Automatically

| Item | Manual Action |
|---|---|
| Root-level status docs (STATUS.md, SYSTEM-COMPLETE.md) | Periodic manual refresh |
| Submodule dirs (cloned-resources/) | `git submodule update --init --recursive` |
| Generated counts in framework-librarian skill | Periodic manual refresh |
| File numbering issues (duplicate `03-`, `05-` prefixes) | Manual renumbering |

---

## Tips for Best Results

1. **Provide source/URL** when possible — adds attribution value
2. **Include bounty amount** if known — populates high_value_bounties
3. **Include addresses/handles** for crypto exploits — adds forensics value
4. **Quote the attack flow verbatim** if it's a writeup — keeps fidelity
5. **Mention if it's a methodology vs. a one-off finding** — affects categorization
6. **Tag with niche** (web/api/ai/crypto/etc.) and **vuln type** — speeds indexing

---

## Examples of Past Adds (For Reference)

### Example 1: One-shot finding
User: "Blockaid detected SquidRouterModule exploit on Ethereum/Base, 86 Gnosis Safes drained for ~$3M..."

What got added:
- Entry #176 to 00-INBOX.md (full writeup with addresses, drain tx, root cause)
- inbox-metadata.json: entry in array, critical_entries list, high_value_bounties (top of list at $3M)
- categorized-resources.md: row in master index, "Crypto/DeFi" niche, "DelegateCall Impersonation" vuln type
- VULN-INDEX.md: row in Web3/DeFi section
- 04-crypto-hunt.md: new Phase 4.3 (Safe Module / DelegateCall Impersonation)
- 05-adaptive-hunt.md: Technique 7 (DeFi Safe Module)
- 06-xalgorix-22-phase.md: Phase 25

### Example 2: Resource link only
User: "https://github.com/huhusmang/Awesome-LLMs-for-Vulnerability-Detection"

What got added:
- Entry #184 to 00-INBOX.md (resource list entry)
- inbox-metadata.json: entry in array
- categorized-resources.md: row in master index, "Resource Lists" resource type

### Example 3: Multiple findings at once
User: [pastes 5 tweets with distinct findings]

What got added:
- Entries #176, #177, #178, #179, #180 to 00-INBOX.md
- All 5 added to inbox-metadata.json
- All 5 added to categorized-resources.md (master + niche + vuln type)
- Each added to VULN-INDEX.md in appropriate sections
- Cross-references added to relevant workflows
- Single commit with all changes

---

## Last Updated

2026-05-25 — Initial version. Updated with the workflow additions for AI scanner and OTP auth bypass tests.
