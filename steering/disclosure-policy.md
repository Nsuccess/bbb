---
inclusion: auto
description: Modern vulnerability disclosure approach adapted for the LLM era - immediate action, P0 treatment, and realistic timelines
keywords: disclosure, responsible, timeline, reporting, coordination, cvd
---

# Modern Disclosure Policy for the LLM Era

## The Fundamental Shift

### The 90-Day Disclosure Window is Dead

**Historical Context** (Pre-2026):
- 90-day window built for world where bug finders were rare
- Assumed exploit development was slow
- Gave vendors comfortable head start
- Assumed attackers needed days/weeks to reverse engineer exploits

**Current Reality** (2026):
- LLMs compressed both timelines to near-zero
- Bug finders are abundant (11 researchers found same bug in 6 weeks)
- Exploit development is fast (30 minutes from patch to working exploit)
- Attackers already using LLMs in exploit pipelines

**Conclusion**: 90-day window now actively harmful - gives attackers head start.

## The New Assumptions

### What Changed

**OLD (2019) - ALL NOW WRONG**:
1. ❌ You're probably the only person who found this bug
2. ❌ Even if someone else finds it, they'll take their own time
3. ❌ Vendor has comfortable head start on patch
4. ❌ After patch, attackers need days/weeks to reverse engineer exploit

**NEW (2026) - REALITY**:
1. ✅ If you found it, assume 10 others have it
2. ✅ At least one is not friendly
3. ✅ Vendor has NO head start - race is already on
4. ✅ After patch, assume exploit exists immediately

## Real-World Evidence

### Case Study 1: The Duplicate Wave

**Scenario**: Critical bug in e-commerce platform (April 2026)

