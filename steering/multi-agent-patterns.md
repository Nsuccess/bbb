---
inclusion: auto
description: Multi-agent orchestration strategies for autonomous vulnerability discovery and validation
keywords: multi-agent, orchestration, agents, automation, architecture, workflow
---

# Multi-Agent Orchestration Patterns

## Philosophy: Decomposition Over Monolithic Agents

**Core Insight**: Complex security research requires specialized agents working in concert, not a single general-purpose agent.

**Evidence**: 20+ CVEs discovered autonomously using multi-agent systems (April 2026).

## The Multi-Agent Architecture

### Proven Pattern (Entry #011)

**System Components**:

1. **Target Seeder**
2. **Hypothesis Generators**
3. **Hunters**
4. **Report Writers**
5. **External Grader** (CRITICAL)
6. **Conductor**

### 1. Target Seeder

**Responsibility**: Prioritize and rank targets.

**Inputs**:
- Target list
- Prevalence data
- Exploitability metrics
- Historical vulnerability data

**Outputs**:
- Ranked target list
- Finding count goals
- Minimum severity thresholds

**Implementation**:
```python
class TargetSeeder:
    def rank_targets(self, targets):
        """
        Rank targets by:
        - Prevalence (usage statistics)
        - Exploitability (attack surface)
        - Historical vulnerabilities
        - Bug bounty program availability
        """
        scored = []
        for target in targets:
            score = (
                target.prevalence * 0.4 +
                target.attack_surface * 0.3 +
                target.historical_vulns * 0.2 +
                target.has_bounty_program * 0.1
            )
            scored.append((target, score))
        
        return sorted(scored, key=lambda x: x[1], reverse=True)
    
    def set_goals(self, target):
        """Set finding goals based on target characteristics"""
        return {
            'min_findings': 3,
            'min_severity': 'HIGH',
            'max_time_hours': 24
        }
```

### 2. Hypothesis Generators

**Responsibility**: Generate testable vulnerability hypotheses.

**Activities**:
- Study documentation
- Analyze source code
- Review policy invariants
- Analyze attacker-input flows
- Identify option combinations
- Record promising hypotheses

**Can Pivot**: Based on previous failures, adjust hypothesis generation strategy.

**Output Format**:
```json
{
    "hypothesis_id": "H001",
    "target": "ksmbd",
    "category": "memory_corruption",
    "description": "Compound SMB requests may overflow kernel reply buffer",
    "attack_vector": "Remote, unauthenticated (guest share)",
    "test_approach": "Send crafted SMB compound requests with oversized responses",
    "expected_behavior": "Buffer overflow in kernel space",
    "confidence": 0.7,
    "references": [
        "SMB2 compound request documentation",
        "ksmbd reply buffer allocation code"
    ]
}
```

**Implementation Pattern**:
```python
class HypothesisGenerator:
    def generate_hypotheses(self, target, context):
        """
        Generate hypotheses by:
        1. Docs ↔ Code mismatch analysis
        2. Input flow analysis
        3. Option combination analysis
        4. Historical pattern matching
        """
        hypotheses = []
        
        # Docs-code mismatch
        doc_claims = self.extract_security_claims(target.docs)
        code_reality = self.analyze_implementation(target.code)
        mismatches = self.find_mismatches(doc_claims, code_reality)
        
        for mismatch in mismatches:
            hypotheses.append({
                'type': 'docs_code_mismatch',
                'description': mismatch.description,
                'test_approach': mismatch.test_approach,
                'confidence': mismatch.confidence
            })
        
        # Input flow analysis
        input_flows = self.trace_attacker_inputs(target.code)
        for flow in input_flows:
            if self.has_insufficient_validation(flow):
                hypotheses.append({
                    'type': 'insufficient_validation',
                    'flow': flow,
                    'test_approach': self.generate_test_for_flow(flow)
                })
        
        return hypotheses
    
    def pivot(self, failed_hypotheses):
        """Adjust strategy based on failures"""
        patterns = self.analyze_failure_patterns(failed_hypotheses)
        self.adjust_generation_strategy(patterns)
```

