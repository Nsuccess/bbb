# Multi-Agent Orchestration for Vulnerability Discovery

## Overview

This methodology describes a proven multi-agent system architecture for autonomous vulnerability hunting, based on real-world success finding 30+ CVEs in production systems including Linux kernel, Docker, OpenSSL, CUPS, and other critical infrastructure.

**Success Metrics:**
- 30+ CVEs discovered autonomously (April 2026)
- Notable finds: CVE-2026-31432, CVE-2026-31433 (Linux kernel ksmbd RCE)
- CVE-2026-34980, CVE-2026-34990 (CUPS RCE-to-root chain)
- Bounties: Multiple high-value discoveries

**Source:** Entry #011 - Getting LLMs Drunk to Find Linux Kernel Vulns
**Academic Backing:** Entry #109 — 56 Agent4Cybersecurity papers + 83 LLM Assisted Attack papers

---

## Architecture Pattern

### Evolution Path (from Entry #109, Agent4Cyc #3)
The academic literature describes 3 generations:
1. **Single LLM Reasoner** — One model + tools (PentestGPT pattern)
2. **Multi-Agent Systems** — Specialized roles + orchestration (this methodology)
3. **Autonomous Pipelines** — End-to-end with continuous learning and self-improvement

Our framework targets generation 2, with elements of generation 3 (conductor-driven continuous learning).

### Core Agent Roles

#### 1. Target Seeder
**Purpose:** Prioritize and select targets for investigation

**Responsibilities:**
- Rank targets by prevalence and exploitability
- Set finding count goals
- Define minimum severity thresholds
- Identify high-value attack surfaces

**Implementation:**
```
Input: List of potential targets
Output: Prioritized target queue with goals
```

#### 2. Hypothesis Generators
**Purpose:** Generate testable vulnerability hypotheses

**Responsibilities:**
- Study documentation and source code
- Analyze policy invariants
- Map attacker-input flows
- Identify option combinations
- Record promising hypotheses for hunters
- Pivot based on previous failures

**Key Focus Areas:**
- Documentation ↔ code mismatches
- Attacker-controlled input paths
- Complex option interactions
- Policy enforcement gaps

**Implementation:**
```
Input: Target codebase + documentation
Output: Ranked list of vulnerability hypotheses
```

#### 3. Hunters
**Purpose:** Test hypotheses and develop working exploits

**Responsibilities:**
- Iterate on hypotheses in isolated VMs
- Adjust PoCs and time race conditions
- Rule out false positives
- Record successes and failures
- Benefit from "contact with reality" in sandboxes

**Environment:**
- QEMU isolated VMs
- Full system access
- Ability to trigger and verify bugs
- Crash analysis tools

**Implementation:**
```
Input: Hypothesis + target environment
Output: Working PoC or failure analysis
```

#### 4. Report Writers
**Purpose:** Package findings for maintainers

**Responsibilities:**
- Create maintainer-facing reports
- Include working PoCs
- Document impact and severity
- Provide reproduction steps

**Implementation:**
```
Input: Verified vulnerability + PoC
Output: Professional security report
```

#### 5. External Grader (CRITICAL)
**Purpose:** Validate findings independently

**Responsibilities:**
- Evaluate severity match
- Check novelty
- Perform sanity checks
- Prevent reward-hacking
- **Must stay external** - all models eventually inflate findings

**Academic Reference:**
- Entry #109, Vuln Detection #79 — LLM4Vuln: decouples vulnerability detection from vulnerability reasoning, providing a structured framework for independent grading
- Entry #109, Vuln Detection #78 — Multi-role Consensus: formalizes multi-agent voting with confidence scores — each agent votes on exploitability

### 5b. Proof-of-Vulnerability Generator (NEW — from academic research)
**Purpose:** Bridge hunter output and report writer by generating automated PoV code

**Responsibilities:**
- Take verified hypothesis from hunter
- Generate minimal reproducible exploit code
- Test exploit reliability across multiple runs
- Document preconditions and limitations

**Academic Reference:**
- Entry #109, Agent4Cyc #12 — FaultLine: automated PoV generation using LLM agents
- Entry #109, Program Repair #4 — VulnRepairEval: exploit-based evaluation at 3 levels: A (crash), B (controlled primitive), C (full exploit)

