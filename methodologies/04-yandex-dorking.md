# Yandex Dorking Methodology

## Overview

Advanced Yandex search methodology for discovering hidden assets, forgotten endpoints, and sensitive information that other search engines miss. Proven technique for finding private directories, documentation, contracts, and user data.

**Success Metrics:**
- Found private directories with sensitive data
- Discovered 60+ unique subdomains per target
- Located forgotten API endpoints and documentation
- Better Russian-language site coverage than Google
- Superior date search functionality

**Sources:**
- Entry #004 - Yandex Dork Recon Loop
- Entry #012 - Yandex Dork Success Story
- Entry #013 - Advanced Yandex Search Guide

---

## Why Yandex?

### Advantages Over Google

1. **Better Russian-Language Coverage**
   - More indexed Russian sites
   - Better understanding of Cyrillic content
   - Different crawling patterns

2. **Superior Date Search**
   - Exact date: `date:YYYYMMDD`
   - Date range: `date:YYYYMMDD..YYYYMMDD`
   - Partial dates: `date:YYYY**`
   - Comparison operators: `<`, `<=`, `>`, `>=`

3. **Unique Subdomain Discovery**
   - Wildcard support in `rhost:` operator
   - Finds subdomains Google doesn't know
   - Letter-by-letter enumeration technique

4. **Different Index**
   - Knows different pages than Google
   - Catches forgotten/indexed assets
   - Complementary to Google dorking

### Limitations

- Less flexible for general dorking
- Poorer general dork capabilities than Google
- Best for target-specific searches
- Requires manual verification ("not magic")

---

## Core Operators

### Basic Search

**Automatic Features:**
- Word forms and synonyms
- Phrase search (multiple words)

**Exact Form Search:**
```
!word          # No synonyms/forms
+word          # Must contain
"exact phrase" # Exact quote
"phrase * phrase"  # Missing word (one * = one word)
```

**Logical Operators:**
```
word1 | word2              # OR
training (java | PHP)      # Grouping
phrase -unwanted           # Exclusion
```

### URL/Domain Operators

```
url:full_URL                    # Specific page
url:hostname/folder/*           # Section search
site:domain                     # All subdomains and pages
host:www.domain.tld             # Specific subdomain
rhost:tld.domain.www            # Reverse hostname (supports wildcards)
domain:level                    # Any domain level (edu, hackware, tools)
```

### File Type

```
mime:type                       # Supported types
mime:pdf | mime:doc | mime:docx # Multiple types
```

**Supported Types:**
- doc, docx, html, odg, odp, ods, odt
- pdf, ppt, pptx, rtf, swf
- xls, xlsx

### Language

```
lang:code                       # Language filter
```

**Supported Languages:**
- ru, uk, be, en, fr, de, kk, tt, tr

### Date Search (SUPERIOR TO GOOGLE)

```
date:YYYYMMDD                   # Exact date
date:YYYYMMDD..YYYYMMDD         # Date range
date:<YYYYMMDD                  # Before/after (<, <=, >, >=)
date:YYYY**                     # Partial date (year only)
```

**Examples:**
```
site:target.com date:20260610..20260710
"exact phrase" date:20260705..20260710
```

### Title Search

Use advanced form: https://suip.biz/ru/?act=yandex-search

Or add `&zone=title` to URL

### Exact Word Form

Quote each word OR edit URI: `wordforms=exact`

---

## Automated Recon Loop

### Script-Based Methodology

**Complete bash script (yadexloop.sh):**