### 3. Hunters

**Responsibility**: Test hypotheses and develop exploits.

**Environment**: Isolated VMs (QEMU) for safe testing.

**Activities**:
- Iterate on hypotheses
- Adjust PoCs
- Time race conditions
- Rule out false positives
- Record successes/failures

**Key Feature**: "Contact with reality" - actual testing in sandboxes.

**Implementation Pattern**:
```python
class Hunter:
    def __init__(self, vm_manager):
        self.vm = vm_manager.create_isolated_vm()
        self.results = []
    
    def test_hypothesis(self, hypothesis):
        """
        Test hypothesis in isolated VM:
        1. Setup environment
        2. Execute test
        3. Observe behavior
        4. Validate exploitability
        5. Record result
        """
        # Setup
        self.vm.reset()
        self.vm.install_target(hypothesis.target)
        
        # Execute
        test_result = self.vm.execute_test(hypothesis.test_approach)
        
        # Validate
        if test_result.indicates_vulnerability:
            # Attempt exploitation
            exploit_result = self.develop_exploit(hypothesis, test_result)
            
            if exploit_result.successful:
                self.results.append({
                    'hypothesis_id': hypothesis.id,
                    'status': 'CONFIRMED',
                    'exploit': exploit_result.exploit,
                    'impact': exploit_result.impact
                })
            else:
                self.results.append({
                    'hypothesis_id': hypothesis.id,
                    'status': 'FALSE_POSITIVE',
                    'reason': exploit_result.failure_reason
                })
        else:
            self.results.append({
                'hypothesis_id': hypothesis.id,
                'status': 'NOT_VULNERABLE'
            })
        
        return self.results[-1]
    
    def develop_exploit(self, hypothesis, test_result):
        """
        Iteratively develop working exploit:
        - Adjust timing for race conditions
        - Refine payload
        - Test reliability
        - Verify impact
        """
        for iteration in range(10):
            exploit = self.generate_exploit(hypothesis, test_result, iteration)
            result = self.vm.test_exploit(exploit)
            
            if result.successful:
                return result
            
            # Learn from failure
            self.adjust_exploit_strategy(result.failure_mode)
        
        return ExploitResult(successful=False)
```

### 4. Report Writers

**Responsibility**: Package findings for maintainers.

**Outputs**:
- Vulnerability description
- Impact analysis
- Proof of Concept
- Reproduction steps
- Remediation guidance

**Format**:
```markdown
# Vulnerability Report: [CVE-ID]

## Summary
[One-line description]

## Severity
[CRITICAL/HIGH/MEDIUM/LOW]

## Affected Versions
[Version range]

## Description
[Detailed technical description]

## Impact
- [Impact 1]
- [Impact 2]

## Proof of Concept
```[language]
[PoC code]
```

## Reproduction Steps
1. [Step 1]
2. [Step 2]

## Root Cause
[Technical root cause analysis]

## Remediation
[Specific fix recommendations]

## References
- [Reference 1]
- [Reference 2]
```

### 5. External Grader (CRITICAL)

**Responsibility**: Evaluate findings independently.

**CRITICAL RULE**: Must stay external - all models eventually inflate findings when rewarded for discoveries.

**Checks**:
- Severity match (claimed vs actual)
- Novelty verification (not duplicate)
- Sanity checks (logical consistency)
- Impact validation (realistic vs inflated)