**Timeline**:
- March 2026: First report
- Late April 2026: Author reports (reporter #11)
- 6 weeks total: 11 independent discoveries
- Still not patched at time of writing

**Bug**: No signature verification on server response
**Impact**: Buy $5000 item for $0

**Key Insight**: "Once a new vulnerability is discovered - especially via some LLM prompt/skills/automation, we start getting a wave of duplicate reports within days." - @d0rsky (triage side)

**Questions**:
- 11 reported = how many found but didn't report?
- Only 1 gets CVE credit, only 1 gets bounty
- Other 10 frustrated - how many sell instead?
- People who never reported = not on any clock
- 90-day window gives everyone who has the bug a 90-day head start

### Case Study 2: 30 Minutes from Patch to Exploit

**Target**: React (CVE-2026-23870, CVE-2026-44575, CVE-2026-44579, CVE-2026-44574, CVE-2026-44578)

**Timeline**:
- React patches CVEs
- Public blog post explaining fixes (standard practice)
- Researcher experiment: patch → working exploit
- **Time: 30 minutes** (DoS, could go further with more work)

**Method**: AI did heavy lifting:
- Understanding diff
- Identifying vulnerable code path
- Writing PoC

**Old World**: Days to weeks for skilled reverse engineers
**New World**: Minutes for simple bugs, hours for complex

**Conclusion**: The moment a patch ships, assume exploit exists.

### Case Study 3: The Week Linux Caught Fire

#### Act 1: Copy Fail (CVE-2026-31431)

**Disclosed**: April 29, 2026
**Discoverer**: Xint Code (Theori team, 9x DEF CON CTF champions)

**Details**:
- Straight-line logic flaw in kernel crypto subsystem
- 100% reliability, no race condition needed
- 732-byte Python script → root on every Linux distro since 2017
- Affected: Ubuntu, RHEL, Amazon Linux, SUSE, ALL

**Discovery Method**: AI automated scanning, ~1 hour
**Exposure**: 9 years undetected

**Post-Disclosure**: Weaponized by Iranian adversaries within days (DDoS infrastructure)

#### Act 2: Dirty Frag (CVE-2026-43284, CVE-2026-43500)

**Disclosed**: May 7, 2026
**Researcher**: Hyunwoo Kim (@v4bel)

**Details**:
- Two chained vulns in IPSec ESP and RxRPC
- Same bug class as Copy Fail and Dirty Pipe
- Works even if Copy Fail mitigation applied
- Unprivileged → root

**Disclosure Timeline**:
- April 29-30: Reported to security@kernel.org
- May 7: Coordinated with linux-distros list, 5-day embargo agreed
- **Same day (hours later): Third party published detailed exploit, breaking embargo**
- Hyunwoo published full writeup + exploit + PoC
- **Zero distributions had patch available at disclosure**
- CVE-2026-43500 still no upstream patch at time of writing

**Post-Disclosure**: Microsoft Defender detected limited in-the-wild exploitation within 24 hours

**Attack Chain**:
1. SSH access
2. ELF binary execution
3. Root via su
4. Modify auth configs
5. Wipe sessions
6. Lateral movement

**Quote**: "responsible disclosure is dead🤦" - CTS (@gf_256)

## What is Actually Dead

### 1. The 90-Day Disclosure Window

**Why it Failed**:
- Designed for rare finders, slow exploit dev
- LLMs made finders abundant, exploit dev fast
- Protecting nobody - just exposure with polite name

**Replacement**: Immediate disclosure with shortest possible window.

### 2. Monthly Patch Cycles

**Why it Failed**:
- Assumes attackers slower than release train
- They're not - they're faster
- Microsoft saw Dirty Frag in wild within 24 hours
- Monthly window = attack window

**Replacement**: Continuous patching, P0 treatment for critical issues.

### 3. "Wait for the Advisory"

**Why it Failed**:
- If reading CVE descriptions while attackers read `git log --diff-filter=M`, you're behind
- Advisory is downstream artifact
- Patch diff is the signal

**Replacement**: Monitor patch diffs directly, automate analysis.

## The New Disclosure Model

### Core Principle: Treat Every Critical Issue as P0

**What "Immediately" Means**:

**For Researchers**:
- Clock starts moment you confirm vulnerability (not after perfect PoC)
- If you found it, assume 10 others have it
- At least one is not friendly
- Push for shortest possible disclosure window
- Stop sitting on critical bugs

**For Vendors**:
- Clock starts moment report lands (not after triage)
- If someone reported it, assume 10 others have it
- At least one is not friendly
- Patch immediately, not "next sprint"

**For Vulnerability Management**:
- Must be real-time
- Old cadence: "scan weekly, triage in sprint, patch in cycle" = obsolete
- New maximum response time: **hours** (not days)
- Even that might be too slow

### Disclosure Timeline Recommendations

**Critical Severity** (RCE, Auth Bypass, Data Breach):
- Vendor notification: Immediate
- Vendor acknowledgment: 24 hours
- Initial patch: 48-72 hours
- Public disclosure: 7 days maximum
- If vendor can't fix in 7 days = vendor problem, not disclosure problem

**High Severity** (Privilege Escalation, IDOR, XSS):
- Vendor notification: Immediate
- Vendor acknowledgment: 48 hours
- Initial patch: 1 week
- Public disclosure: 14 days maximum

**Medium Severity**:
- Vendor notification: Immediate
- Vendor acknowledgment: 1 week
- Initial patch: 2 weeks
- Public disclosure: 30 days maximum

**Low Severity**:
- Traditional 90-day window acceptable
- But still push for faster resolution

### When to Disclose Immediately (0-day)

**Criteria for Immediate Public Disclosure**:
1. Vendor unresponsive after 7 days
2. Vendor refuses to fix
3. Vendor disputes severity without justification
4. Evidence of active exploitation
5. Patch is available but not deployed
6. Third party breaks embargo (as in Dirty Frag case)

**Process**:
1. Notify vendor of intent to disclose
2. Provide 24-hour warning
3. Publish full details with PoC
4. Notify affected parties directly if possible

## Coordinated Disclosure Best Practices

### Initial Report

**Include**:
- Clear vulnerability description
- Severity assessment (with justification)
- Affected versions
- Proof of Concept (working, minimal)
- Reproduction steps
- Impact analysis
- Suggested remediation
- Proposed disclosure timeline

**Template**:
```markdown
# Vulnerability Report

## Summary
[One-line description]

## Severity
CRITICAL - [Justification based on CVSS or similar]

## Affected Versions
[Specific version range]

## Description
[Technical details]

## Proof of Concept
[Working PoC code]

## Reproduction Steps
1. [Step 1]
2. [Step 2]

## Impact
- [Impact 1]
- [Impact 2]

## Suggested Remediation
[Specific fix recommendations]

## Proposed Timeline
- Acknowledgment: 24 hours
- Patch: 72 hours
- Public disclosure: 7 days

## Contact
[Your contact information]
```

### Communication Protocol

**Response Time Expectations**:
- Critical: Vendor response within 24 hours
- High: Vendor response within 48 hours
- Medium: Vendor response within 1 week

**If No Response**:
- Day 1: Initial report
- Day 2: Follow-up email
- Day 3: Try alternative contact (security@, abuse@, social media)
- Day 7: Notify of intent to disclose
- Day 8: Public disclosure

### Embargo Handling

**When to Use Embargoes**:
- Multiple vendors affected
- Coordinating with linux-distros or similar lists
- Critical infrastructure impact
- Need time for coordinated patch deployment

**Embargo Duration**:
- Maximum: 7 days for critical issues
- Maximum: 14 days for high severity
- Longer embargoes only if justified and agreed by all parties

**Embargo Breach Protocol**:
- If third party breaks embargo, immediately publish full details
- Don't leave affected parties in the dark
- Notify all coordinating parties
- Publish with attribution to original researcher

## Bug Bounty Program Considerations

### Disclosure Timelines in Programs

**Program Policies**:
- Check program's disclosure policy before reporting
- Some programs require 90-day window (outdated)
- Some allow researcher-controlled disclosure
- Some require permission before disclosure

**Negotiation**:
- Push for shorter timelines
- Cite real-world evidence (Copy Fail, Dirty Frag)
- Emphasize risk of duplicate discoveries
- Offer to coordinate with affected parties

**If Program Refuses Reasonable Timeline**:
- Document communication
- Consider disclosing anyway after reasonable period
- Prioritize public safety over bounty payment
- Be prepared to defend decision

### Duplicate Handling

**Reality**: You will encounter duplicates.

**When You're First**:
- Report immediately
- Don't sit on findings
- Speed matters for credit

**When You're Not First**:
- Still report (program may not have received first report)
- Document your independent discovery
- Share your unique insights
- Don't be discouraged

**When You're #11**:
- Recognize the pattern
- This is evidence of LLM-enabled discovery
- Focus on novel techniques, not just running automated scans
- Consider more complex vulnerability classes

## Responsible Disclosure in the LLM Era

### What "Responsible" Means Now

**OLD Definition**:
- Give vendor 90 days
- Don't publish exploit code
- Coordinate with vendor on timing

**NEW Definition**:
- Give vendor realistic time based on severity (hours to days for critical)
- Publish full details including exploit (attackers already have it)
- Coordinate, but don't wait indefinitely
- Prioritize public safety over vendor convenience

### The Courtesy Shift

**OLD Courtesy**:
- "Give them time" - made sense when you were only finder
- Vendor convenience prioritized
- Researcher waits patiently

**NEW Courtesy**:
- You're not the only finder anymore
- Vendor urgency required
- Public safety prioritized
- Researcher pushes for action

### Ethical Considerations

**Questions to Ask**:
1. Is delaying disclosure protecting users or exposing them?
2. How many others likely have this vulnerability?
3. Is vendor taking issue seriously?
4. Is there evidence of exploitation?
5. What's the realistic risk of 0-day exploitation?

**Guiding Principle**: When in doubt, err on the side of public disclosure.

## Automation Implications

### For Our System

**Disclosure Automation**:
- Auto-generate disclosure reports
- Track vendor response times
- Escalate if no response
- Auto-publish after deadline

**Timeline Tracking**:
```python
class DisclosureTracker:
    def __init__(self, finding):
        self.finding = finding
        self.timeline = self.calculate_timeline(finding.severity)
        self.vendor_notified = None
        self.vendor_acknowledged = None
        self.patch_available = None
        self.disclosed = None
    
    def calculate_timeline(self, severity):
        if severity == 'CRITICAL':
            return {
                'acknowledgment_deadline': timedelta(hours=24),
                'patch_deadline': timedelta(hours=72),
                'disclosure_deadline': timedelta(days=7)
            }
        elif severity == 'HIGH':
            return {
                'acknowledgment_deadline': timedelta(hours=48),
                'patch_deadline': timedelta(days=7),
                'disclosure_deadline': timedelta(days=14)
            }
        # ... other severities
    
    def check_deadlines(self):
        now = datetime.now()
        
        if self.vendor_notified:
            # Check acknowledgment deadline
            if not self.vendor_acknowledged:
                deadline = self.vendor_notified + self.timeline['acknowledgment_deadline']
                if now > deadline:
                    self.escalate('no_acknowledgment')
            
            # Check disclosure deadline
            disclosure_deadline = self.vendor_notified + self.timeline['disclosure_deadline']
            if now > disclosure_deadline and not self.disclosed:
                self.auto_disclose()
    
    def auto_disclose(self):
        """Automatically publish disclosure after deadline"""
        self.publish_disclosure(self.finding)
        self.disclosed = datetime.now()
        self.notify_vendor_of_disclosure()
```

### Monitoring for Active Exploitation

**Automated Checks**:
- Monitor for patch commits in target repos
- Monitor for exploit code in public repos
- Monitor security mailing lists
- Monitor social media for mentions
- Alert if exploitation detected

**Implementation**:
```python
class ExploitationMonitor:
    def monitor_finding(self, finding):
        """Monitor for signs of exploitation"""
        checks = {
            'public_exploits': self.check_exploit_db(finding),
            'github_exploits': self.check_github(finding),
            'twitter_mentions': self.check_twitter(finding),
            'vendor_patches': self.check_vendor_repos(finding),
            'security_lists': self.check_mailing_lists(finding)
        }
        
        if any(checks.values()):
            self.alert_immediate_disclosure(finding, checks)
```

## Communication Templates

### Initial Disclosure Email

```
Subject: [CRITICAL] Security Vulnerability in [Product] - [CVE-ID if assigned]

Dear [Vendor] Security Team,

I have discovered a critical security vulnerability in [Product] version [X.Y.Z].

SEVERITY: CRITICAL
IMPACT: [Brief impact description]
AFFECTED VERSIONS: [Version range]

SUMMARY:
[One-paragraph description]

PROOF OF CONCEPT:
[Minimal PoC demonstrating the issue]

PROPOSED TIMELINE:
- Acknowledgment: 24 hours
- Patch: 72 hours  
- Public disclosure: 7 days

I am available to provide additional details and assist with remediation.

Please acknowledge receipt within 24 hours.

Best regards,
[Your name]
[Contact information]

---
FULL TECHNICAL DETAILS:
[Detailed writeup]
```

### Follow-up Email (No Response)

```
Subject: Re: [CRITICAL] Security Vulnerability in [Product] - FOLLOW-UP

Dear [Vendor] Security Team,

I have not received acknowledgment of my vulnerability report sent [X] days ago.

Given the critical severity and the risk of independent discovery by others, I will proceed with public disclosure in [Y] days if I do not receive a response.

Please respond urgently.

Best regards,
[Your name]
```

### Disclosure Notification Email

```
Subject: Re: [CRITICAL] Security Vulnerability in [Product] - DISCLOSURE NOTICE

Dear [Vendor] Security Team,

As [X] days have passed since my initial report without [acknowledgment/patch/resolution], I will be publishing full details of the vulnerability on [DATE].

This decision is made in the interest of public safety, as:
1. [Reason 1]
2. [Reason 2]

I remain available to coordinate on remediation efforts.

Best regards,
[Your name]
```

## Key Principles

1. **Speed Matters**: If you found it, others have it too
2. **Realistic Timelines**: Hours to days for critical, not months
3. **Public Safety First**: When in doubt, disclose
4. **Document Everything**: Communication, timelines, decisions
5. **Be Prepared to Defend**: Your disclosure decisions
6. **Automate Tracking**: Don't rely on manual follow-up
7. **Monitor for Exploitation**: Adjust timeline if exploitation detected
8. **Full Disclosure**: Include PoC - attackers already have it

## References

- Entry #017: The 90 Day Disclosure Policy is Dead (LLM Impact Analysis)
- Entry #005: AI Agent Self-Validation Methodology (quality over speed)
- Entry #022: Bug Bounty Methodology 2026

## Key Quotes

> "Once a new vulnerability is discovered - especially via some LLM prompt/skills/automation, we start getting a wave of duplicate reports within days." - @d0rsky

> "The moment a patch ships, assume exploit exists" - Himanshu Anand

> "If someone reported it, assume 10 others have it. At least one is not friendly."

> "responsible disclosure is dead🤦" - CTS (@gf_256)

> "If vendor can't fix in a week = vendor problem, not disclosure problem"

## Conclusion

The 90-day disclosure window was built for a world that no longer exists. LLMs have fundamentally changed the vulnerability landscape:

- Bug finders are abundant
- Exploit development is fast
- Attackers are already using AI
- Duplicates are inevitable
- Time is the enemy

Our disclosure policy must reflect this reality: immediate action, realistic timelines, and public safety first.
