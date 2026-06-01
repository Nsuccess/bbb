# Bug Bounty Automation Framework

A comprehensive, AI-first bug bounty hunting framework built from 202+ real-world resources, 
methodologies, and successful writeups. Designed for use with Claude Code, Cursor, or any AI coding assistant.

## 🎯 What This Is

A **framework-agnostic** bug bounty system that works with any LLM tool. Built on the principle that **operational memory evolves from actual hunting**, not upfront organization.

### Core Philosophy

- ✅ **Declarative workflows** (if/then logic, not "hyper-agentic")
- ✅ **Deterministic validation** (curl commands, nuclei - not AI validating AI)
- ✅ **Manual curation** of what works (you are the intelligence)
- ✅ **Framework-agnostic** (Markdown/YAML, portable across tools)
- ✅ **No bullshit promises** (no "auto-learning", no hallucination risks)

## 📁 Structure

```
bug-bounty-automation/
├── methodologies/       # 7 complete testing methodologies
├── skills/             # 12 specialized AI agent skills
├── steering/           # 7 persistent context files
├── workflows/          # 6 declarative hunting workflows
├──   resources/          # 202 curated bug bounty resources
└── docs/              # Integration guides and documentation
```

## 🚀 Quick Start

### 1. Choose Your Tool

Works with:
- **Claude Code** (Kiro)
- **Cursor**
- **Windsurf**
- **Any AI coding assistant**

### 2. Load Skills

Copy skills from `/skills/` to your AI assistant's context:

```markdown
# Example: IDOR Hunting
Load: @skills/recon-basic.md
Load: @skills/ai-self-validator.md
```

### 3. Use Workflows

Follow declarative workflows from `/workflows/`:

```markdown
# Example: Web App Hunt
Follow: @workflows/01-web-app-hunt.md
Target: example.com
```

### 4. Apply Methodologies

Reference methodologies from `/methodologies/`:

```markdown
# Example: OAuth Testing
Apply: @methodologies/02-oauth-security-testing.md
```

## 📚 Key Components

### Methodologies (9 Files)

Complete testing frameworks extracted from real-world findings:

1. **Multi-Agent Orchestration** - Parallel agent hunting patterns
2. **OAuth Security Testing** - Complete OAuth vulnerability framework
3. **AI Self-Validation** - Challenge findings before submission (80% rejection rate)
4. **Yandex Recon** - Advanced dorking and asset discovery
5. **Prompt Injection Framework** - AI application security testing
6. **MCP Security Audit** - Model Context Protocol vulnerabilities
7. **Logic Bug Hunting** - Business logic & supply chain exploitation
8. **Patch Diffing Pipeline** - N-day exploit generation
9. **Submission Format** - Report structure and optimization

### Skills (14 Files)

Specialized AI agent personas for specific vulnerability classes:

- `oauth-security-auditor.md` - OAuth flow analysis
- `yandex-recon-specialist.md` - Advanced OSINT
- `prompt-injection-hunter.md` - AI security testing
- `mcp-security-auditor.md` - MCP vulnerabilities
- `ai-self-validator.md` - Finding validation
- `multi-agent-orchestrator.md` - Parallel hunting
- `parser-differential-tester.md` - Parser confusion attacks
- `bucket-squatting-detector.md` - Cloud storage attacks
- `enterprise-software-auditor.md` - Enterprise app testing
- `crypto-defi-auditor.md` - Blockchain security
- `recon-basic.md` - Asset discovery
- `router-simple.md` - Workflow routing
- `framework-librarian.md` - Resource & methodology librarian
- `cosmos-evm-precompile-auditor.md` - Cosmos/EVM precompile audit

### Steering (7 Files)

Persistent context files with `inclusion: auto` frontmatter:

- `core-principles.md` - Fundamental testing principles
- `oauth-security-standards.md` - OAuth best practices
- `recon-methodology.md` - Asset discovery standards
- `multi-agent-patterns.md` - Orchestration patterns
- `disclosure-policy.md` - Responsible disclosure
- `cloud-security-standards.md` - Cloud testing guidelines
- `ai-security-testing.md` - AI/ML security standards

### Workflows (8 Files)

Declarative, step-by-step hunting processes:

1. **Router** (`00-router.md`) - Intelligent workflow selector
2. **Web App Hunt** (`01-web-app-hunt.md`) - Traditional web testing
3. **API Security Hunt** (`02-api-security-hunt.md`) - API-focused testing
4. **AI App Hunt** (`03-ai-app-hunt.md`) - AI/ML application testing
5. **Crypto Hunt** (`04-crypto-hunt.md`) - Blockchain/DeFi testing
6. **Adaptive Hunt** (`05-adaptive-hunt.md`) - Dynamic workflow
7. **Claude Code Security Review** (`05-claude-code-security-review.md`) - AI agent code security
8. **Xalgorix 22-Phase** (`06-xalgorix-22-phase.md`) - AI pentesting methodology

### Resources (202 Entries)

Curated from real bug bounty findings:

- **$3,401,106+** in documented bounties (Verus Bridge $11.5M loss + Exolix $40M exposure disclosed separately)
- **63 CVEs** referenced
- **30+ tools** and techniques
- **Real-world writeups** from successful hunters

Topics covered:
- IDOR, Mass Assignment, Business Logic
- OAuth, JWT, Authentication
- NoSQL Injection, SQL Injection
- XSS, CSRF, SSRF
- Prompt Injection, AI Security
- Cloud Security, Container Escape
- Cryptographic Vulnerabilities
- And more...

## 🎓 How to Use

### Example 1: IDOR Hunting

