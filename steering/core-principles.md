---
inclusion: auto
description: Core principles for AI-driven bug bounty hunting - self-validation, P0 treatment, and quality over quantity
keywords: validation, false-positive, quality, principles, methodology
---

# Core Principles for Bug Bounty Automation

## Philosophy: Challenge Your Findings

**CRITICAL RULE**: AI agents should CHALLENGE findings, not just find them.

### The Self-Validation Mandate

Most AI security agents are optimized to FIND bugs → high false positive rate. Build agents that validate and reject weak findings.

**Required Workflow**:
1. Initial lead identified
2. Agent self-validates:
   - Trace real implementation flow
   - Test actual protections
   - Verify cross-origin/cross-context failures
   - Confirm exploitability in realistic scenario
3. Result: Accept OR reject with documented reasoning

**Key Metrics for Success**:
- 0 false positive submissions
- 0 hallucinations
- 0 fake reports
- Every submission must survive self-challenge

### Validation Steps (Mandatory)

Before reporting ANY finding:

1. **Trace the Real Flow**
   - Don't assume based on endpoint names
   - Follow actual code execution
   - Verify data flow end-to-end

2. **Test Protections**
   - Check for Origin enforcement
   - Check for Referer enforcement  
   - Test CSRF tokens
   - Verify authentication requirements
   - Test authorization boundaries

3. **Prove Exploitability**
   - Build working PoC
   - Test in realistic scenario
   - Verify impact is real, not theoretical
   - Document exact reproduction steps

4. **Challenge Your Assumptions**
   - What could make this a false positive?
   - What protections might I have missed?
   - Is there a legitimate reason for this behavior?
   - Can I prove the security control is absent, not just bypassed?

### Devil's Advocate Pattern

Implement a "Devil's Advocate" sub-agent that:
- Tries to disprove findings
- Looks for mitigating controls
- Tests edge cases that would invalidate the vulnerability
- Forces documentation of why protections DON'T work

**Only report if the Devil's Advocate fails to disprove the finding.**

## P0 Treatment: The New Reality

### The 90-Day Disclosure Window is Dead

**Why Traditional Timelines Failed**:
- Built for world where bug finders were rare ❌
- Assumed exploit development was slow ❌  
- Gave vendors comfortable head start ❌
- Assumed attackers needed days/weeks to reverse engineer ❌

**The New Reality** (2026):
- LLMs compressed both timelines to near-zero
- 11 researchers found same bug in 6 weeks (real case)
- 30 minutes from patch to working exploit (React CVEs)
- 1 hour AI scan → 9-year-old kernel bug (Copy Fail)
- 24 hours disclosure → in-the-wild exploitation (Dirty Frag)

### Treat Every Critical Issue as P0

**What "Immediately" Means**:

**For Our Agents**:
- If you found it, assume 10 others have it
- At least one is not friendly
- Push for shortest possible disclosure window
- Stop sitting on critical bugs

**For Reporting**:
- Document severity accurately
- Provide complete PoC immediately
- Include remediation guidance
- Flag cross-tenant/platform-wide impact

**Response Time Expectations**:
- Critical bugs: Hours (not days)
- High severity: Same day
- Medium: Within week

### The Duplicate Reality

**Accept This Truth**:
- You are probably NOT the only person who found this bug
- LLMs made vulnerability discovery abundant
- Same prompt/skill/automation = wave of duplicates within days
- Only first reporter gets CVE credit and bounty

**Implications**:
- Speed matters
- Quality matters more (avoid rejection delays)
- Self-validation prevents wasted time on duplicates others will also find
- Focus on novel techniques, not just running automated scans

## AI-First Approach

### Automation is Not Optional

**The Arms Race**:
- Attackers already integrated LLMs into exploit pipelines
- If you haven't done same on offense = "bringing clipboard to gunfight"
- Window between "vulnerability exists" and "vulnerability exploited" → zero

### What This Means for Our System

**Required Capabilities**:

1. **Automated Hypothesis Generation**
   - Study documentation, source code, policy invariants
   - Analyze attacker-input flows
   - Identify option combinations
   - Record promising hypotheses

2. **Automated Validation**
   - Test hypotheses in isolated environments
   - Adjust PoCs automatically
   - Rule out false positives
   - Record successes/failures

3. **Continuous Learning**
   - Learn from failed attempts
   - Identify systemic blockers
   - Adapt techniques based on results
   - Share knowledge across agents

4. **Real-Time Analysis**
   - Monitor for new patches
   - Analyze diffs automatically
   - Determine exploitability
   - Generate PoCs from patches

## Quality Over Quantity

### Reputation is Everything

**One False Positive Can**:
- Damage relationship with program
- Delay triage of real findings
- Reduce payout rates
- Get you banned from programs

**Prevention**:
- Mandatory self-validation before submission
- External grader agent (separate model evaluates findings)
- Sanity checks on severity claims
- Novelty verification
- Impact chain documentation

### The External Grader Pattern

**CRITICAL**: All models eventually inflate findings when rewarded for discoveries.

**Solution**: Separate model evaluates findings:
- Checks severity match
- Verifies novelty
- Performs sanity checks
- Must stay external (never part of hunting loop)
- Prevents reward-hacking

## Distinction: Scanning vs Research

**AI-Powered Scanning**:
- Runs known checks
- Finds common vulnerabilities
- High volume, low quality
- Easily duplicated

**Actual Security Research**:
- Understands context
- Chains multiple issues
- Finds novel vulnerability classes
- Documents complete impact
- Survives self-challenge

**Our Goal**: Actual security research, not just scanning.

## Implementation Checklist

- [ ] Every finding goes through self-validation workflow
- [ ] Devil's Advocate agent challenges all findings
- [ ] External grader evaluates before submission
- [ ] PoC proves exploitability, not just presence
- [ ] Impact chain fully documented
- [ ] Severity justified with evidence
- [ ] Novelty verified (not duplicate of known issue)
- [ ] Remediation guidance included
- [ ] Response time appropriate to severity

## References

- Entry #005: AI Agent Self-Validation Methodology (Walid Ladeb)
- Entry #017: The 90 Day Disclosure Policy is Dead (LLM Impact Analysis)
- Entry #022: Bug Bounty Methodology 2026 (Aituglo/Cassim)

## Key Quotes

> "AI agents should CHALLENGE findings, not just find them" - Walid Ladeb

> "The moment a patch ships, assume exploit exists" - Himanshu Anand

> "If someone reported it, assume 10 others have it. At least one is not friendly."
