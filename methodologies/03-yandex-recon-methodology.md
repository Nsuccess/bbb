# Yandex Recon Methodology

## Overview

Yandex search engine provides unique reconnaissance capabilities that complement Google dorking, with superior coverage of Russian-language sites, better date search functionality, and the ability to discover subdomains that other search engines miss. This methodology combines automated loop-based dorking with manual verification workflows.

**Key Advantages:**
- Discovers assets other search engines miss (old routes, forgotten APIs, staging environments)
- Superior date-based search capabilities
- Better Russian-language site coverage
- Unique subdomain enumeration via wildcard operators
- Finds indexed content that Google doesn't know about

**Philosophy:** "Yandex dork is not Magic" - automated discovery must be followed by manual verification and testing.

---

## Table of Contents

1. [Yandex Search Operators](#yandex-search-operators)
2. [Automated Recon Loop Workflow](#automated-recon-loop-workflow)
3. [Manual Verification Workflow](#manual-verification-workflow)
4. [Subdomain Enumeration Technique](#subdomain-enumeration-technique)
5. [Success Patterns & Case Studies](#success-patterns--case-studies)
6. [Comparison with Google Dorking](#comparison-with-google-dorking)
7. [Tools & Scripts](#tools--scripts)
8. [Kiro Automation Integration](#kiro-automation-integration)

---

## 1. Yandex Search Operators

### Basic Search Syntax

| Operator | Purpose | Example |
|----------|---------|---------|
| `!word` | Exact form (no synonyms/forms) | `!admin` |
| `+word` | Must contain word | `+password` |
| `"exact phrase"` | Exact phrase match | `"Index of /"` |
| `"phrase * phrase"` | Missing word (one * = one word) | `"config * file"` |
| `word1 \| word2` | Alternatives (OR) | `admin \| login` |
| `phrase -unwanted` | Exclusion | `site:example.com -www` |
| `(word1 \| word2)` | Grouping | `training (java \| PHP)` |

### URL/Domain Operators

| Operator | Purpose | Example |
|----------|---------|---------|
| `url:full_URL` | Specific page | `url:example.com/admin/config.php` |
| `url:hostname/folder/*` | Section search | `url:example.com/api/*` |
| `site:domain` | All subdomains and pages | `site:example.com` |
| `host:www.domain.tld` | Specific subdomain only | `host:api.example.com` |
| `rhost:tld.domain.www` | Reverse hostname (supports wildcards) | `rhost:com.example.*` |
| `domain:level` | Any domain level | `domain:edu` |

### File Type Operator

**Syntax:** `mime:type`

**Supported types:**
- Documents: `doc`, `docx`, `pdf`, `rtf`, `odt`
- Spreadsheets: `xls`, `xlsx`, `ods`
- Presentations: `ppt`, `pptx`, `odp`
- Other: `html`, `swf`, `odg`

**Example:** `site:example.com (mime:pdf | mime:doc | mime:docx)`

### Language Operator

**Syntax:** `lang:code`

**Supported:** `ru`, `uk`, `be`, `en`, `fr`, `de`, `kk`, `tt`, `tr`

**Example:** `site:example.com lang:en`

### Date Search (SUPERIOR TO GOOGLE)

| Syntax | Purpose | Example |
|--------|---------|---------|
| `date:YYYYMMDD` | Exact date | `date:20260511` |
| `date:YYYYMMDD..YYYYMMDD` | Date range | `date:20260401..20260430` |
| `date:<YYYYMMDD` | Before date | `date:<20260101` |
| `date:>YYYYMMDD` | After date | `date:>20260101` |
| `date:YYYY**` | Partial date (year only) | `date:2026**` |

**Examples:**
```
site:example.com date:20260510..20260511
"API documentation" site:example.com date:2026**
```

### Title Search

**Method 1:** Use advanced form: https://suip.biz/ru/?act=yandex-search

**Method 2:** Add `&zone=title` to search URL

### Exact Word Form

**Method 1:** Quote each word individually: `"admin" "panel" "login"`

**Method 2:** Edit URI: add `wordforms=exact` parameter

---

## 2. Automated Recon Loop Workflow

### Loop-Based Approach

**Philosophy:** Recon → Filter → Validate → Repeat

The automated loop discovers assets continuously, categorizes them, and prepares them for manual verification.

### Dork Categories

#### Category 1: API Endpoints
```bash
site:example.com (/api/ | graphql | swagger | openapi | redoc)
site:example.com (url:*/api/* | url:*/graphql* | url:*/v1/* | url:*/v2/*)
```

**Targets:**
- REST API endpoints
- GraphQL endpoints
- API documentation (Swagger, OpenAPI, ReDoc)
- Versioned API paths

#### Category 2: JavaScript Files
```bash
site:example.com (_next/static | chunk.js | app.js | main.js | bundle.js)
site:example.com (mime:html url:*.js)
```

**Targets:**
- Next.js static files
- Webpack chunks
- Main application bundles
- Source maps

#### Category 3: Auth/Admin Panels
```bash
site:example.com (admin | login | dashboard | signin | portal)
site:example.com (url:*/admin/* | url:*/login* | url:*/dashboard*)
```

**Targets:**
- Admin panels
- Login pages
- User dashboards
- Authentication portals

#### Category 4: Environments
```bash
site:example.com (staging | dev | test | beta | internal | uat)
site:example.com (host:staging.* | host:dev.* | host:test.*)
```

**Targets:**
- Staging environments
- Development servers
- Testing instances
- Internal systems
- UAT environments

#### Category 5: Config/Secrets
```bash
site:example.com (config | token | secret | password | key | credential)
site:example.com (.env | config.json | settings.xml)
```

**Targets:**
- Configuration files
- Environment variables
- API keys/tokens
- Credentials
- Secret files

#### Category 6: File Types
```bash
site:example.com (mime:json | mime:xml | mime:txt | mime:pdf)
site:example.com "Index of /" (mime:log | mime:txt)
```

**Targets:**
- JSON responses
- XML files
- Text files
- Log files
- PDF documents

#### Category 7: Cloud Assets
```bash
site:example.com (firebase | s3.amazonaws.com | blob.core.windows.net | storage.googleapis.com)
```

**Targets:**
- Firebase instances
- AWS S3 buckets
- Azure Blob storage
- Google Cloud Storage

#### Category 8: Open Directories
```bash
site:example.com "Index of /" "Parent Directory"
site:example.com "Index of /admin" "Parent Directory"
site:example.com "Index of /backup" "Parent Directory"
site:example.com "Index of /.ssh/" "Parent Directory"
```

**Targets:**
- Directory listings
- Backup directories
- SSH key directories
- Upload directories

### Automation Script Structure

**Core Loop:**
```bash
#!/bin/bash
# yandexloop.sh - Automated Yandex Recon Loop

TARGET="$1"
OUTPUT_DIR="yandex_recon_${TARGET}"
mkdir -p "$OUTPUT_DIR"

# Rate limiting (5 seconds between requests)
SLEEP_TIME=5

# User-Agent spoofing for better results
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Function to perform search and save results
search_and_save() {
    local query="$1"
    local output_file="$2"
    
    # Perform search (pseudo-code - actual implementation varies)
    curl -A "$USER_AGENT" "https://yandex.com/search/?text=${query}" \
        | grep -oP 'https?://[^\s<>"]+' \
        | sort -u \
        >> "$output_file"
    
    sleep $SLEEP_TIME
}

# Category 1: API Endpoints
echo "[*] Searching for API endpoints..."
search_and_save "site:${TARGET} (/api/ | graphql | swagger)" \
    "$OUTPUT_DIR/api.txt"

# Category 2: JavaScript Files
echo "[*] Searching for JavaScript files..."
search_and_save "site:${TARGET} (chunk.js | app.js | main.js)" \
    "$OUTPUT_DIR/javascript.txt"

# Category 3: Auth/Admin
echo "[*] Searching for auth/admin panels..."
search_and_save "site:${TARGET} (admin | login | dashboard)" \
    "$OUTPUT_DIR/auth_admin.txt"

# Category 4: Environments
echo "[*] Searching for non-production environments..."
search_and_save "site:${TARGET} (staging | dev | test | beta)" \
    "$OUTPUT_DIR/environments.txt"

# Category 5: Config/Secrets
echo "[*] Searching for config/secrets..."
search_and_save "site:${TARGET} (config | token | secret | .env)" \
    "$OUTPUT_DIR/config_secrets.txt"

# Category 6: File Types
echo "[*] Searching for interesting file types..."
search_and_save "site:${TARGET} (mime:json | mime:xml | mime:txt)" \
    "$OUTPUT_DIR/files.txt"

# Category 7: Cloud Assets
echo "[*] Searching for cloud assets..."
search_and_save "site:${TARGET} (firebase | s3.amazonaws.com)" \
    "$OUTPUT_DIR/cloud.txt"

# Category 8: Open Directories
echo "[*] Searching for open directories..."
search_and_save "site:${TARGET} \"Index of /\" \"Parent Directory\"" \
    "$OUTPUT_DIR/open_directories.txt"

# Deduplication
echo "[*] Deduplicating results..."
for file in "$OUTPUT_DIR"/*.txt; do
    sort -u "$file" -o "$file"
done

echo "[+] Recon complete! Results saved to $OUTPUT_DIR/"
```

**Key Features:**
- Rate limiting (5 seconds between requests)
- User-Agent spoofing
- Automatic categorization into buckets
- Deduplication
- Organized output structure

---

## 3. Manual Verification Workflow

### Post-Discovery Process

**Critical:** Automated dorking finds candidates; manual verification confirms exploitability.

### Step 1: Review Automated Results

**For each category bucket:**
1. Open the results file (e.g., `api.txt`, `javascript.txt`)
2. Prioritize by potential impact:
   - **High:** Config/secrets, open directories, admin panels
   - **Medium:** API endpoints, environments, cloud assets
   - **Low:** General files, JavaScript

### Step 2: Source Code Analysis

**For JavaScript files:**
```bash
# Download and analyze
wget https://target.com/static/chunk.js
cat chunk.js | grep -E "(api|endpoint|token|key|secret|password)"
```

**Look for:**
- Hardcoded API endpoints
- API keys/tokens
- Internal URLs
- Debug flags
- Environment variables
- GraphQL schemas
- Commented-out code

**Tools:**
- JSMiner
- metasecjs
- LinkFinder
- SecretFinder

### Step 3: Open Directory Exploration

**When "Index of /" found:**
1. Browse directory structure
2. Look for:
   - Backup files (`.bak`, `.old`, `.backup`)
   - Configuration files
   - Database dumps
   - SSH keys (`.ssh/`)
   - Git repositories (`.git/`)
   - Environment files (`.env`)
   - Log files
   - User data

**Example finds:**
- Password files
- User databases
- Private contracts
- Private documentation
- Private conversations
- Access to user accounts

### Step 4: Test Functionality

**For each discovered asset:**
1. **Access Control:** Can you access without auth?
2. **Functionality:** What does it do?
3. **Data Exposure:** What data is visible?
4. **Privilege Level:** What permissions do you have?

**Example tests:**
- Try default credentials on admin panels
- Test API endpoints without authentication
- Check if staging environments have weaker security
- Verify if config files contain secrets
- Test if cloud buckets are publicly accessible

### Step 5: Document Findings

**For valid findings:**
- URL/endpoint
- Discovery method (specific dork used)
- Impact (data exposed, functionality accessible)
- Steps to reproduce
- Screenshots/evidence
- Potential vulnerability classification

---

## 4. Subdomain Enumeration Technique

### Alphabet-Based Wildcard Enumeration

**Unique Yandex Capability:** The `rhost:` operator supports wildcards, enabling systematic subdomain discovery.

### Methodology

**Syntax:** `rhost:tld.domain.subdomain_pattern*`

**Process:** Enumerate subdomains letter by letter through the alphabet.

### Step-by-Step Process

```bash
# Target: example.com
# Enumerate all subdomains starting with 'a'
rhost:com.example.a*

# Continue through alphabet
rhost:com.example.b*
rhost:com.example.c*
rhost:com.example.d*
# ... through z

# For multi-level subdomains
rhost:com.example.api.a*
rhost:com.example.api.b*
# etc.
```

### Automation Script

```bash
#!/bin/bash
# yandex_subdomain_enum.sh

TARGET="$1"  # e.g., example.com
OUTPUT="subdomains_${TARGET}.txt"

# Split domain into parts
IFS='.' read -ra PARTS <<< "$TARGET"
TLD="${PARTS[-1]}"
DOMAIN="${PARTS[-2]}"

# Reverse for rhost format
RHOST_BASE="${TLD}.${DOMAIN}"

echo "[*] Enumerating subdomains for $TARGET using Yandex..."

# Iterate through alphabet
for letter in {a..z}; do
    echo "[*] Searching: ${letter}*"
    
    # Perform search (pseudo-code)
    curl -A "Mozilla/5.0" \
        "https://yandex.com/search/?text=rhost:${RHOST_BASE}.${letter}*" \
        | grep -oP "${letter}[a-z0-9-]*\.${TARGET}" \
        | sort -u \
        >> "$OUTPUT"
    
    sleep 5
done

# Deduplicate
sort -u "$OUTPUT" -o "$OUTPUT"

echo "[+] Found $(wc -l < $OUTPUT) unique subdomains"
echo "[+] Results saved to $OUTPUT"
```

### Real-World Results

**Example: kali.org enumeration**

Found subdomains that Google didn't know:
- `builddd-amd64.kali.org`
- `eros.kali.org`
- `eos.kali.org`
- `iris.kali.org`
- `images.kali.org`

**Example: offensive-security.com**
- `download.offensive-security.com`
- `forums.offensive-security.com`
- `support.offensive-security.com`

### Advantages Over Traditional Methods

| Method | Coverage | Speed | Accuracy |
|--------|----------|-------|----------|
| DNS Brute-force | Dictionary-limited | Fast | High |
| Certificate Transparency | Active certs only | Fast | High |
| **Yandex Wildcard** | **Indexed content** | **Moderate** | **High** |
| Google Dorking | Limited | Moderate | High |

**Key Advantage:** Discovers subdomains that exist in Yandex's index but may not be in DNS wordlists or CT logs.

### Combining with Other Methods

**Optimal workflow:**
1. **Passive DNS** (crt.sh, Censys) - Fast, comprehensive
2. **Yandex Wildcard** - Finds indexed but obscure subdomains
3. **DNS Brute-force** - Fills gaps with wordlist
4. **Merge & Deduplicate** - Combine all sources

---

## 5. Success Patterns & Case Studies

### Case Study 1: Private Directory Discovery (Koupon/Shabosec)

**Method:** Yandex dorking + source code analysis + manual testing

**Discovery Process:**
1. Input target in Yandex dork
2. Analyze source code and JavaScript files
3. Test discovered endpoints
4. Found open directory

**Results:**
- Private Documentation
- Private Conversations
- Private Contracts
- Private Data Management System
- Access to individual user accounts

**Impact:** Critical information disclosure + unauthorized access

**Key Quote:** "Yandex dork never Fail" - but requires manual verification

**Lesson:** Open directories are high-value targets; Yandex indexes them well.

### Case Study 2: Subdomain Discovery Competition

**Target:** kali.org and offensive-security.com

**Method:** Alphabet-based wildcard enumeration (`rhost:org.kali.a*` through `z*`)

**Results:**
- Found subdomains Google didn't know
- Discovered build servers, internal tools, support systems
- Competitive with dictionary-based brute-force

**Lesson:** Yandex's index contains subdomains missed by other search engines.

### Success Pattern Analysis

**Common High-Value Finds:**

1. **Open Directories (40% of successes)**
   - Backup files
   - Configuration files
   - User data
   - Private documents

2. **Staging/Dev Environments (25%)**
   - Weaker security controls
   - Debug information enabled
   - Test data with real patterns

3. **Forgotten API Endpoints (20%)**
   - Old API versions
   - Undocumented endpoints
   - Legacy integrations

4. **JavaScript Files (10%)**
   - Hardcoded credentials
   - Internal endpoints
   - API keys

5. **Cloud Assets (5%)**
   - Misconfigured S3 buckets
   - Public Firebase instances
   - Exposed storage accounts

### Timing Patterns

**Best results when searching for:**
- Recently indexed content (`date:>20260401`)
- Old forgotten content (`date:<20200101`)
- Specific date ranges during migrations/launches

---

## 6. Comparison with Google Dorking

### Yandex Advantages

| Feature | Yandex | Google |
|---------|--------|--------|
| **Russian-language sites** | ✅ Superior | ❌ Limited |
| **Date search** | ✅ Flexible, precise | ❌ Basic |
| **Subdomain discovery** | ✅ Wildcard support | ❌ No wildcards |
| **Indexed subdomains** | ✅ More obscure ones | ❌ Mainstream only |
| **Open directories** | ✅ Good coverage | ✅ Good coverage |

### Google Advantages

| Feature | Google | Yandex |
|---------|--------|--------|
| **General dorking** | ✅ More flexible | ❌ Less flexible |
| **English-language sites** | ✅ Superior | ❌ Limited |
| **Index size** | ✅ Larger | ❌ Smaller |
| **Operator variety** | ✅ More operators | ❌ Fewer operators |
| **Speed** | ✅ Faster | ❌ Slower |

### When to Use Each

**Use Yandex when:**
- Target has Russian-language content
- Need precise date-based searches
- Enumerating subdomains systematically
- Looking for obscure/forgotten assets
- Google results exhausted

**Use Google when:**
- General reconnaissance
- English-language targets
- Need broader operator support
- Speed is priority
- Looking for mainstream content

**Best Practice:** Use BOTH in parallel for comprehensive coverage.

### Parallel Workflow

```bash
# Run Google dorks
./google_recon.sh target.com

# Run Yandex dorks
./yandex_recon.sh target.com

# Merge and deduplicate
cat google_results/*.txt yandex_results/*.txt \
    | sort -u \
    > combined_results.txt

# Analyze unique findings from each
comm -23 <(sort yandex_results/all.txt) <(sort google_results/all.txt) \
    > yandex_unique.txt
```

---

## 7. Tools & Scripts

### Core Scripts

#### 1. yandexloop.sh
**Purpose:** Automated multi-category Yandex dorking

**Features:**
- 8 dork categories
- Rate limiting
- User-Agent spoofing
- Auto-categorization
- Deduplication

**Usage:**
```bash
./yandexloop.sh target.com
```

**Output:**
```
yandex_recon_target.com/
├── api.txt
├── javascript.txt
├── auth_admin.txt
├── environments.txt
├── config_secrets.txt
├── files.txt
├── cloud.txt
└── open_directories.txt
```

#### 2. yandex_subdomain_enum.sh
**Purpose:** Alphabet-based subdomain enumeration

**Features:**
- Wildcard-based discovery
- Alphabet iteration (a-z)
- Deduplication
- Progress tracking

**Usage:**
```bash
./yandex_subdomain_enum.sh target.com
```

**Output:**
```
subdomains_target.com.txt
```

#### 3. yandex_date_search.sh
**Purpose:** Time-based asset discovery

**Features:**
- Date range searches
- Recent changes detection
- Old forgotten content discovery

**Usage:**
```bash
# Find content from last 30 days
./yandex_date_search.sh target.com 30

# Find content older than 5 years
./yandex_date_search.sh target.com -1825
```

### Supporting Tools

#### JavaScript Analysis
- **JSMiner:** Extract endpoints from JS files
- **metasecjs:** Security-focused JS analysis
- **LinkFinder:** Find endpoints in JavaScript
- **SecretFinder:** Extract secrets from JS

#### CAPTCHA Handling (for automation)
- **playwright-stealth:** Headless browser with stealth
- **2Captcha:** CAPTCHA solving service ($1/1000)
- **Residential proxies:** Avoid bot detection

#### Integration Tools
- **waymore:** Wayback Machine crawler
- **Katana:** Web crawler
- **gospider:** Fast web spider

### Rate Limiting & Stealth

**Best Practices:**
```bash
# Rate limiting
SLEEP_TIME=5  # 5 seconds between requests

# User-Agent rotation
USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
)
UA="${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}"

# Proxy rotation (if needed)
PROXY="http://proxy:port"
curl -x "$PROXY" -A "$UA" "https://yandex.com/search/?text=..."
```

**CAPTCHA Avoidance:**
1. Use residential proxies (not datacenter)
2. Add random delays (8-15 seconds)
3. Rotate User-Agents
4. Use headless browser with stealth plugin
5. Implement human-like mouse movement (if using browser)
6. Fallback to CAPTCHA solving service (2Captcha)

---

## 8. Kiro Automation Integration

### Automation Opportunities

#### 1. Automated Recon Hook
**Trigger:** New target added to scope

**Actions:**
1. Run `yandexloop.sh` for target
2. Run `yandex_subdomain_enum.sh` for target
3. Categorize results
4. Prioritize by potential impact
5. Queue for manual verification

**Kiro Hook:**
```yaml
name: Yandex Auto-Recon
trigger: new_target
actions:
  - run: yandexloop.sh {target}
  - run: yandex_subdomain_enum.sh {target}
  - categorize: results
  - notify: manual_verification_queue
```

#### 2. JavaScript Analysis Agent
**Purpose:** Automatically analyze discovered JS files

**Workflow:**
1. Extract JS URLs from `javascript.txt`
2. Download each file
3. Run JSMiner, LinkFinder, SecretFinder
4. Extract:
   - API endpoints
   - Hardcoded secrets
   - Internal URLs
   - Debug flags
5. Report findings

**Kiro Skill:**
```yaml
name: JS Analysis Agent
input: javascript_urls
tools:
  - JSMiner
  - LinkFinder
  - SecretFinder
output: extracted_endpoints_and_secrets
```

#### 3. Open Directory Validator
**Purpose:** Verify and explore open directories

**Workflow:**
1. Read URLs from `open_directories.txt`
2. For each URL:
   - Verify directory listing is accessible
   - Crawl directory structure
   - Identify sensitive files
   - Download high-value files
   - Classify by sensitivity
3. Generate report

**Kiro Skill:**
```yaml
name: Open Directory Validator
input: directory_urls
actions:
  - verify_access
  - crawl_structure
  - identify_sensitive_files
  - classify_by_impact
output: validated_findings
```

#### 4. Parallel Google + Yandex Recon
**Purpose:** Run both search engines simultaneously

**Workflow:**
1. Launch Google recon agent
2. Launch Yandex recon agent (parallel)
3. Wait for both to complete
4. Merge results
5. Identify unique findings from each
6. Prioritize combined results

**Kiro Workflow:**
```yaml
name: Parallel Search Engine Recon
agents:
  - google_recon_agent
  - yandex_recon_agent
execution: parallel
post_processing:
  - merge_results
  - deduplicate
  - identify_unique_per_engine
  - prioritize
```

#### 5. Date-Based Change Detection
**Purpose:** Monitor for new/changed content

**Workflow:**
1. Run date-based search for last 7 days
2. Compare with previous results
3. Identify new assets
4. Flag for immediate review
5. Schedule recurring checks

**Kiro Hook:**
```yaml
name: Yandex Change Monitor
trigger: schedule (weekly)
actions:
  - run: yandex_date_search.sh {target} 7
  - compare: previous_results
  - identify: new_assets
  - alert: high_priority
```

### Integration Points

#### Input Sources
1. **Target List:** Read from scope file
2. **Previous Results:** Compare with historical data
3. **Prioritization Rules:** Apply impact-based scoring

#### Output Destinations
1. **Manual Verification Queue:** High-priority findings
2. **Automated Testing:** API endpoints, auth panels
3. **Reporting System:** Validated vulnerabilities
4. **Knowledge Base:** Patterns and techniques

### Preparation Notes for Kiro

#### Required Capabilities
1. **Shell Script Execution:** Run bash scripts
2. **HTTP Requests:** Perform searches, download files
3. **File Management:** Save, categorize, deduplicate results
4. **Text Processing:** Parse search results, extract URLs
5. **Scheduling:** Recurring recon tasks
6. **Parallel Execution:** Multiple agents simultaneously

#### Configuration Needs
1. **Rate Limiting:** Configurable delays
2. **Proxy Support:** Residential proxy integration
3. **CAPTCHA Handling:** 2Captcha API integration
4. **User-Agent Rotation:** Multiple UA strings
5. **Output Paths:** Organized directory structure

#### Agent Roles
1. **Recon Agent:** Execute dorking scripts
2. **Analysis Agent:** Process JavaScript, configs
3. **Validation Agent:** Verify findings manually
4. **Reporting Agent:** Document vulnerabilities
5. **Conductor Agent:** Orchestrate workflow

### Workflow Templates

#### Template 1: Initial Target Recon
```
1. Run yandexloop.sh for all dork categories
2. Run yandex_subdomain_enum.sh for subdomain discovery
3. Analyze JavaScript files for endpoints/secrets
4. Validate open directories
5. Test discovered admin/auth panels
6. Document findings
```

#### Template 2: Focused API Discovery
```
1. Run API-specific Yandex dorks
2. Extract API endpoints from JavaScript
3. Test endpoints for authentication
4. Check for API documentation (Swagger, etc.)
5. Enumerate API versions
6. Test for common API vulnerabilities
```

#### Template 3: Subdomain Deep Dive
```
1. Enumerate subdomains via Yandex wildcard
2. Combine with passive DNS sources
3. Probe each subdomain for services
4. Run targeted dorks on each subdomain
5. Identify staging/dev environments
6. Test for subdomain takeover
```

#### Template 4: Historical Asset Discovery
```
1. Search for old content (date:<2020)
2. Search for recent changes (date:>30 days ago)
3. Compare old vs new architecture
4. Identify forgotten/legacy systems
5. Test old endpoints for security issues
```

---

## Summary

### Key Takeaways

1. **Yandex complements Google** - Use both for comprehensive coverage
2. **Automation + Manual = Success** - Scripts find candidates, humans verify
3. **Subdomain wildcards are unique** - Yandex's killer feature
4. **Date search is superior** - Better than Google for time-based queries
5. **Open directories are gold** - High-value targets, well-indexed by Yandex
6. **Rate limiting is critical** - Avoid detection, use stealth techniques
7. **Categorization improves efficiency** - Organize findings by type
8. **Manual verification is mandatory** - "Yandex dork is not Magic"

### Quick Reference

**Best Yandex Dorks:**
```
site:target.com "Index of /" "Parent Directory"
site:target.com (staging | dev | test | beta)
site:target.com (/api/ | graphql | swagger)
rhost:com.target.* (subdomain enumeration)
site:target.com date:>20260401 (recent changes)
```

**Essential Tools:**
- yandexloop.sh (automated dorking)
- yandex_subdomain_enum.sh (subdomain discovery)
- JSMiner (JavaScript analysis)
- 2Captcha (CAPTCHA solving)
- playwright-stealth (bot detection bypass)

**Workflow:**
1. Automated dorking (yandexloop.sh)
2. Subdomain enumeration (wildcard method)
3. JavaScript analysis (extract endpoints/secrets)
4. Manual verification (test functionality)
5. Document findings (impact assessment)

---

## References

- **Entry #004:** Yandex Dork Recon Loop (yadexloop.sh script)
- **Entry #012:** Yandex Dork Success Story (Koupon/Shabosec)
- **Entry #013:** Advanced Yandex Search Guide (https://hackware.ru/?p=6045)
- **Advanced Search Interface:** https://suip.biz/ru/?act=yandex-search

---

*Last Updated: 2026-05-11*
*Methodology Version: 1.0*
