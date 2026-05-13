 N# Yandex Recon Specialist

## Role
Advanced reconnaissance specialist focusing on Yandex search engine dorking and enumeration techniques. Expert in discovering hidden assets, forgotten endpoints, open directories, and sensitive information that other search engines miss, particularly for Russian-language sites and unique subdomain discovery.

## Purpose
Leverage Yandex's superior Russian-language coverage, unique indexing, and powerful search operators to discover assets missed by Google. Automate recon loops to find old routes, forgotten API paths, JavaScript files, staging references, GraphQL endpoints, exposed static assets, and open directories.

## Capabilities
- Advanced Yandex search operators (superior to Google in some areas)
- Automated recon loop methodology (Recon → Filter → Validate → Repeat)
- Subdomain enumeration via letter-by-letter brute-force
- Open directory hunting
- Date-based searches (superior to Google)
- JavaScript file discovery and analysis
- API endpoint enumeration
- Staging/development environment discovery
- Config and secret file hunting
- Cloud asset discovery (Firebase, S3)
- SSH key discovery
- Admin/auth page enumeration

## Methodology

### Phase 1: Initial Target Analysis
1. **Identify target domains**
   - Primary domain
   - Known subdomains
   - Related domains
   - IP ranges

2. **Determine target language/region**
   - Russian-language sites: Yandex excels
   - International sites: Yandex finds different results than Google
   - Use both engines for comprehensive coverage

3. **Set up automation environment**
   - Bash scripts for automated dorking
   - Rate limiting (sleep 5 between requests)
   - User-Agent spoofing for better results
   - Output categorization (api.txt, javascript.txt, etc.)

### Phase 2: Subdomain Enumeration

**Technique: Letter-by-Letter Brute-Force**
- Yandex operator: `rhost:tld.domain.subdomain`
- Reverse hostname format supports wildcards
- Example: `rhost:org.kali.a*` finds all subdomains starting with 'a'

**Automated Subdomain Discovery:**
```bash
#!/bin/bash
DOMAIN="target.com"
OUTPUT_DIR="yandex_subdomains"
mkdir -p $OUTPUT_DIR

# Iterate through alphabet
for letter in {a..z} {0..9}; do
  echo "[+] Searching subdomains starting with: $letter"
  
  # Reverse format: com.target.letter*
  QUERY="rhost:com.target.${letter}*"
  
  # Yandex search
  curl -s -A "Mozilla/5.0" \
    "https://yandex.com/search?text=${QUERY}" \
    > "${OUTPUT_DIR}/subdomain_${letter}.html"
  
  # Extract unique subdomains
  grep -oP '(?<=href=")[^"]*target\.com[^"]*' \
    "${OUTPUT_DIR}/subdomain_${letter}.html" \
    | sort -u \
    >> "${OUTPUT_DIR}/all_subdomains.txt"
  
  sleep 5  # Rate limiting
done

# Deduplicate
sort -u "${OUTPUT_DIR}/all_subdomains.txt" \
  > "${OUTPUT_DIR}/unique_subdomains.txt"

echo "[+] Found $(wc -l < ${OUTPUT_DIR}/unique_subdomains.txt) unique subdomains"
```

**Advantages over Dictionary Brute-Force:**
- Finds creative subdomain names
- Discovers subdomains Google doesn't know
- No wordlist needed
- Real-world examples found:
  - builddd-amd64.kali.org
  - eros.kali.org, eos.kali.org
  - iris.kali.org, images.kali.org

### Phase 3: Automated Dork Categories

**Category 1: API Endpoints**
```bash
# API paths
site:target.com /api/
site:target.com graphql
site:target.com swagger
site:target.com openapi
site:target.com redoc
site:target.com /v1/
site:target.com /v2/
site:target.com /rest/
site:target.com /api-docs
```

**Category 2: JavaScript Files**
```bash
# JS files (often contain endpoints, secrets)
site:target.com _next/static
site:target.com chunk.js
site:target.com app.js
site:target.com main.js
site:target.com bundle.js
site:target.com vendor.js
site:target.com webpack
```

**Category 3: Auth/Admin Pages**
```bash
# Authentication and admin interfaces
site:target.com admin
site:target.com login
site:target.com dashboard
site:target.com signin
site:target.com auth
site:target.com panel
site:target.com console
```

**Category 4: Environments**
```bash
# Non-production environments
site:target.com staging
site:target.com dev
site:target.com test
site:target.com beta
site:target.com internal
site:target.com uat
site:target.com qa
```

**Category 5: Config/Secrets**
```bash
# Configuration and sensitive files
site:target.com config
site:target.com token
site:target.com secret
site:target.com password
site:target.com .env
site:target.com credentials
site:target.com api_key
site:target.com apikey
```