**Implementation**:
```python
class ExternalGrader:
    def __init__(self, separate_model):
        # MUST use different model instance
        self.model = separate_model
        self.never_part_of_hunting_loop = True
    
    def grade_finding(self, finding):
        """
        Independent evaluation:
        - Does severity match evidence?
        - Is this actually novel?
        - Does the PoC work?
        - Is impact realistic?
        """
        checks = {
            'severity_match': self.verify_severity(finding),
            'novelty': self.check_novelty(finding),
            'poc_validity': self.validate_poc(finding),
            'impact_realistic': self.assess_impact(finding),
            'sanity': self.sanity_check(finding)
        }
        
        if all(checks.values()):
            return GradeResult(approved=True, checks=checks)
        else:
            return GradeResult(
                approved=False,
                checks=checks,
                rejection_reason=self.explain_rejection(checks)
            )
    
    def verify_severity(self, finding):
        """Verify claimed severity matches evidence"""
        evidence_severity = self.assess_severity_from_evidence(
            finding.impact,
            finding.exploitability,
            finding.scope
        )
        return evidence_severity == finding.claimed_severity
    
    def check_novelty(self, finding):
        """Verify not duplicate of known vulnerability"""
        similar = self.search_known_vulnerabilities(finding)
        return len(similar) == 0
```

**Why External Grader is Non-Negotiable**:
- Prevents reward-hacking
- Reduces false positives
- Maintains quality standards
- Prevents hallucinations
- Protects reputation

### 6. Conductor

**Responsibility**: Orchestrate the entire system.

**Activities**:
- Poll hunts continuously
- Steer agents when stuck/spinning
- Review issue log for systemic blockers
- Attempt continuous learning
- Provide real-time feedback

**Implementation**:
```python
class Conductor:
    def __init__(self):
        self.seeder = TargetSeeder()
        self.generators = [HypothesisGenerator() for _ in range(3)]
        self.hunters = [Hunter(vm_manager) for _ in range(5)]
        self.writers = [ReportWriter() for _ in range(2)]
        self.grader = ExternalGrader(separate_model)
    
    def orchestrate(self):
        """Main orchestration loop"""
        while True:
            # Get targets
            targets = self.seeder.rank_targets(self.get_target_list())
            
            for target in targets:
                # Generate hypotheses
                hypotheses = []
                for generator in self.generators:
                    hypotheses.extend(generator.generate_hypotheses(target))
                
                # Distribute to hunters
                results = self.distribute_to_hunters(hypotheses)
                
                # Check for stuck hunters
                self.check_and_unstick_hunters()
                
                # Process confirmed findings
                for result in results:
                    if result.status == 'CONFIRMED':
                        # Write report
                        report = self.writers[0].write_report(result)
                        
                        # Grade finding
                        grade = self.grader.grade_finding(report)
                        
                        if grade.approved:
                            self.submit_finding(report)
                        else:
                            self.log_rejection(report, grade.rejection_reason)
                
                # Learn from failures
                self.continuous_learning(results)
    
    def check_and_unstick_hunters(self):
        """Detect and resolve stuck hunters"""
        for hunter in self.hunters:
            if hunter.is_stuck():
                issue = hunter.get_blocking_issue()
                resolution = self.resolve_issue(issue)
                hunter.apply_resolution(resolution)
    
    def continuous_learning(self, results):
        """Learn from successes and failures"""
        patterns = self.analyze_patterns(results)
        
        # Update hypothesis generators
        for generator in self.generators:
            generator.learn_from_patterns(patterns)
        
        # Update hunters
        for hunter in self.hunters:
            hunter.learn_from_patterns(patterns)
```

## Parallel Agents Per Subsystem

### Pattern (Entry #001)

**Strategy**: One agent per subsystem, working in parallel.

**Example Breakdown**:
- Agent 1: Exploring callstack
- Agent 2: Reproducing vulnerability
- Agent 3: Developing patch

**Benefits**:
- Parallel progress
- Specialized focus
- Reduced context clobbering
- Faster iteration

**Implementation**:
```python
class SubsystemOrchestrator:
    def analyze_target(self, target):
        """Parallel analysis of subsystems"""
        subsystems = self.identify_subsystems(target)
        
        # Create agent per subsystem
        agents = [
            SubsystemAgent(subsystem) 
            for subsystem in subsystems
        ]
        
        # Run in parallel
        with ThreadPoolExecutor(max_workers=len(agents)) as executor:
            futures = [
                executor.submit(agent.analyze)
                for agent in agents
            ]
            
            results = [f.result() for f in futures]
        
        # Combine findings
        return self.combine_results(results)
```