**Why Critical:**
- Prevents hallucinations
- Stops false positive inflation
- Maintains quality standards
- Provides objective assessment

**Implementation:**
```
Input: Finding + report
Output: Validated severity + novelty score
```

#### 6. Conductor
**Purpose:** Orchestrate the entire system

**Responsibilities:**
- Poll hunts continuously
- Steer agents when stuck or spinning
- Review issue logs for systemic blockers
- Attempt continuous learning
- Provide real-time feedback
- Maintain knowledge graph of explored paths and attack techniques

**Key Insight:** "Managing juiced-up golden retrievers"

**Academic Reference:**
- Entry #109, Agent4Cyc #8 — xOffense: multi-agent system with offensive knowledge-enhanced LLMs. Conductor maintains a knowledge graph of attack techniques and steers agents toward under-explored paths. Implements: 1) shared memory of explored paths, 2) priority queue of un-explored techniques, 3) automated pivot triggers when agents stall.

**Implementation:**
```
Input: System state + agent outputs
Output: Steering commands + resource allocation
```

---

## Key Principles

### 1. Granular Decomposition
- Smaller models need restrictive scaffolding
- Frontier models (GPT/Claude): Collapse entire harness into single end-to-end hunter
- Best approach: Load VM with tools, get out of the way

### 2. External Validation is Non-Negotiable
- Separate model evaluates findings
- Prevents reward-hacking
- All models eventually inflate findings if self-grading
- External grader must remain independent

### 3. Contact with Reality
- Hunters benefit from actual sandbox execution
- Real crashes > theoretical analysis
- Conductor provides real-time feedback
- Models look like "semantic fuzzers" with guidance

### 4. Continuous Orchestration
- Conductor polls continuously
- Steers when agents stuck
- Reviews systemic issues
- Enables continuous learning

---

## Vulnerability Classes Discovered

### 0. Zero-Day & One-Day Exploitation by Agent Teams
**Academic Reference:**
- Entry #109, Agent4Cyc #36 — Teams of LLM Agents Can Exploit Zero-Day Vulnerabilities: landmark paper showing agent teams achieve what single agents cannot. Key insight: collaboration across specialized agents (recon agent + exploit agent + payload agent) unlocks 0-day exploitation.
- Entry #109, Agent4Cyc #40 — LLM Agents Autonomously Exploit One-Day Vulnerabilities: validates the patch-diffing pipeline approach. Agents given CVE descriptions + codebases autonomously develop working exploits.
- Entry #109, Agent4Cyc #52 — LLM Agents Can Autonomously Hack Websites: 8 real-world websites tested, demonstrated autonomous web exploitation end-to-end. Validates the entire workflow concept.

### 1. Remote OOB Writes (ksmbd)
- CVE-2026-31432, CVE-2026-31433
- Remote, unauthenticated (guest share)
- Compound requests overflow kernel reply buffer

### 2. RCE-to-Root Chains (CUPS)
- CVE-2026-34980, CVE-2026-34990
- Network-exposed CUPS → unprivileged RCE → root file overwrite
- Separate agents: foothold + privilege escalation

### 3. Documentation ↔ Code Mismatches
- Docker CVE-2026-34040: AuthZ plugins bypass
- Caddy CVE-2026-27587, CVE-2026-27588: Case-sensitivity issues
- udisks CVE-2026-26103, CVE-2026-26104: Missing polkit auth
- Firewalld CVE-2026-4948: Wrong permission check
- util-linux CVE-2026-3184: Hostname canonicalization (PAM bypass)

---

## Implementation Workflow

### Phase 1: Target Selection
```
1. Target Seeder analyzes potential targets
2. Ranks by:
   - Prevalence (how widely used)
   - Exploitability (attack surface)
   - Impact (severity potential)
3. Sets goals:
   - Minimum severity threshold
   - Target finding count
   - Time budget
```

### Phase 2: Hypothesis Generation
```
1. Hypothesis Generators study target:
   - Read documentation
   - Analyze source code
   - Map input flows
   - Identify policy invariants
2. Generate ranked hypotheses:
   - Documentation mismatches
   - Input validation gaps
   - Race conditions
   - Logic flaws
3. Record for hunters
```