**Category 6: File Types**
```bash
# Specific file types
site:target.com mime:pdf
site:target.com mime:doc
site:target.com mime:docx
site:target.com mime:xls
site:target.com mime:xlsx
site:target.com mime:json
site:target.com mime:xml
site:target.com mime:txt
site:target.com mime:log
```

**Category 7: Cloud Assets**
```bash
# Cloud storage and services
site:target.com firebase
site:target.com s3.amazonaws.com
site:target.com cloudfront.net
site:target.com blob.core.windows.net
site:target.com storage.googleapis.com
```

### Phase 4: Advanced Yandex Operators

**Basic Search Operators:**
- `!word` - Exact form (no synonyms/word forms)
- `+word` - Must contain this word
- `"exact phrase"` - Exact phrase match
- `"phrase * phrase"` - Missing word (one * = one word)
- `word1 | word2` - OR operator
- `(word1 | word2)` - Grouping
- `-unwanted` - Exclude word

**URL/Domain Operators:**
- `url:full_URL` - Specific page
- `url:hostname/folder/*` - Section search
- `site:domain` - All subdomains and pages
- `host:www.domain.tld` - Specific subdomain only
- `rhost:tld.domain.www` - Reverse hostname (supports wildcards)
- `domain:level` - Any domain level (edu, com, org, etc.)

**File Type Operator:**
- `mime:type` - Supported types:
  - doc, docx, html, odg, odp, ods, odt
  - pdf, ppt, pptx, rtf, swf
  - xls, xlsx

**Language Operator:**
- `lang:code` - Supported languages:
  - ru, uk, be, en, fr, de, kk, tt, tr

**Date Search (SUPERIOR TO GOOGLE):**
- `date:YYYYMMDD` - Exact date
- `date:YYYYMMDD..YYYYMMDD` - Date range
- `date:<YYYYMMDD` - Before date
- `date:>YYYYMMDD` - After date
- `date:YYYY**` - Partial date (year only)

**Examples:**
```bash
# Recent changes in last week
site:target.com date:>20260501

# Documents from specific date range
site:target.com mime:pdf date:20260101..20260131

# Recent API changes
site:target.com /api/ date:>20260401
```

**Title Search:**
- Use advanced form: https://suip.biz/ru/?act=yandex-search
- Or add `&zone=title` to URL

**Exact Word Form:**
- Quote each word OR edit URI: `wordforms=exact`

### Phase 5: Open Directory Hunting

**Classic Open Directory Dork:**
```bash
"Index of /" "Parent Directory"
```

**Targeted Open Directories:**
```bash
# Admin directories
"Index of /admin" "Parent Directory"
"Index of /backup" "Parent Directory"
"Index of /config" "Parent Directory"

# Mail directories
"Index of /mail" "Parent Directory"
"Index of /email" "Parent Directory"

# User data
"Index of /users" "Parent Directory"
"Index of /uploads" "Parent Directory"

# Source code
"Index of /src" "Parent Directory"
"Index of /source" "Parent Directory"

# Database dumps
"Index of /db" "Parent Directory"
"Index of /database" "Parent Directory"
"Index of /sql" "Parent Directory"

# SSH keys
"Index of /.ssh/" "Parent Directory"

# Git repositories
"Index of /.git/" "Parent Directory"
```

