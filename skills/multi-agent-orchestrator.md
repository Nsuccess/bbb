# Multi-Agent Orchestrator

## Role
Orchestration specialist for coordinating multiple AI agents in parallel bug hunting operations. Expert in agent decomposition, task distribution, conductor patterns, and multi-agent debate for complex vulnerability discovery.

## Purpose
Implement multi-agent architectures for autonomous vulnerability hunting based on proven patterns from Entry #011 (20+ CVEs discovered). Coordinate specialized agents (hypothesis generators, hunters, validators, report writers) with external grading and continuous conductor feedback.

## Capabilities
- Multi-agent system design and orchestration
- Parallel agent coordination per subsystem
- Scoped CLAUDE.md per agent (prevent context clobbering)
- Hypothesis generation and testing
- Hunter agent management in isolated VMs
- External grader implementation (prevent reward-hacking)
- Conductor polling and steering
- Subagent architecture (Binary Ninja, documentation, etc.)
- Multi-agent debate facilitation
- Skill discovery and distillation

## Methodology

### Phase 1: System Architecture

**Agent Roles (from Entry #011):**

**1. Target Seeder**
- Ranks targets by prevalence/exploitability
- Sets finding count/minimum severity goals
- Prioritizes high-value targets

**2. Hypothesis Generators**
- Study documentation, source code, policy invariants
- Analyze attacker-input flows, option combinations
- Record promising hypotheses for hunters
- Can pivot based on previous failures
- Focus on "docs ↔ code mismatch" vulnerabilities

**3. Hunters**
- Iterate on hypotheses in isolated VMs
- Adjust PoCs, time race conditions
- Rule out false positives
- Record successes/failures
- Benefit from "contact with reality" in sandboxes

**4. Report Writers**
- Package findings into maintainer-facing reports
- Include PoCs and evidence
- Professional formatting

**5. External Grader (CRITICAL)**
- Separate model evaluates findings
- Checks: severity match, novelty, sanity
- Prevents reward-hacking/inflated findings
- **Must stay external** - all models eventually inflate findings

**6. Conductor**
- Polls hunts continuously
- Steers agents when stuck/spinning
- Reviews issue log for systemic blockers
- Attempts continuous learning
- Provides real-time feedback

### Phase 2: Parallel Agent Deployment

**Pattern: One Agent Per Subsystem**

**Example (from Entry #001):**
- One agent exploring callstack
- One agent reproducing vulnerability
- One agent patching
- Scoped CLAUDE.md per agent to prevent context clobbering

**Subagent Architecture:**
- Subagent driving Binary Ninja (binja)
- Subagent for documentation
- Headless binja client + skill for Claude Code

**Benefits:**
- Parallel exploration
- Specialized focus
- No context interference
- Faster discovery

### Phase 3: Orchestration Patterns

**Pattern 1: Hypothesis → Hunt → Validate**
```
1. Hypothesis Generator creates theories
2. Hunter tests in isolated VM
3. Validator confirms exploitability
4. External Grader evaluates quality
5. Report Writer packages finding
6. Conductor reviews and steers
```

**Pattern 2: Multi-Agent Debate**
- Multiple agents analyze same target
- Agents debate findings
- Conductor synthesizes conclusions
- Reduces false positives

**Pattern 3: Skill Discovery**
- Agents discover new techniques
- Conductor distills into reusable skills
- Skills shared across agents
- Continuous improvement

### Phase 4: Conductor Implementation

**Conductor Responsibilities:**
1. **Continuous Polling**
   - Monitor all active hunts
   - Check progress and status
   - Identify stuck agents

2. **Steering When Stuck**
   - Detect spinning/stuck agents
   - Provide hints or new directions
   - Suggest alternative approaches

3. **Issue Log Review**
   - Track systemic blockers
   - Identify patterns in failures
   - Adjust strategy accordingly

4. **Continuous Learning**
   - Learn from successes
   - Learn from failures
   - Improve hypothesis generation

**Example Conductor Logic:**
```python
while hunting:
    for agent in active_agents:
        status = agent.get_status()
        
        if status == "stuck":
            hint = generate_hint(agent.context)
            agent.provide_hint(hint)
        
        elif status == "spinning":
            agent.pivot_approach()
        
        elif status == "success":
            finding = agent.get_finding()
            grader.evaluate(finding)
        
        elif status == "failure":
            learn_from_failure(agent.attempts)
    
    review_systemic_issues()
    adjust_strategy()
```

### Phase 5: External Grader (Non-Negotiable)

**Why External Grader is Critical:**
- All models eventually inflate findings
- Reward-hacking is inevitable
- Need independent evaluation
- Must stay external to hunting agents

**Grader Checks:**
1. **Severity Match**
   - Does claimed severity match actual impact?
   - Is CVSS score accurate?

2. **Novelty**
   - Is this a new finding?
   - Or duplicate of known issue?

3. **Sanity**
   - Does the finding make sense?
   - Is PoC realistic?
   - Is impact achievable?

**Grader Implementation:**
```python
def grade_finding(finding):
    checks = {
        "severity": verify_severity(finding),
        "novelty": check_novelty(finding),
        "sanity": sanity_check(finding),
        "exploitability": verify_poc(finding)
    }
    
    if all(checks.values()):
        return "ACCEPT"
    else:
        return "REJECT", failed_checks
```

### Phase 6: Isolated VM Testing

**Why Isolation:**
- Hunters need "contact with reality"
- Test in actual environments
- Verify exploitability
- Prevent false positives

**VM Setup:**
- QEMU for isolation
- Target software installed
- Network access for testing
- Snapshot/restore capability

**Hunter Workflow:**
1. Receive hypothesis from generator
2. Set up test environment in VM
3. Implement PoC
4. Test exploitation
5. Adjust and iterate
6. Record results (success/failure)
7. Report back to conductor

## Tools to Use

### Orchestration
- **Custom conductor script**: Coordinate agents
- **Message queue**: Agent communication
- **Database**: Track findings and status

### Agent Deployment
- **Multiple Claude Code instances**: Parallel agents
- **Scoped CLAUDE.md files**: Prevent context clobbering
- **Isolated workspaces**: Per-agent directories

### Testing Infrastructure
- **QEMU**: Isolated VMs for hunters
- **Docker**: Containerized test environments
- **Snapshot tools**: Quick environment reset

### Analysis
- **CodeQL**: Static analysis for hypothesis generation
- **Binary Ninja**: Reverse engineering (with subagent)
- **Debuggers**: Dynamic analysis

## Success Criteria

### Critical Success
- 20+ CVEs discovered (Entry #011 benchmark)
- High-severity findings (RCE, LPE, etc.)
- Novel vulnerability classes discovered
- Low false positive rate

### High Success
- 10+ CVEs discovered
- Multiple vulnerability types
- Efficient agent coordination
- Continuous learning demonstrated

### Medium Success
- 5+ CVEs discovered
- Proof of concept working
- Agent architecture validated

## Examples from Real Findings

### Example 1: Linux Kernel CVEs (Entry #011)
**Architecture:** Multi-agent system with conductor

**Results:**
- CVE-2026-31432, CVE-2026-31433: Remote unauthenticated OOB writes in Linux kernel ksmbd
- CVE-2026-34980, CVE-2026-34990: CUPS RCE-to-root chain
- 30+ total findings across Docker, OpenSSL, HAProxy, Caddy, Traefik, nginx, Samba, etc.

**Key Insights:**
- Hypothesis generators focused on "docs ↔ code mismatch"
- Hunters tested in isolated VMs
- External grader prevented false positives
- Conductor provided continuous feedback

**Techniques:**
- Smaller models (Qwen 3.5 27B) + time + iteration = viable
- Multi-agent debate benefits
- Real-time conductor feedback
- Models as "semantic fuzzers"

### Example 2: Parallel Subsystem Hunting (Entry #001)
**Architecture:** One agent per subsystem

**Agents:**
- Agent 1: Exploring callstack
- Agent 2: Reproducing vulnerability
- Agent 3: Patching

**Benefits:**
- Parallel exploration
- Specialized focus
- Faster discovery
- No context interference

**Note:** Not fully unattended - human still drives direction

## Key Patterns

### Granular Decomposition
- Smaller models need restrictive scaffolding
- Frontier models: scaffolding becomes liability
- Best approach: Load VM with tools, get out of the way
- Job becomes "managing juiced-up golden retrievers"

### Stacking Layers
- Moves up abstraction
- Prompting matters more than technical scaffolding
- With inference-time compute, raw intelligence matters less

### Inference-Time Compute
- Small models + time + iteration = viable alternative
- Trade VRAM for time
- Multi-agent debate benefits
- Conductor provides real-time feedback

## Future Research Directions

### 1. Looped LLMs
- Better multi-hop reasoning
- Could discover novel techniques (e.g., JBIG2 virtual CPU)

### 2. LLM Brain Surgery
- Repeat middle reasoning layers
- Increase reasoning capacity with minimal VRAM overhead

### 3. Optimal Decomposition & Orchestration
- RL-training for task decomposition
- "Mismanaged Geniuses hypothesis"
- Skill discovery and distillation
- GEPA (automatic prompt evolution)
- Dedicated conductor training

## Orchestration Checklist

- [ ] Define agent roles (seeder, generator, hunter, validator, grader, writer, conductor)
- [ ] Implement external grader (separate from hunters)
- [ ] Set up isolated VMs for hunters
- [ ] Create scoped CLAUDE.md per agent
- [ ] Implement conductor polling loop
- [ ] Define steering logic for stuck agents
- [ ] Set up multi-agent debate mechanism
- [ ] Implement skill discovery and distillation
- [ ] Track findings and status in database
- [ ] Monitor for systemic issues
- [ ] Adjust strategy based on learnings
- [ ] Ensure external grader stays external
- [ ] Test full pipeline end-to-end
- [ ] Measure false positive rate
- [ ] Optimize agent coordination

## Related Concepts
- Multi-Agent Systems
- Distributed Computing
- Orchestration Patterns
- Conductor Pattern
- External Validation
- Continuous Learning

## References
- Entry #011: Getting LLMs Drunk to Find Linux Kernel Vulns (20+ CVEs, multi-agent architecture)
- Entry #001: Multi-Agent Bug Hunting Discussion
- Entry #035: IronCurtain (multi-agent orchestration)
- Entry #036: Multi-agent coordination patterns
- Entry #072: Advanced orchestration techniques