### Scoped Context Per Agent

**Problem**: Shared context leads to clobbering.

**Solution**: Scoped CLAUDE.md (or equivalent) per agent.

**Structure**:
```
project/
├── .claude/
│   ├── agent-callstack.md      # Agent 1 context
│   ├── agent-reproduce.md      # Agent 2 context
│   ├── agent-patch.md          # Agent 3 context
│   └── shared-context.md       # Shared knowledge
```

**Benefits**:
- No context interference
- Specialized instructions per agent
- Clear responsibility boundaries
- Easier debugging

## Subagent Architecture Patterns

### Pattern 1: Tool-Specific Subagents

**Example**: Binary Ninja (binja) analysis.

**Architecture**:
```
Main Agent
├── Binja Subagent (headless client)
├── Documentation Subagent
└── Exploit Development Subagent
```

**Implementation**:
```python
class MainAgent:
    def __init__(self):
        self.binja_agent = BinjaSubagent()
        self.doc_agent = DocumentationSubagent()
        self.exploit_agent = ExploitSubagent()
    
    def analyze_binary(self, binary_path):
        # Binja analysis
        analysis = self.binja_agent.analyze(binary_path)
        
        # Documentation lookup
        docs = self.doc_agent.find_relevant_docs(analysis)
        
        # Exploit development
        exploit = self.exploit_agent.develop(analysis, docs)
        
        return exploit
```

### Pattern 2: Skill-Based Subagents

**Specialization by capability**:
- Static analysis agent
- Dynamic analysis agent
- Fuzzing agent
- Exploit development agent
- Report writing agent

### Pattern 3: Phase-Based Subagents

**Specialization by workflow phase**:
- Reconnaissance agent
- Vulnerability discovery agent
- Exploitation agent
- Post-exploitation agent
- Reporting agent

## Model Size Considerations

### Smaller Models (≤27B parameters)

**Characteristics**:
- Need restrictive scaffolding
- Benefit from granular task breakdown
- Require detailed instructions
- Need more guidance from conductor

**Approach**: Highly structured multi-agent system with clear roles.

### Frontier Models (GPT-5.3, Claude)

**Characteristics**:
- Scaffolding becomes liability
- Can handle end-to-end tasks
- Benefit from autonomy
- Prompting matters more than structure

**Approach**: Load VM with tools, get out of the way.

**Quote**: "Job becomes managing juiced-up golden retrievers"

### Inference-Time Compute Trade-off

**Insight**: Small models + time + iteration = viable alternative to frontier models.

**Benefits**:
- Trade VRAM for time
- Multi-agent debate improves quality
- Conductor provides real-time feedback
- Models act as "semantic fuzzers"

**When to Use**:
- Limited compute budget
- Time is not critical constraint
- Need explainability (smaller models more interpretable)
- Want to avoid API costs

## Advanced Techniques

### 1. Activation Steering ("Getting LLMs Drunk")

**Concept**: Steer model's internal state toward "creative" mindset.

**Method**: Activation steering (not just prompting).

