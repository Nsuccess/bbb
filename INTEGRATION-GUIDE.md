# Integration Guide: Using This System in Kiro IDE

**Goal:** Make all skills, methodologies, steering files, and workflows available in Kiro IDE

---

## Quick Start (5 Minutes)

### Option 1: Copy Everything to Kiro
```bash
# Navigate to your workspace
cd /path/to/your/workspace

# Copy skills
cp -r bugbounty/bug-bounty-automation/skills/* .kiro/skills/

# Copy steering files
cp -r bugbounty/bug-bounty-automation/steering/* .kiro/steering/

# Copy workflows
cp -r bugbounty/bug-bounty-automation/workflows/* .kiro/workflows/

# Restart Kiro or reload configuration
```

### Option 2: Symlink (Recommended for Development)
```bash
# Create symlinks instead of copying
ln -s $(pwd)/bugbounty/bug-bounty-automation/skills/* .kiro/skills/
ln -s $(pwd)/bugbounty/bug-bounty-automation/steering/* .kiro/steering/
ln -s $(pwd)/bugbounty/bug-bounty-automation/workflows/* .kiro/workflows/
```

---

## What Gets Installed

### Skills (12 files)
Located in `.kiro/skills/`:
- ✅ oauth-security-auditor.md
- ✅ yandex-recon-specialist.md
- ✅ prompt-injection-hunter.md
- ✅ mcp-security-auditor.md
- ✅ ai-self-validator.md
- ✅ multi-agent-orchestrator.md
- ✅ parser-differential-tester.md
- ✅ bucket-squatting-detector.md
- ✅ enterprise-software-auditor.md
- ✅ crypto-defi-auditor.md
- ✅ recon-basic.md
- ✅ router-simple.md

### Steering Files (7 files)
Located in `.kiro/steering/`:
- ✅ core-principles.md (always active)
- ✅ oauth-security-standards.md
- ✅ recon-methodology.md
- ✅ multi-agent-patterns.md
- ✅ disclosure-policy.md
- ✅ cloud-security-standards.md
- ✅ ai-security-testing.md

### Workflows (6 files)
Located in `.kiro/workflows/`:
- ✅ 00-router.md (workflow selector)
- ✅ 01-web-app-hunt.md
- ✅ 02-api-security-hunt.md
- ✅ 03-ai-app-hunt.md
- ✅ 04-crypto-hunt.md
- ✅ 05-adaptive-hunt.md

---

## How to Use

### Method 1: Start with Router
```
1. Open Kiro IDE
2. Load workflow: 00-router.md
3. Provide target: "Hunt https://target.com (web app with OAuth)"
4. Router recommends: 01-web-app-hunt.md
5. Execute recommended workflow
```

### Method 2: Direct Workflow Selection
```
1. Know your target type
2. Load appropriate workflow:
   - Web app → 01-web-app-hunt.md
   - API → 02-api-security-hunt.md
   - AI app → 03-ai-app-hunt.md
   - Crypto → 04-crypto-hunt.md
   - Unknown → 05-adaptive-hunt.md
3. Follow workflow steps
```

### Method 3: Manual Skill Activation
```
1. Load specific skill: oauth-security-auditor.md
2. Follow skill methodology
3. Validate with: ai-self-validator.md
```

---

## Workflow Examples

### Example 1: Hunt a Web App
```
You: "I want to test https://app.example.com - it has Google OAuth login"

Kiro (with router):
1. Analyzes target
2. Detects OAuth
3. Recommends: 01-web-app-hunt.md
4. Loads: oauth-security-auditor.md, yandex-recon-specialist.md
5. Executes workflow steps
6. Validates findings with: ai-self-validator.md
7. Reports results
```

### Example 2: Hunt an API
```
You: "Test https://api.example.com/v1/ - REST API with Swagger"

Kiro (with router):
1. Analyzes target
2. Detects API
3. Recommends: 02-api-security-hunt.md
4. Loads: recon-basic.md
5. Executes workflow steps
6. Tests IDOR, mass assignment, injection
7. Validates and reports
```

### Example 3: Hunt an AI App
```
You: "Test https://chat.example.com - AI chatbot"

Kiro (with router):
1. Analyzes target
2. Detects AI features
3. Recommends: 03-ai-app-hunt.md
4. Loads: prompt-injection-hunter.md, mcp-security-auditor.md
5. Executes workflow steps
6. Tests prompt injection, data exfiltration
7. Validates and reports
```

---

## Steering Files (Always Active)

### What They Do:
Steering files provide **persistent context** for all hunting sessions.

### Core Principles (core-principles.md):
- ✅ Challenge your findings (80% fail at validation)
- ✅ P0 treatment (90-day disclosure is dead)
- ✅ AI-first approach (automation required)
- ✅ Quality over quantity (reputation matters)

### OAuth Security Standards (oauth-security-standards.md):
- ✅ Test popup hijacking
- ✅ Test redirect_uri bypass
- ✅ Test token theft
- ✅ Test non-happy paths

### Recon Methodology (recon-methodology.md):
- ✅ Yandex dorking patterns
- ✅ Subdomain enumeration
- ✅ JavaScript analysis
- ✅ API discovery

---

## Customization

### Add Your Own Skills:
```bash
# Create new skill
cat > .kiro/skills/my-custom-skill.md << 'EOF'
# My Custom Skill

## Role
[Your skill description]

## Methodology
[Your methodology]
EOF
```