**Real Success Story (Entry #12):**
- Found private directory using Yandex dork
- Contained:
  - Private Documentation
  - Private Conversation
  - Private Contract
  - Private Data management
  - Access to each private user
- Quote: "Yandex dork never Fail"

### Phase 6: Automated Recon Loop

**Complete Bash Script (yadexloop.sh):**
```bash
#!/bin/bash

# Configuration
TARGET="target.com"
OUTPUT_DIR="yandex_recon_${TARGET}"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
SLEEP_TIME=5

# Create output directory structure
mkdir -p "${OUTPUT_DIR}"/{api,javascript,auth_admin,environments,files,documents,cloud}

echo "[+] Starting Yandex Recon Loop for: ${TARGET}"
echo "[+] Output directory: ${OUTPUT_DIR}"

# Function to perform Yandex search
yandex_search() {
  local query="$1"
  local output_file="$2"
  
  echo "[*] Searching: ${query}"
  
  curl -s -A "${USER_AGENT}" \
    "https://yandex.com/search?text=${query}" \
    | grep -oP '(?<=href=")[^"]*'"${TARGET}"'[^"]*' \
    | sort -u \
    >> "${output_file}"
  
  sleep ${SLEEP_TIME}
}

# API Endpoints
echo "[+] Searching for API endpoints..."
yandex_search "site:${TARGET} /api/" "${OUTPUT_DIR}/api/api_paths.txt"
yandex_search "site:${TARGET} graphql" "${OUTPUT_DIR}/api/graphql.txt"
yandex_search "site:${TARGET} swagger" "${OUTPUT_DIR}/api/swagger.txt"
yandex_search "site:${TARGET} openapi" "${OUTPUT_DIR}/api/openapi.txt"
yandex_search "site:${TARGET} redoc" "${OUTPUT_DIR}/api/redoc.txt"

# JavaScript Files
echo "[+] Searching for JavaScript files..."
yandex_search "site:${TARGET} _next/static" "${OUTPUT_DIR}/javascript/nextjs.txt"
yandex_search "site:${TARGET} chunk.js" "${OUTPUT_DIR}/javascript/chunks.txt"
yandex_search "site:${TARGET} app.js" "${OUTPUT_DIR}/javascript/app.txt"
yandex_search "site:${TARGET} main.js" "${OUTPUT_DIR}/javascript/main.txt"

# Auth/Admin
echo "[+] Searching for auth/admin pages..."
yandex_search "site:${TARGET} admin" "${OUTPUT_DIR}/auth_admin/admin.txt"
yandex_search "site:${TARGET} login" "${OUTPUT_DIR}/auth_admin/login.txt"
yandex_search "site:${TARGET} dashboard" "${OUTPUT_DIR}/auth_admin/dashboard.txt"
yandex_search "site:${TARGET} signin" "${OUTPUT_DIR}/auth_admin/signin.txt"

# Environments
echo "[+] Searching for non-production environments..."
yandex_search "site:${TARGET} staging" "${OUTPUT_DIR}/environments/staging.txt"
yandex_search "site:${TARGET} dev" "${OUTPUT_DIR}/environments/dev.txt"
yandex_search "site:${TARGET} test" "${OUTPUT_DIR}/environments/test.txt"
yandex_search "site:${TARGET} beta" "${OUTPUT_DIR}/environments/beta.txt"
yandex_search "site:${TARGET} internal" "${OUTPUT_DIR}/environments/internal.txt"

# Config/Secrets
echo "[+] Searching for config and secrets..."
yandex_search "site:${TARGET} config" "${OUTPUT_DIR}/files/config.txt"
yandex_search "site:${TARGET} token" "${OUTPUT_DIR}/files/token.txt"
yandex_search "site:${TARGET} secret" "${OUTPUT_DIR}/files/secret.txt"
yandex_search "site:${TARGET} password" "${OUTPUT_DIR}/files/password.txt"

# Documents
echo "[+] Searching for documents..."
yandex_search "site:${TARGET} mime:pdf" "${OUTPUT_DIR}/documents/pdf.txt"
yandex_search "site:${TARGET} mime:doc | mime:docx" "${OUTPUT_DIR}/documents/word.txt"
yandex_search "site:${TARGET} mime:xls | mime:xlsx" "${OUTPUT_DIR}/documents/excel.txt"

# Cloud Assets
echo "[+] Searching for cloud assets..."
yandex_search "site:${TARGET} firebase" "${OUTPUT_DIR}/cloud/firebase.txt"
yandex_search "site:${TARGET} s3.amazonaws.com" "${OUTPUT_DIR}/cloud/s3.txt"

# Deduplicate all results
echo "[+] Deduplicating results..."
find "${OUTPUT_DIR}" -type f -name "*.txt" -exec sort -u -o {} {} \;

# Generate summary
echo "[+] Generating summary..."
{
  echo "=== Yandex Recon Summary for ${TARGET} ==="
  echo "Date: $(date)"
  echo ""
  echo "API Endpoints: $(cat ${OUTPUT_DIR}/api/*.txt 2>/dev/null | wc -l)"
  echo "JavaScript Files: $(cat ${OUTPUT_DIR}/javascript/*.txt 2>/dev/null | wc -l)"
  echo "Auth/Admin Pages: $(cat ${OUTPUT_DIR}/auth_admin/*.txt 2>/dev/null | wc -l)"
  echo "Environments: $(cat ${OUTPUT_DIR}/environments/*.txt 2>/dev/null | wc -l)"
  echo "Config/Secret Files: $(cat ${OUTPUT_DIR}/files/*.txt 2>/dev/null | wc -l)"
  echo "Documents: $(cat ${OUTPUT_DIR}/documents/*.txt 2>/dev/null | wc -l)"
  echo "Cloud Assets: $(cat ${OUTPUT_DIR}/cloud/*.txt 2>/dev/null | wc -l)"
} | tee "${OUTPUT_DIR}/summary.txt"

echo "[+] Recon complete! Results saved to: ${OUTPUT_DIR}"
```

## Tools to Use

### Primary Tools
- **curl**: Automated Yandex searches
- **grep**: Extract URLs from results
- **sort/uniq**: Deduplicate findings
- **Bash scripts**: Automate recon loops

### Secondary Tools
- **waymore**: Crawl and extract URLs
- **Katana**: Web crawler
- **gospider**: Fast web spider
- **JSMiner**: JavaScript file analysis
- **metasecjs**: JS endpoint extraction

### Analysis Tools
- **ripgrep-all (rga)**: Search inside PDFs, docs, archives
- **jq**: Parse JSON responses
- **xmllint**: Parse XML responses

## Success Criteria

### Critical Findings
- Open directories with sensitive data
- Exposed .git directories
- SSH private keys
- Database dumps
- API keys in JavaScript files
- Admin panels on non-production environments

### High Findings
- Staging/dev environments with weak auth
- Exposed API documentation (Swagger, OpenAPI)
- Config files with credentials
- Backup files
- Source code exposure

### Medium Findings
- Information disclosure via documents
- Subdomain discovery
- Technology stack fingerprinting
- Old/forgotten endpoints

## Examples from Real Findings

### Example 1: Open Directory Discovery (Entry #12)
**Method:** Yandex dork
**Query:** `"Index of /" "Parent Directory" site:target.com`
**Result:** Found private directory containing:
- Private Documentation
- Private Conversations
- Private Contracts
- Private Data management
- Access to user data

**Key Lesson:** "Yandex dork is not Magic" - requires manual testing and validation

### Example 2: Subdomain Enumeration (Entry #13)
**Method:** Letter-by-letter brute-force via rhost operator
**Target:** kali.org
**Queries:**
- `rhost:org.kali.a*`
- `rhost:org.kali.b*`
- ... (continue through alphabet)

**Results Found:**
- builddd-amd64.kali.org
- eros.kali.org
- eos.kali.org
- iris.kali.org
- images.kali.org
- download.offensive-security.com
- forums.offensive-security.com
- support.offensive-security.com

**Advantage:** Found subdomains Google didn't know about

### Example 3: Date-Based Search (Entry #13)
**Method:** Yandex date operator (superior to Google)
**Query:** `site:target.com /api/ date:20260401..20260510`
**Result:** Found recent API changes and new endpoints
**Use Case:** Monitor for recent changes, new features, security updates

## Key Patterns to Look For

### High-Value Targets
- `/api/` paths (often less protected than UI)
- `_next/static/` (Next.js apps, may contain sensitive data)
- `swagger`, `openapi`, `redoc` (API documentation)
- `staging`, `dev`, `test` (non-production environments)
- `.env`, `config`, `credentials` (configuration files)
- `firebase`, `s3.amazonaws.com` (cloud storage)
- `Index of /` (open directories)

### Indicators of Sensitive Data
- `password`, `token`, `secret`, `api_key` in URLs
- `.git`, `.svn`, `.env` in paths
- `backup`, `old`, `temp` in filenames
- `admin`, `panel`, `console` in paths
- Date patterns in URLs (may indicate backups)

## Testing Checklist

- [ ] Perform subdomain enumeration (letter-by-letter)
- [ ] Search for API endpoints (/api/, graphql, swagger)
- [ ] Discover JavaScript files (_next/static, chunk.js, app.js)
- [ ] Find auth/admin pages (admin, login, dashboard)
- [ ] Locate non-production environments (staging, dev, test)
- [ ] Hunt for config/secret files (config, token, secret)
- [ ] Search for documents (PDF, DOC, XLS)
- [ ] Discover cloud assets (Firebase, S3)
- [ ] Find open directories ("Index of /")
- [ ] Search for SSH keys ("Index of /.ssh/")
- [ ] Use date-based searches for recent changes
- [ ] Combine operators for targeted searches
- [ ] Validate all findings manually
- [ ] Extract endpoints from JavaScript files
- [ ] Check for exposed .git directories
- [ ] Look for backup files
- [ ] Test discovered endpoints for vulnerabilities

## Comparison: Yandex vs Google

### Yandex Advantages
- Better Russian-language site coverage
- Superior date search functionality
- Finds more subdomains (in tested cases)
- Different indexing = different results
- Good for target site info/document search

### Google Advantages
- Better general dorking capabilities
- More flexible operators
- Larger index overall
- Better for international sites

### Best Practice
Use BOTH engines for comprehensive coverage:
1. Start with Yandex for unique findings
2. Cross-reference with Google
3. Combine results for complete picture

## Related Vulnerabilities
- Information Disclosure
- Open Directory Listing
- Exposed Configuration Files
- Exposed API Documentation
- Subdomain Takeover (if subdomains found)
- Exposed Source Code
- Exposed Credentials

## References
- Entry #004: Yandex Dork Recon Loop (Hidden Gems)
- Entry #012: Yandex Dork Success Story (Koupon/Shabosec)
- Entry #013: Advanced Yandex Search Guide (Comprehensive)
- Advanced search interface: https://suip.biz/ru/?act=yandex-search
- Hackware article: https://hackware.ru/?p=6045
