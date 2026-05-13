# Quick Start Guide

Get started with the Bug Bounty Automation Framework in 5 minutes.

## 🚀 Installation

### Option 1: Clone Repository

```bash
git clone https://github.com/yourusername/bug-bounty-automation.git
cd bug-bounty-automation
```

### Option 2: Download ZIP

Download and extract to your workspace.

## 🎯 Choose Your Tool

### Claude Code (Kiro)

```bash
# Copy skills to Kiro
cp -r skills/ ~/.kiro/skills/

# Copy steering files
cp -r steering/ ~/.kiro/steering/

# Reference in prompts
@skills/recon-basic.md
```

### Cursor

```bash
# Add to workspace
# Reference in .cursorrules

# Use @ mentions
@skills/oauth-security-auditor.md
```

### Windsurf

```bash
# Add to project context
# Reference in cascade files
# Use in agent prompts
```

## 📖 Your First Hunt

### Step 1: Pick a Target

```markdown
Target: api.example.com
Type: REST API
Authorization: Yes (registered on bug bounty program)
```

### Step 2: Load Router

```markdown
@workflows/00-router.md

Input: REST API target
Output: Recommends 02-api-security-hunt.md
```

### Step 3: Load Skills

```markdown
@skills/recon-basic.md
@skills/ai-self-validator.md
```

### Step 4: Execute Workflow

```markdown
@workflows/02-api-security-hunt.md

Follow steps:
1. Asset discovery
2. Endpoint enumeration
3. Authentication testing
4. Authorization testing (IDOR)
5. Input validation
6. Business logic
```

### Step 5: Apply Methodologies

```markdown
# For OAuth endpoints
@methodologies/02-oauth-security-testing.md

# For validation
@methodologies/03-ai-self-validation.md
```

### Step 6: Reference Resources

```markdown
# IDOR testing
Entry #7: Mass assignment
Entry #25: Export functionality IDOR
Entry #41: $9k BAC IDOR writeup

# Validation
Entry #5: AI self-validation (80% rejection rate)
```

## 🎓 Example: IDOR Hunt

### Complete Example

```markdown
# 1. Target Selection
Target: booking.example.com
Focus: Booking system IDOR

# 2. Load Skills
@skills/recon-basic.md
@skills/ai-self-validator.md

# 3. Recon Phase
- Enumerate endpoints
- Map booking flow
- Identify booking IDs

# 4. Testing Phase
Test: GET /api/bookings/{id}
- User A creates booking (ID: 12345)
- User B tries to access booking 12345
- Expected: 403 Forbidden
- Vulnerable: 200 OK with data

# 5. Validation Phase
@skills/ai-self-validator.md

Challenge:
- Tested Origin enforcement? ✓
- Tested Referer enforcement? ✓
- Built working PoC? ✓
- Documented why protections fail? ✓

Decision: CONFIRM (all checks pass)

# 6. Reporting Phase
Use template from Entry #22:
- Clear title
- 1-2 sentence impact
- Numbered steps
- Working PoC
- CVSS score

# 7. Submit
Platform: Bugcrowd
Expected: P2 High ($2,500-$3,500)
```

## 📊 Expected Results

### First Week

- ✅ Recon: 50+ endpoints mapped
- ✅ Hunting: 10-15 leads found
- ✅ Validation: 2-3 confirmed (80% rejected)
- ✅ Submissions: 1-2 valid reports

### First Month

- 💰 Payout: $3,000-$5,000
- 📈 Findings: 1x P2 High + 1x P3 Medium
- 🎯 Success Rate: 20% (2-3 valid out of 10-15 leads)

## 🛠️ Essential Tools

Install these tools for best results:

```bash
# Web testing
brew install burpsuite-community  # or download from portswigger.net

# Fuzzing
go install github.com/ffuf/ffuf@latest

# Scanning
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Subdomain enumeration
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# HTTP toolkit
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# JSON parsing
brew install jq

# Advanced file search
brew install ripgrep-all
```

## 📚 Learning Path

### Beginner

1. Read: `README.md`
2. Study: `resources/00-INBOX.md` (Entry #22 - Complete methodology)
3. Practice: Set up HackLabs (Entry #33)
4. Apply: `workflows/01-web-app-hunt.md`

### Intermediate

1. Study: `methodologies/02-oauth-security-testing.md`
2. Practice: OAuth vulnerabilities (Entry #18)
3. Apply: `workflows/02-api-security-hunt.md`
4. Master: `skills/ai-self-validator.md` (80% rejection)

### Advanced

1. Study: `methodologies/01-multi-agent-orchestration.md`
2. Practice: Parallel hunting (Entry #11)
3. Apply: `workflows/05-adaptive-hunt.md`
4. Master: Multiple skills simultaneously

## 🎯 Common Workflows

### Web Application

```markdown
@workflows/01-web-app-hunt.md
@skills/recon-basic.md
Entry #7, #25, #41 (IDOR techniques)
```

### API Testing

```markdown
@workflows/02-api-security-hunt.md
@skills/recon-basic.md
Entry #23 (NoSQL injection)
```

### OAuth Testing

```markdown
@methodologies/02-oauth-security-testing.md
@skills/oauth-security-auditor.md
Entry #18 (OAuth popup hijacking)
```

### AI Application

```markdown
@workflows/03-ai-app-hunt.md
@skills/prompt-injection-hunter.md
Entry #38 (Prompt injection framework)
```

### Blockchain/DeFi

```markdown
@workflows/04-crypto-hunt.md
@skills/crypto-defi-auditor.md
Entry #16 (Solana router vulnerabilities)
```

## ⚠️ Important Reminders

### Before Testing

- ✅ Get authorization (bug bounty program)
- ✅ Read program scope
- ✅ Understand restrictions
- ✅ Use test accounts only

### During Testing

- ✅ Document everything
- ✅ Capture requests/responses
- ✅ Record video PoCs
- ✅ Test responsibly

### Before Submitting

- ✅ Validate finding (80% rejection is normal!)
- ✅ Build working PoC
- ✅ Write clear report (no AI slop)
- ✅ Calculate CVSS score

## 🆘 Troubleshooting

### "I can't find vulnerabilities"

- Use `@skills/ai-self-validator.md` to challenge assumptions
- Reference `Entry #5` - 80% rejection rate is NORMAL
- Try different workflows
- Focus on one vulnerability class

### "My findings are rejected"

- Good! This means validation is working
- Review `Entry #5` - AI self-validation
- Challenge your own findings harder
- Build stronger PoCs

### "I don't know where to start"

- Start with `@workflows/00-router.md`
- Let it recommend a workflow
- Follow step-by-step
- Reference resources as needed

## 📖 Next Steps

1. **Read the full README.md**
2. **Study Entry #22** (Complete methodology)
3. **Practice on HackLabs** (Entry #33)
4. **Pick a target** from a bug bounty program
5. **Start hunting!**

## 🔗 Resources

- **Full Documentation**: `README.md`
- **Framework Structure**: `STRUCTURE.md`
- **Integration Guide**: `INTEGRATION-GUIDE.md`
- **All Resources**: `resources/00-INBOX.md`

---

**Ready to hunt? Pick a workflow and start testing! 🎯**