```bash
#!/bin/bash

# Yandex Dork Recon Loop
# Automated asset discovery via Yandex search

TARGET="$1"
OUTPUT_DIR="yandex_results_${TARGET}"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target.com>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Dork categories
declare -A DORKS=(
    ["api"]="site:${TARGET} (/api/ | graphql | swagger | openapi | redoc)"
    ["javascript"]="site:${TARGET} (_next/static | chunk.js | app.js | main.js)"
    ["auth_admin"]="site:${TARGET} (admin | login | dashboard | signin)"
    ["environments"]="site:${TARGET} (staging | dev | test | beta | internal)"
    ["config_secrets"]="site:${TARGET} (config | token | secret | password)"
    ["files"]="site:${TARGET} (mime:json | mime:xml | mime:txt | mime:log | mime:pdf)"
    ["cloud"]="site:${TARGET} (firebase | s3.amazonaws.com)"
)

echo "[*] Starting Yandex Dork Recon for ${TARGET}"
echo "[*] Output directory: ${OUTPUT_DIR}"

for category in "${!DORKS[@]}"; do
    echo "[+] Searching: ${category}"
    
    dork="${DORKS[$category]}"
    output_file="${OUTPUT_DIR}/${category}.txt"
    
    # Yandex search URL
    search_url="https://yandex.com/search?text=$(echo "$dork" | jq -sRr @uri)"
    
    # Fetch results
    curl -s -A "$USER_AGENT" "$search_url" \
        | grep -oP 'href="https?://[^"]+' \
        | cut -d'"' -f2 \
        | grep "$TARGET" \
        | sort -u \
        > "$output_file"
    
    count=$(wc -l < "$output_file")
    echo "    Found: ${count} results"
    
    # Rate limiting
    sleep 5
done

echo "[*] Deduplicating results..."
cat "${OUTPUT_DIR}"/*.txt | sort -u > "${OUTPUT_DIR}/all_unique.txt"

total=$(wc -l < "${OUTPUT_DIR}/all_unique.txt")
echo "[*] Total unique URLs: ${total}"
echo "[*] Results saved to: ${OUTPUT_DIR}/"
```

### Dork Categories

#### 1. API Endpoints
```
site:target.com (/api/ | graphql | swagger | openapi | redoc)
```

**Finds:**
- REST API endpoints
- GraphQL endpoints
- API documentation
- OpenAPI specs

#### 2. JavaScript Files
```
site:target.com (_next/static | chunk.js | app.js | main.js)
```

**Finds:**
- Next.js static files
- Webpack chunks
- Main application bundles
- Source maps

#### 3. Auth/Admin Pages
```
site:target.com (admin | login | dashboard | signin)
```

**Finds:**
- Admin panels
- Login pages
- Dashboards
- Authentication endpoints

#### 4. Environments
```
site:target.com (staging | dev | test | beta | internal)
```

**Finds:**
- Staging servers
- Development environments
- Test instances
- Beta versions
- Internal tools

#### 5. Config/Secrets
```
site:target.com (config | token | secret | password)
```

**Finds:**
- Configuration files
- Token references
- Secret management pages
- Password reset flows

#### 6. File Types
```
site:target.com (mime:json | mime:xml | mime:txt | mime:log | mime:pdf)
```

**Finds:**
- JSON data files
- XML configurations
- Text documents
- Log files
- PDF documents

#### 7. Cloud Assets
```
site:target.com (firebase | s3.amazonaws.com)
```

**Finds:**
- Firebase instances
- S3 buckets
- Cloud storage references

---

## Advanced Techniques

### Subdomain Brute-Force by Letter

**Technique:** Use wildcard in `rhost:` operator to enumerate subdomains

**Methodology:**
```
rhost:com.target.a*
rhost:com.target.b*
rhost:com.target.c*
...
rhost:com.target.z*
```

**Advantages:**
- Finds subdomains Google doesn't know
- Can compete with dictionary brute-force
- Discovers forgotten subdomains

**Example Results (kali.org):**
```
builddd-amd64.kali.org
eros.kali.org
eos.kali.org
iris.kali.org
images.kali.org
download.offensive-security.com
forums.offensive-security.com
support.offensive-security.com
```