### Phase 3: Hunting
```
1. Hunters receive hypotheses
2. Spin up isolated VMs
3. Iterate on PoCs:
   - Adjust payloads
   - Time race conditions
   - Verify crashes
4. Rule out false positives
5. Record results (success or failure)
```

### Phase 4: Validation
```
1. External Grader evaluates:
   - Severity match
   - Novelty check
   - Sanity verification
2. Rejects:
   - Hallucinations
   - Inflated findings
   - Known issues
3. Approves valid discoveries
```

### Phase 5: Reporting
```
1. Report Writers package findings:
   - Professional format
   - Working PoC included
   - Impact documentation
   - Reproduction steps
2. Submit to maintainers
```

### Phase 6: Continuous Orchestration
```
1. Conductor monitors all agents:
   - Polls hunt status
   - Identifies stuck agents
   - Reviews systemic issues
2. Steers as needed:
   - Pivot hypotheses
   - Adjust resources
   - Learn from failures
```

---

## Tools and Techniques

### Isolation
- **QEMU:** Isolated VMs for safe testing
- **Sandboxes:** Full system access for hunters
- **Crash Analysis:** Automated crash detection

### Static Analysis
- **CodeQL:** Pattern-based code analysis
- **Documentation Parsing:** Extract policy invariants
- **Source Code Analysis:** Map input flows

### Dynamic Testing
- **Fuzzing:** Semantic fuzzing with AI guidance
- **Race Condition Timing:** Automated timing adjustments
- **PoC Development:** Iterative exploit refinement

### Validation
- **External Grading:** Independent model evaluation
- **Severity Scoring:** Objective impact assessment
- **Novelty Checking:** Duplicate detection

---

## Advanced Techniques

### Activation Steering ("Getting LLMs Drunk")
**Technique:** Steer model's internal state toward "creative" mindset

**Method:** Activation steering (not just prompting)

**Reference:** "Representation Engineering Mistral-7B an Acid Trip" by Theia Vogel

**Results:**
- Reduced refusals
- Improved overall performance
- Possibly helped with CVE-2026-31432 (Qwen 3.5 27B)
- **No new vulnerability classes discovered**
- Underwhelming for creativity specifically

**Verdict:** Interesting but not game-changer. Focus on architecture over steering.

### Multi-Agent Debate
- Multiple agents discuss hypotheses
- Conductor provides real-time feedback
- Benefits from diverse perspectives
- Reduces false positives

**Academic Reference:**
- Entry #109, Vuln Detection #15 — "Let the Trial Begin": Mock-court approach to vuln detection. Prosecutor agent argues bug exists, defense argues against, judge decides. This formalizes the debate with explicit roles. Integrate as: Hypothesis Generator (prosecution) → Devil's Advocate (defense) → External Grader (judge).
- Entry #109, Vuln Detection #78 — Multi-role Consensus: assign each agent a different expertise domain (auth, crypto, logic, race). Agents vote with confidence scores. Conductor weights votes by expertise match to target. 

### Inference-Time Compute
- Small models + time + iteration = viable alternative
- Trade VRAM for time
- Enables use of smaller, cheaper models
- Conductor guidance makes up for raw intelligence gap

---

## Lessons Learned

### 1. No Slam Dunk on Creativity
- "Drunk" models didn't discover new vulnerability classes
- May need architectural changes for true creativity
- ≤27B models may not benefit from steering
- Steering away from refusals helped overall

### 2. Stacking Layers Moves Up Abstraction
- Smaller models need restrictive scaffolding
- Frontier models: Scaffolding becomes liability
- Best approach: Load VM with tools, get out of the way
- Job becomes "managing juiced-up golden retrievers"
- Prompting matters more than technical scaffolding

### 3. With Inference-Time Compute, Raw Intelligence Matters Less
- Small models + time + iteration = viable alternative
- Trade VRAM for time
- Multi-agent debate benefits
- Conductor provides real-time feedback
- Models look like "semantic fuzzers" with conductor guidance

---