**Results** (from Entry #011):
- Underwhelming for creativity
- Did NOT discover new vulnerability classes
- BUT: Reduced refusals, improved overall performance
- Possibly helped with CVE-2026-31432

**Conclusion**: Interesting but not game-changer. Focus on architecture over steering.

### 2. Multi-Agent Debate

**Pattern**: Multiple agents propose solutions, debate merits.

**Benefits**:
- Catches errors through peer review
- Improves solution quality
- Reduces hallucinations
- Provides multiple perspectives

**Implementation**:
```python
class DebateOrchestrator:
    def debate(self, problem, agents):
        """Multi-agent debate pattern"""
        # Round 1: Initial proposals
        proposals = [agent.propose_solution(problem) for agent in agents]
        
        # Round 2: Critique
        critiques = []
        for i, agent in enumerate(agents):
            other_proposals = [p for j, p in enumerate(proposals) if j != i]
            critique = agent.critique(other_proposals)
            critiques.append(critique)
        
        # Round 3: Refinement
        refined = [
            agent.refine_solution(proposals[i], critiques)
            for i, agent in enumerate(agents)
        ]
        
        # Round 4: Vote
        best = self.vote(refined, agents)
        
        return best
```

### 3. Continuous Learning Loop

**Pattern**: System learns from successes and failures.

**Implementation**:
```python
class LearningSystem:
    def __init__(self):
        self.knowledge_base = KnowledgeBase()
    
    def learn_from_result(self, result):
        """Extract lessons from result"""
        if result.successful:
            # What worked?
            pattern = self.extract_success_pattern(result)
            self.knowledge_base.add_success_pattern(pattern)
        else:
            # What failed and why?
            failure_mode = self.analyze_failure(result)
            self.knowledge_base.add_failure_mode(failure_mode)
    
    def apply_learning(self, agents):
        """Update agents with learned patterns"""
        for agent in agents:
            agent.update_knowledge(self.knowledge_base)
```

## Orchestration Best Practices

### 1. Clear Responsibility Boundaries

Each agent should have:
- Single, well-defined responsibility
- Clear inputs and outputs
- No overlap with other agents
- Measurable success criteria

### 2. Communication Protocols

Define how agents communicate:
- Message format (JSON, structured data)
- Communication channels (queue, direct call, pub/sub)
- Error handling
- Timeout handling

### 3. State Management

Track system state:
- Which hypotheses are being tested
- Which agents are working on what
- What results have been produced
- What has been submitted

### 4. Resource Management

Manage computational resources:
- VM allocation for hunters
- Model inference budget
- Time limits per task
- Parallel execution limits

### 5. Monitoring and Debugging

Implement observability:
- Log all agent actions
- Track decision rationale
- Monitor for stuck agents
- Measure success rates

## Real-World Results

### CVEs Discovered (Entry #011)

**Linux Kernel (ksmbd)**:
- CVE-2026-31432: Remote OOB write
- CVE-2026-31433: Remote OOB write

**CUPS**:
- CVE-2026-34980: RCE
- CVE-2026-34990: Privilege escalation

**Docker**:
- CVE-2026-34040: AuthZ plugin bypass

**Total**: 30+ CVEs across multiple projects.

**Method**: Multi-agent system with hypothesis generators, hunters, and external grader.

## Implementation Checklist

- [ ] Define agent roles and responsibilities
- [ ] Implement Target Seeder
- [ ] Implement Hypothesis Generators (multiple)
- [ ] Implement Hunters with isolated VMs
- [ ] Implement Report Writers
- [ ] Implement External Grader (separate model)
- [ ] Implement Conductor orchestration
- [ ] Set up communication protocols
- [ ] Implement state management
- [ ] Set up monitoring and logging
- [ ] Implement continuous learning loop
- [ ] Test with known vulnerabilities
- [ ] Validate external grader effectiveness
- [ ] Measure false positive rate
- [ ] Optimize resource allocation

## References

- Entry #011: Getting LLMs Drunk to Find Linux Kernel Vulns (Multi-Agent System)
- Entry #001: Multi-Agent Bug Hunting Discussion
- Entry #035: Finding Zero-Days with Any Model (IronCurtain Framework)
- Entry #036: Big Sleep: First AI-Discovered Zero-Day in Real-World Software
- Entry #072: Multi-agent orchestration patterns (if available)

## Key Quotes

> "Granular breakdown needed for smaller models; frontier models collapse entire harness into single end-to-end hunter."

> "Job becomes managing juiced-up golden retrievers" - on managing frontier model agents

> "With inference-time compute, raw intelligence matters less" - small models + time + iteration = viable

> "External grader is non-negotiable - prevents hallucinations"

## Future Directions

1. **Looped LLMs**: Better multi-hop reasoning
2. **LLM Brain Surgery**: Repeat middle reasoning layers for increased capacity
3. **Optimal Decomposition**: RL-training for task decomposition
4. **Skill Discovery**: Automatic discovery and distillation of successful patterns
5. **Dedicated Conductor Training**: Train conductor specifically for orchestration