**Automation Script:**
```bash
#!/bin/bash

TARGET="$1"
OUTPUT="subdomains_${TARGET}.txt"

echo "[*] Enumerating subdomains for ${TARGET}"

for letter in {a..z} {0..9}; do
    echo "[+] Searching: ${letter}*"
    
    # Reverse hostname format
    reversed=$(echo "$TARGET" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s",$i,(i>1?".":"")}')
    
    dork="rhost:${reversed}.${letter}*"
    search_url="https://yandex.com/search?text=$(echo "$dork" | jq -sRr @uri)"
    
    curl -s -A "Mozilla/5.0" "$search_url" \
        | grep -oP 'https?://[a-zA-Z0-9.-]+\.'"$TARGET" \
        | sed 's|https\?://||' \
        | cut -d'/' -f1 \
        | sort -u \
        >> "$OUTPUT"
    
    sleep 3
done

# Deduplicate
sort -u "$OUTPUT" -o "$OUTPUT"

count=$(wc -l < "$OUTPUT")
echo "[*] Found ${count} unique subdomains"
echo "[*] Saved to: ${OUTPUT}"
```

### Open Directory Listing

**Basic Dork:**
```
"Index of /" "Parent Directory"
```

**Specific Folders:**
```
"Index of /admin" "Parent Directory"
"Index of /mail" "Parent Directory"
"Index of /backup" "Parent Directory"
"Index of /config" "Parent Directory"
```

**Target-Specific:**
```
site:target.com "Index of /" "Parent Directory"
```

**Finds:**
- Password files
- User data
- Archives
- Configuration files
- Source code

### SSH Keys

```
"Index of /.ssh/"
site:target.com "Index of /.ssh/"
```

**Finds:**
- Private keys
- Public keys
- Authorized keys
- Known hosts

### Admin/Auth Pages (Russian)

```
"Вход" url:."ru/admin"
"Вход" url:."ru/login"
```

**Finds:**
- Russian admin panels
- Login pages
- Authentication endpoints

---

## Workflow: Recon → Filter → Validate → Repeat

### Phase 1: Recon
```bash
# Run automated dork loop
./yadexloop.sh target.com

# Run subdomain enumeration
./yandex_subdomains.sh target.com

# Manual targeted dorks
# (Use advanced search form)
```

### Phase 2: Filter
```bash
# Categorize results
cat yandex_results_target.com/all_unique.txt | grep "/api/" > api_endpoints.txt
cat yandex_results_target.com/all_unique.txt | grep "\.js$" > javascript_files.txt
cat yandex_results_target.com/all_unique.txt | grep "admin\|login" > auth_pages.txt

# Remove false positives
# Manual review of each category
```

### Phase 3: Validate
```bash
# Check if URLs are live
while read url; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$status" != "404" ]; then
        echo "$url - $status"
    fi
done < api_endpoints.txt

# Test for open directories
while read url; do
    if curl -s "$url" | grep -q "Index of"; then
        echo "[!] Open directory: $url"
    fi
done < all_unique.txt
```

### Phase 4: Repeat
```
# Pivot on findings
# If found staging.target.com:
site:staging.target.com

# If found API endpoints:
site:target.com /api/v2/

# If found specific file types:
site:target.com mime:json date:2026****
```

---

## Success Story Example

**Target:** Undisclosed company
**Method:** Yandex dorking + source code analysis

**Found:**
- Private directory
- Private documentation
- Private conversation logs
- Private contracts
- Private data management system
- Access to each private user

**Quote:** "Yandex dork never Fail"

**Methodology:**
1. Input target in dork
2. Look into source code and JavaScript
3. Test stuff manually
4. If open directory found = "your luck"

**Key Insight:** "Yandex dork is not a Magic" - requires manual testing

---

## Integration with Other Tools

### Combine with JavaScript Analysis
```bash
# Download all JS files found
cat javascript_files.txt | while read url; do
    wget -q "$url" -P js_files/
done

# Extract endpoints from JS
grep -roh "https://[^\"']*" js_files/ | sort -u > extracted_endpoints.txt

# Search extracted endpoints on Yandex
cat extracted_endpoints.txt | while read endpoint; do
    # Yandex search for endpoint
    echo "Searching: $endpoint"
done
```