```markdown
# Load skills
@skills/recon-basic.md
@skills/ai-self-validator.md

# Follow workflow
@workflows/01-web-app-hunt.md

# Apply methodology
Target: booking.example.com
Focus: IDOR on booking endpoints

# Reference resources
Entry #7: Mass assignment technique
Entry #25: Export functionality IDOR
Entry #41: $9k BAC IDOR writeup
```

### Example 2: OAuth Testing

```markdown
# Load skill
@skills/oauth-security-auditor.md

# Apply methodology
@methodologies/02-oauth-security-testing.md

# Reference resources
Entry #18: OAuth popup hijacking
Entry #50: OAuth 2.0 attacks
```

### Example 3: AI Security Testing

```markdown
# Load skill
@skills/prompt-injection-hunter.md

# Apply methodology
@methodologies/05-prompt-injection-framework.md

# Follow workflow
@workflows/03-ai-app-hunt.md

# Reference resources
Entry #38: Prompt injection framework
Entry #5: AI self-validation
```

## 🔧 Integration

### Claude Code (Kiro)

1. Copy skills to `.kiro/skills/`
2. Copy steering to `.kiro/steering/`
3. Reference in prompts: `@skill-name.md`

### Cursor

1. Add to workspace
2. Reference in `.cursorrules`
3. Use `@` mentions in chat

### Windsurf

1. Add to project context
2. Reference in cascade files
3. Use in agent prompts

## 📊 Success Metrics

Based on Entry #22 (Cassim's Methodology):

**Expected Results (First Month):**
- ✅ Recon: 50+ endpoints mapped
- ✅ Hunting: 10-15 leads found
- ✅ Validation: 2-3 confirmed (80% rejection is GOOD!)
- ✅ Submissions: 1-2 valid reports
- 💰 Payout: $3,000-$5,000 (1x P2 + 1x P3)

**Key Principle:** Challenge every finding. 80% rejection rate during self-validation is expected and healthy.

## 🛠️ Tools Referenced

Essential tools mentioned across resources:

- **Burp Suite** - Manual testing and exploitation
- **ffuf** - Fast web fuzzing
- **nuclei** - Template-based scanning
- **jq** - JSON parsing
- **subfinder** - Subdomain enumeration
- **httpx** - HTTP toolkit
- **ripgrep-all** - Advanced file search
- **Yandex** - Alternative search engine for dorking

## 📖 Key Resources

### Top Methodologies

- **Entry #22**: Complete bug bounty methodology 2026 (Cassim/Aituglo)
- **Entry #11**: Multi-agent LLM vulnerability hunting (30+ CVEs)
- **Entry #5**: AI self-validation (80% rejection rate)
- **Entry #17**: 90-day disclosure is dead (LLM impact analysis)

### Top Techniques

- **Entry #7**: Mass assignment privilege escalation
- **Entry #25**: Export functionality IDOR goldmine
- **Entry #41**: $9k BAC IDOR writeup
- **Entry #50**: Business logic flaws (HackLabs)

### Top Tools

- **Entry #3**: AI/MCP/Agentic wordlist
- **Entry #4**: Yandex dork recon loop
- **Entry #19**: ripgrep-all (rga) advanced search
- **Entry #34**: Top 3 bug bounty tools (community consensus)

## 🎯 Workflow Example

### Complete Hunt Process

```markdown
# 1. Select Target
Target: api.example.com
Type: REST API

# 2. Load Router
@workflows/00-router.md
→ Recommends: 02-api-security-hunt.md

# 3. Load Skills
@skills/recon-basic.md
@skills/ai-self-validator.md

# 4. Execute Workflow
@workflows/02-api-security-hunt.md

# 5. Apply Methodologies
- Recon: @methodologies/03-yandex-recon-methodology.md
- Testing: Entry #23 (NoSQL injection)
- Validation: @methodologies/03-ai-self-validation.md

# 6. Document Findings
- Challenge each finding (80% rejection expected)
- Build PoC for confirmed issues
- Write report (no AI slop)

# 7. Submit
- Platform: Bugcrowd/HackerOne
- Follow disclosure policy
```

## 🚨 Important Notes

### What This Framework IS:

✅ Curated methodologies from real findings  
✅ Declarative workflows (if/then logic)  
✅ Deterministic validation (curl, nuclei)  
✅ Manual curation of techniques  
✅ Framework-agnostic (works anywhere)  

### What This Framework IS NOT:

❌ Automated exploitation tool  
❌ "AI that finds bugs for you"  
❌ Auto-learning system  
❌ Replacement for manual testing  
❌ Magic bullet  

**You are the intelligence. This is your toolkit.**

## 📝 Contributing

This framework is built from real-world hunting experience. Contributions welcome:

1. Real writeups with documented bounties
2. Proven methodologies (not theory)
3. Tools that actually work
4. Techniques you've successfully used

**No:**
- Theoretical vulnerabilities
- Untested tools
- AI-generated content without validation
- Generic security advice

## 📜 License

MIT License - Use freely, attribute sources where applicable.

## 🙏 Credits

Built from 202+ resources including:

- Cassim (@aituglo) - Complete methodology
- Walid Ladeb (@ladebw) - AI self-validation
- 0xSabir - Mass assignment techniques
- Koupon (@Shabosec) - Yandex dorking
- xEHLE (@xEHLE_) - Solana router vulnerabilities
- And 60+ other researchers and writeups

## 🔗 Resources

- **Full Resource List**: See `resources/00-INBOX.md`
- **Integration Guide**: See `INTEGRATION-GUIDE.md`
- **System Status**: See `STATUS.md`

---

**Remember:** This is a framework, not a script. You still need to:
- Understand the vulnerabilities
- Test manually
- Validate findings
- Write clear reports
- Act ethically

**Happy hunting! 🎯**
