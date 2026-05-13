# Framework Structure

## Directory Layout

```
bug-bounty-automation/
│
├── README.md                    # Main documentation
├── LICENSE                      # MIT License
├── .gitignore                  # Git ignore rules
├── STRUCTURE.md                # This file
├── STATUS.md                   # System completion status
├── INTEGRATION-GUIDE.md        # How to integrate with AI tools
├── SYSTEM-COMPLETE.md          # Framework completion summary
├── VULNERABILITY-SCAN-GUIDE.md # Vulnerability prioritization
├── ALTERNATIVE-PLATFORMS.md    # Bug bounty platform guide
├── INBOX-METADATA-EXTRACTION.md # Resource extraction process
├── inbox-metadata.json         # Resource statistics
│
├── methodologies/              # Complete testing frameworks
│   ├── 01-multi-agent-orchestration.md
│   ├── 02-oauth-security-testing.md
│   ├── 03-ai-self-validation.md
│   ├── 03-yandex-recon-methodology.md
│   ├── 04-yandex-dorking.md
│   ├── 05-prompt-injection-framework.md
│   └── 06-mcp-security-audit.md
│
├── skills/                     # AI agent personas
│   ├── ai-self-validator.md
│   ├── bucket-squatting-detector.md
│   ├── crypto-defi-auditor.md
│   ├── enterprise-software-auditor.md
│   ├── mcp-security-auditor.md
│   ├── multi-agent-orchestrator.md
│   ├── oauth-security-auditor.md
│   ├── parser-differential-tester.md
│   ├── prompt-injection-hunter.md
│   ├── recon-basic.md
│   ├── router-simple.md
│   └── yandex-recon-specialist.md
│
├── steering/                   # Persistent context files
│   ├── ai-security-testing.md
│   ├── cloud-security-standards.md
│   ├── core-principles.md
│   ├── disclosure-policy.md
│   ├── multi-agent-patterns.md
│   ├── oauth-security-standards.md
│   └── recon-methodology.md
│
├── workflows/                  # Declarative hunting processes
│   ├── 00-router.md           # Workflow selector
│   ├── 01-web-app-hunt.md     # Web application testing
│   ├── 02-api-security-hunt.md # API testing
│   ├── 03-ai-app-hunt.md      # AI/ML application testing
│   ├── 04-crypto-hunt.md      # Blockchain/DeFi testing
│   └── 05-adaptive-hunt.md    # Dynamic workflow
│
└── resources/                  # Curated bug bounty resources
    ├── 00-INBOX.md            # All 72 resources (11,000+ lines)
    └── categorized-resources.md # Organized by category
```

## File Descriptions

### Root Level

- **README.md** - Main documentation, quick start guide
- **LICENSE** - MIT License with attribution notice
- **.gitignore** - Excludes personal hunting data, credentials
- **STATUS.md** - Framework completion status
- **INTEGRATION-GUIDE.md** - Integration with Claude Code, Cursor, Windsurf
- **SYSTEM-COMPLETE.md** - Summary of framework capabilities
- **VULNERABILITY-SCAN-GUIDE.md** - Vulnerability prioritization by success rate
- **ALTERNATIVE-PLATFORMS.md** - Bug bounty platform comparison
- **INBOX-METADATA-EXTRACTION.md** - How resources were extracted
- **inbox-metadata.json** - Statistics on 72 resources

### methodologies/

Complete testing frameworks extracted from real-world findings:

1. **Multi-Agent Orchestration** - Parallel agent hunting (Entry #11, 30+ CVEs)
2. **OAuth Security Testing** - Complete OAuth vulnerability framework (Entry #18)
3. **AI Self-Validation** - Challenge findings before submission (Entry #5, 80% rejection)
4. **Yandex Recon** - Advanced dorking and asset discovery (Entry #4, #13)
5. **Yandex Dorking** - Specific dork patterns and automation
6. **Prompt Injection Framework** - AI application security (Entry #38)
7. **MCP Security Audit** - Model Context Protocol vulnerabilities (Entry #6)

### skills/

Specialized AI agent personas for specific vulnerability classes:

- **ai-self-validator** - Validate findings, reject false positives
- **bucket-squatting-detector** - Cloud storage attacks (Entry #6)
- **crypto-defi-auditor** - Blockchain/DeFi security (Entry #16)
- **enterprise-software-auditor** - Enterprise application testing
- **mcp-security-auditor** - MCP vulnerability detection
- **multi-agent-orchestrator** - Parallel hunting coordination
- **oauth-security-auditor** - OAuth flow analysis (Entry #18)
- **parser-differential-tester** - Parser confusion attacks (Entry #57)
- **prompt-injection-hunter** - AI security testing (Entry #38)
- **recon-basic** - Asset discovery and enumeration
- **router-simple** - Workflow routing and selection
- **yandex-recon-specialist** - Advanced OSINT (Entry #4, #13)

### steering/

Persistent context files with `inclusion: auto` frontmatter:

- **ai-security-testing** - AI/ML security standards
- **cloud-security-standards** - Cloud testing guidelines
- **core-principles** - Fundamental testing principles
- **disclosure-policy** - Responsible disclosure guidelines
- **multi-agent-patterns** - Orchestration patterns
- **oauth-security-standards** - OAuth best practices
- **recon-methodology** - Asset discovery standards

### workflows/

Declarative, step-by-step hunting processes:

1. **Router** - Intelligent workflow selector based on target type
2. **Web App Hunt** - Traditional web application testing
3. **API Security Hunt** - API-focused testing (REST, GraphQL, etc.)
4. **AI App Hunt** - AI/ML application testing (prompt injection, etc.)
5. **Crypto Hunt** - Blockchain/DeFi testing (smart contracts, etc.)
6. **Adaptive Hunt** - Dynamic workflow that adapts to findings

### resources/

Curated from 72 real bug bounty findings:

- **00-INBOX.md** - All 72 resources with complete details (11,000+ lines)
- **categorized-resources.md** - Organized by niche, vulnerability type, priority

**Statistics:**
- 72 total resources
- $180,000+ in documented bounties
- 60+ CVEs referenced
- 30+ tools and techniques
- Real-world writeups from successful hunters

## Usage Patterns

### Pattern 1: Skill-Based Hunting

```markdown
# Load specific skill
@skills/oauth-security-auditor.md

# Apply to target
Target: auth.example.com
Focus: OAuth flow vulnerabilities
```

### Pattern 2: Workflow-Based Hunting

```markdown
# Load router to select workflow
@workflows/00-router.md

# Router recommends workflow based on target
Target: api.example.com
→ Recommends: 02-api-security-hunt.md

# Execute recommended workflow
@workflows/02-api-security-hunt.md
```

### Pattern 3: Methodology-Based Hunting

```markdown
# Apply complete methodology
@methodologies/02-oauth-security-testing.md

# Reference related resources
Entry #18: OAuth popup hijacking
Entry #50: OAuth 2.0 attacks
```

### Pattern 4: Resource-Based Hunting

```markdown
# Reference specific technique
Entry #7: Mass assignment privilege escalation
Entry #25: Export functionality IDOR
Entry #41: $9k BAC IDOR writeup

# Apply to target
Target: booking.example.com
Test: IDOR on booking endpoints
```

## Integration Points

### Claude Code (Kiro)

```
.kiro/
├── skills/          # Copy from /skills/
├── steering/        # Copy from /steering/
└── workflows/       # Reference from /workflows/
```

### Cursor

```
.cursorrules         # Reference skills and workflows
@mentions            # Use in chat
```

### Windsurf

```
cascade files        # Reference methodologies
agent prompts        # Use skills
```

## Excluded from Git

The following are excluded via `.gitignore`:

- `targets/` - Personal hunt plans for specific companies
- `*-HUNT-PLAN.md` - Specific target hunt plans
- `*-RECON-REPORT.md` - Reconnaissance reports
- `*-EXECUTION-GUIDE.md` - Execution guides with personal data
- `BUGCROWD-TOP-TARGETS.md` - Personal program selections
- `LOW-COMPETITION-TARGETS.md` - Personal target lists
- Credentials, API keys, tokens
- Personal notes and scratch files

## Maintenance

### Adding New Resources

1. Add to `resources/00-INBOX.md`
2. Update `inbox-metadata.json`
3. Categorize in `categorized-resources.md`
4. Extract methodology if applicable
5. Create skill if needed
6. Update relevant workflows

### Adding New Methodologies

1. Create in `methodologies/`
2. Reference source resources
3. Include real-world examples
4. Add to relevant workflows
5. Update README.md

### Adding New Skills

1. Create in `skills/`
2. Define clear persona and focus
3. Reference methodologies
4. Add to router logic
5. Update README.md

## Version Control

- **Main branch**: Stable, tested framework
- **Feature branches**: New methodologies, skills, workflows
- **Tags**: Version releases (v1.0, v1.1, etc.)

## Contributing

See README.md for contribution guidelines.

Key principles:
- Real-world tested only
- Document sources
- No theoretical content
- Proven techniques only