### Combine with Wayback Machine
```bash
# Get Wayback URLs
curl -s "http://web.archive.org/cdx/search/cdx?url=*.target.com/*&output=txt&fl=original&collapse=urlkey" \
    | sort -u > wayback_urls.txt

# Cross-reference with Yandex results
comm -12 <(sort yandex_results.txt) <(sort wayback_urls.txt) > common_urls.txt
```

### Combine with Subdomain Tools
```bash
# Run subfinder
subfinder -d target.com -o subfinder_results.txt

# Run Yandex subdomain enum
./yandex_subdomains.sh target.com

# Combine and deduplicate
cat subfinder_results.txt yandex_subdomains_target.com.txt | sort -u > all_subdomains.txt
```

---

## Testing Checklist

### Initial Recon
- [ ] Run automated dork loop for all categories
- [ ] Enumerate subdomains letter-by-letter
- [ ] Search for open directories
- [ ] Look for SSH keys
- [ ] Find admin/auth pages
- [ ] Search for specific file types
- [ ] Check for cloud assets

### JavaScript Analysis
- [ ] Download all JS files found
- [ ] Extract API endpoints from JS
- [ ] Search for hardcoded secrets
- [ ] Find internal URLs
- [ ] Identify API versions

### Date-Based Searches
- [ ] Search for recent changes (last 30 days)
- [ ] Find old forgotten pages (>1 year)
- [ ] Identify deployment dates
- [ ] Track content updates

### Validation
- [ ] Verify all URLs are live
- [ ] Test for open directories
- [ ] Check for sensitive data exposure
- [ ] Validate subdomain ownership
- [ ] Test discovered endpoints

### Pivoting
- [ ] Search discovered subdomains
- [ ] Explore found API versions
- [ ] Investigate related domains
- [ ] Follow internal links

---

## Tools and Resources

### Essential Tools
- **curl:** HTTP requests
- **jq:** JSON processing
- **grep:** Pattern matching
- **sort/uniq:** Deduplication

### Advanced Search Interface
https://suip.biz/ru/?act=yandex-search

### Yandex Search
https://yandex.com/search

### Complementary Tools
- subfinder: Subdomain enumeration
- waybackurls: Historical URLs
- gau: Get All URLs
- hakrawler: Web crawler

---

## Rate Limiting and Stealth

### Rate Limiting
```bash
# Sleep between requests
sleep 5

# Random delays
sleep $((3 + RANDOM % 5))

# Respect robots.txt
# (Yandex respects it)
```

### User-Agent Rotation
```bash
USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
)

# Random UA
UA="${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}"
curl -A "$UA" "$url"
```

### Proxy Rotation
```bash
# Use proxy list
while read proxy; do
    curl -x "$proxy" "$url"
    sleep 2
done < proxies.txt
```

---

## Real-World Examples

### Example 1: 60+ Subdomains
**Target:** kali.org
**Method:** Letter-by-letter rhost enumeration
**Results:** Found subdomains Google didn't know

### Example 2: Private Directory
**Target:** Undisclosed company
**Method:** Open directory dork + manual testing
**Results:** Private docs, contracts, user data

### Example 3: Forgotten API
**Target:** Major SaaS platform
**Method:** Date-based search + API dorks
**Results:** Old API version with vulnerabilities

---

## Key Takeaways

1. **Yandex complements Google** - different index, different results
2. **Superior date search** - exact dates, ranges, comparisons
3. **Unique subdomain discovery** - wildcard rhost operator
4. **Automated loops work** - script-based recon is efficient
5. **Manual verification required** - "not magic", needs testing
6. **Rate limiting essential** - sleep between requests
7. **Combine with other tools** - JS analysis, Wayback, subfinder
8. **Persistence pays off** - systematic approach finds hidden gems

---

## Related Methodologies

- **Multi-Agent Orchestration** (Entry #011): Automate Yandex dorking with agents
- **AI Agent Self-Validation** (Entry #005, #039): Validate findings before reporting
- **MCP Security Audit** (Entry #047): Use mcp-recon for orchestration

---

**Yandex dorking is a powerful complement to Google dorking for discovering hidden assets.**