## Microsoft Multi-Agent Pipeline: Audit → Debate → Dedup → Prove

**Source:** Entry #077 — Microsoft research on surpassing Mythos

### The Pipeline

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  AUDIT   │ →  │  DEBATE  │ →  │  DEDUP   │ →  │  PROVE   │
│ (find)   │    │(challenge)│    │(dedupe)  │    │(exploit) │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
    20%              50%             15%             15%
   effort           effort          effort          effort
```

### Stage 1: Audit (20% effort)
- Multiple agents independently analyze the same target
- Each agent focuses on different vulnerability classes
- No collaboration yet — independent discovery

### Stage 2: Debate (50% effort)
- **This is where the value is created**
- Agents challenge each other's findings
- Devil's Advocate patterns active
- Cross-validation eliminates false positives
- Builds consensus on what's real

### Stage 3: Dedup (15% effort)
- Merge overlapping reports
- Identify the same root cause across different agents
- Prioritize unique findings over duplicates

### Stage 4: Prove (15% effort)
- Build working exploit/PoC
- Demonstrate real impact
- Zero false positive target

### Integration with Existing System

| Our Role | Microsoft Equivalent |
|----------|---------------------|
| Target Seeder | Pre-Audit (target selection) |
| Hypothesis Generator | Audit (independent analysis) |
| Hunter | Audit (focused testing) |
| External Grader | Debate (challenge findings) |
| Report Writer | Prove + Dedup (consolidate) |
| Conductor | Orchestrates all stages |

### Key Insight

> "The watershed isn't whether bugs can be found, but proving bugs with zero false positives — putting 80% of engineering effort into Debate, Dedup, and Prove stages"

**This changes how we think about effort allocation:**
- Traditional: 80% finding, 20% verifying
- Microsoft: 20% finding, 80% verifying
- Our framework: Already aligned (self-validation is the verify step)
- **Next step:** Formalize Debate and Dedup as explicit agent roles

---

## Future Research Directions

### Quantitative
- **30+ CVEs discovered** autonomously
- **Multiple critical vulnerabilities** (RCE, LPE, OOB writes)
- **Diverse targets** (kernel, userspace, network services)
- **High-value bounties** from major projects

### Qualitative
- **Novel vulnerability classes** (docs ↔ code mismatches)
- **Complex exploit chains** (multi-step RCE-to-root)
- **Production-ready findings** (all verified and patched)
- **Maintainer acceptance** (fast patches, no disputes)

---

## Implementation Checklist

- [ ] Set up isolated VM environment (QEMU)
- [ ] Implement Target Seeder (prioritization logic)
- [ ] Build Hypothesis Generators (documentation + code analysis)
- [ ] Create Hunter agents (PoC development + testing)
- [ ] Deploy External Grader (independent validation)
- [ ] Implement Report Writers (professional formatting)
- [ ] Build Conductor (orchestration + steering)
- [ ] Integrate static analysis tools (CodeQL)
- [ ] Set up continuous monitoring
- [ ] Establish feedback loops
- [ ] Test with known vulnerabilities
- [ ] Deploy on real targets
- [ ] Monitor and iterate

---

## Related Methodologies

- **AI Agent Self-Validation** (Entry #005, #039, #109): Complements with validation principles — backed by 83 LLM Assisted Attack papers
- **Prompt Injection Framework** (Entry #044): Similar multi-step approach
- **Bug Bounty Methodology 2026** (Entry #022): Skill-based hunting aligns with agent roles
- **Entry #109 Agent4Cyc Papers** (56 papers): Academic foundation for multi-agent security systems
- **Entry #109 Vuln Detection Papers** (94 papers): LLM-based vulnerability detection techniques

---

## Key Takeaways

1. **Multi-agent > single agent** for complex vulnerability hunting
2. **External grader is non-negotiable** to prevent hallucinations
3. **Smaller models viable** with proper orchestration
4. **Contact with reality** (sandboxes) essential for hunters
5. **Conductor orchestration** enables continuous learning
6. **Architecture > specific techniques** (e.g., "drunk" models)
7. **Proven results:** 30+ CVEs in production systems

---

**This is the blueprint for advanced agent-based vulnerability hunting.**