### Add Your Own Workflows:
```bash
# Create new workflow
cat > .kiro/workflows/my-custom-workflow.md << 'EOF'
# My Custom Workflow

**Target Type:** [Your target type]

**Skills Used:**
- skill1.md
- skill2.md

## Phase 1: [Phase name]
[Your workflow steps]
EOF
```

### Update Steering Files:
```bash
# Edit existing steering file
nano .kiro/steering/core-principles.md

# Add your own principles
# Kiro will automatically use them
```

---

## Operational Memory (Manual for Now)

### After Each Hunt:
```bash
# Log results
echo "$(date) | target.com | OAuth bypass | CRITICAL | $5,000 | 3 hours" >> hunt-log.txt

# Extract patterns
# - What worked?
# - What didn't work?
# - What to try first next time?
```

### Build Your Own Priority Table:
```markdown
| Technique | Success Rate | Avg Bounty | Avg Time | Priority |
|-----------|--------------|------------|----------|----------|
| OAuth testing | 60% | $4,000 | 2 hours | 🔴 HIGH |
| API IDOR | 80% | $2,000 | 1 hour | 🔴 HIGH |
| Prompt injection | 40% | $3,000 | 2 hours | 🟡 MEDIUM |
| Parser differentials | 20% | $1,500 | 1 hour | 🟢 LOW |
```

### Update Router Based on Learnings:
```bash
# Edit router
nano .kiro/workflows/00-router.md

# Update priorities based on your success rates
# Example: If OAuth hunting very successful, increase priority
```

---

## Troubleshooting

### Skills Not Loading:
```bash
# Check file permissions
ls -la .kiro/skills/

# Ensure files are readable
chmod 644 .kiro/skills/*.md

# Restart Kiro
```

### Steering Files Not Active:
```bash
# Check steering directory
ls -la .kiro/steering/

# Ensure files have frontmatter
head -n 5 .kiro/steering/core-principles.md
# Should see:
# ---
# inclusion: auto
# ---
```

### Workflows Not Found:
```bash
# Check workflows directory
ls -la .kiro/workflows/

# Ensure files exist
# If missing, copy again from source
```

---

## Framework-Agnostic Usage

### This system works in:
- ✅ Kiro IDE (primary)
- ✅ OpenCode
- ✅ Cursor
- ✅ Claude Code
- ✅ Custom Python runners
- ✅ Any LLM tool that supports Markdown

### How:
1. **Skills** = Markdown files (human-readable, LLM-friendly)
2. **Workflows** = Markdown files (declarative, not code)
3. **Steering** = Markdown files (persistent context)
4. **No vendor lock-in** = Works anywhere

### To use in other tools:
```bash
# Copy to your tool's config directory
cp -r bugbounty/bug-bounty-automation/skills/* /path/to/your/tool/skills/
cp -r bugbounty/bug-bounty-automation/steering/* /path/to/your/tool/steering/
cp -r bugbounty/bug-bounty-automation/workflows/* /path/to/your/tool/workflows/
```

---

## GitHub Repository (Optional)

### Make it public:
```bash
# Initialize git
cd bugbounty/bug-bounty-automation
git init

# Add files
git add .

# Commit
git commit -m "Initial commit: Bug bounty automation system"

# Push to GitHub
git remote add origin https://github.com/yourusername/bug-bounty-automation.git
git push -u origin main
```

### Others can clone:
```bash
# Clone repository
git clone https://github.com/yourusername/bug-bounty-automation.git

# Copy to their Kiro
cp -r bug-bounty-automation/skills/* .kiro/skills/
cp -r bug-bounty-automation/steering/* .kiro/steering/
cp -r bug-bounty-automation/workflows/* .kiro/workflows/
```

---

## Next Steps

### 1. Install the System (5 min)
```bash
# Copy files to Kiro
cp -r bugbounty/bug-bounty-automation/skills/* .kiro/skills/
cp -r bugbounty/bug-bounty-automation/steering/* .kiro/steering/
cp -r bugbounty/bug-bounty-automation/workflows/* .kiro/workflows/
```

### 2. Test on a Target (2-4 hours)
```
# Start with router
Load: 00-router.md
Provide target
Execute recommended workflow
```

### 3. Log Results (5 min)
```bash
# After hunt
echo "$(date) | target | technique | result | bounty | time" >> hunt-log.txt
```

### 4. Iterate (Ongoing)
```
# Based on results:
- Update priorities
- Add new techniques
- Refine workflows
- Build operational memory
```

---

## Support

### Questions?
- Check the 72 resources in `resources/00-INBOX.md`
- Review methodologies in `methodologies/`
- Read skill files for detailed techniques

### Contributing:
- Add your own skills
- Share successful workflows
- Update priorities based on results
- Build operational memory organically

---

## Summary

**You now have:**
- ✅ 12 specialized skills
- ✅ 7 steering files (always active)
- ✅ 6 workflows (web, API, AI, crypto, adaptive, router)
- ✅ 7 methodologies (deep dives)
- ✅ 72 resources (organized and extracted)
- ✅ Framework-agnostic (works anywhere)
- ✅ Ready to hunt TODAY

**Start hunting:**
```bash
# Copy to Kiro
cp -r bugbounty/bug-bounty-automation/{skills,steering,workflows}/* .kiro/

# Load router
# Provide target
# Execute workflow
# Find bugs
# Get paid
```

🔥 **LET'S GO!** 🔥
