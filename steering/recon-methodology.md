---
inclusion: auto
description: Systematic reconnaissance methodology using Yandex dorking, advanced search operators, and automated discovery techniques
keywords: recon, reconnaissance, dorking, yandex, discovery, enumeration, osint
---

# Reconnaissance Methodology

## Philosophy: Systematic Discovery Over Random Scanning

**Core Principle**: Loop-based approach (Recon → Filter → Validate → Repeat)

**Goal**: Find assets other search engines miss:
- Old routes, forgotten API paths
- JavaScript files, documentation
- Staging references, GraphQL endpoints  
- Exposed static assets
- Open directories
- Configuration files

## Yandex Dorking: The Hidden Gem

### Why Yandex?

**Advantages over Google**:
- Better Russian-language site coverage
- Superior date search functionality
- Knows more subdomains (in tested cases)
- Different indexing patterns
- Finds assets Google doesn't know about

**Limitations**:
- Less flexible for general dorking
- Poorer general dork capabilities than Google
- Best for target-specific searches

**Strategy**: Use BOTH Google and Yandex in parallel for comprehensive coverage.

### Yandex Search Operators

#### Basic Search

```
word                    # Automatic word forms, synonyms
"exact phrase"          # Exact phrase match
!word                   # Exact form (no synonyms/forms)
+word                   # Must contain (important word)
"phrase * phrase"       # Missing word (* = one word)
word1 | word2           # Alternatives (OR)
training (java | PHP)   # Grouping
phrase -unwanted        # Exclusion
```

#### URL/Domain Operators

```
url:full_URL                    # Specific page
url:hostname/folder/*           # Section search
site:domain                     # All subdomains and pages
host:www.domain.tld             # Specific subdomain
rhost:tld.domain.www            # Reverse hostname (supports wildcards)
domain:level                    # Any domain level (edu, tools, etc.)
```

#### File Type

```
mime:pdf                        # PDF files
mime:doc | mime:docx            # Word documents
mime:xls | mime:xlsx            # Excel files
```

**Supported types**: doc, docx, html, odg, odp, ods, odt, pdf, ppt, pptx, rtf, swf, xls, xlsx

#### Language

```
lang:en                         # English
lang:ru                         # Russian
```

**Supported**: ru, uk, be, en, fr, de, kk, tt, tr

#### Date Search (SUPERIOR TO GOOGLE)

```
date:YYYYMMDD                   # Exact date
date:YYYYMMDD..YYYYMMDD         # Date range
date:<YYYYMMDD                  # Before/after (<, <=, >, >=)
date:YYYY**                     # Partial date (year only)
```

**Examples**:
```
site:target.com date:20260101..20260531
"API key" site:target.com date:>20260401
```

#### Title Search

Use advanced form: https://suip.biz/ru/?act=yandex-search

Or add `&zone=title` to URL

### Yandex Dorks for Bug Bounty

#### 1. Subdomain Enumeration (Letter-by-Letter)

**Technique**: Brute-force subdomains by first letter using wildcards.

```
rhost:com.target.a*
rhost:com.target.b*
rhost:com.target.c*
...
rhost:com.target.z*
```

**Advantages**:
- Finds subdomains Google doesn't know
- Can compete with dictionary brute-force
- Discovers forgotten/legacy subdomains

**Example Results** (from kali.org):
```
builddd-amd64.kali.org
eros.kali.org
eos.kali.org
iris.kali.org
images.kali.org
```

**Automation**: Script this to iterate through alphabet automatically.

#### 2. Open Directory Listing

```
site:target.com "Index of /" "Parent Directory"
```

**Specific folders**:
```
site:target.com "Index of /admin" "Parent Directory"
site:target.com "Index of /mail" "Parent Directory"
site:target.com "Index of /backup" "Parent Directory"
site:target.com "Index of /config" "Parent Directory"
site:target.com "Index of /uploads" "Parent Directory"
```

**What to find**:
- Password files
- User data
- Archives
- Configuration files
- Database dumps

#### 3. Admin/Auth Pages

```
site:target.com url:*/admin
site:target.com url:*/login
site:target.com url:*/dashboard
site:target.com url:*/signin
```

#### 4. SSH Keys

```
site:target.com "Index of /.ssh/"
```

#### 5. API Endpoints

```
site:target.com url:*/api/*
site:target.com url:*/graphql
site:target.com url:*/swagger
site:target.com url:*/openapi
site:target.com url:*/redoc
```

#### 6. JavaScript Files

```
site:target.com url:*/_next/static/*
site:target.com url:*/chunk.js
site:target.com url:*/app.js
site:target.com url:*/main.js
site:target.com url:*/bundle.js
```

#### 7. Environments

```
site:target.com url:*/staging/*
site:target.com url:*/dev/*
site:target.com url:*/test/*
site:target.com url:*/beta/*
site:target.com url:*/internal/*
```

#### 8. Config/Secrets

```
site:target.com mime:txt "password"
site:target.com mime:txt "api_key"
site:target.com mime:txt "secret"
site:target.com mime:txt "token"
site:target.com url:*/config.*
```

#### 9. Cloud Assets

```
site:target.com url:*firebase*
site:target.com url:*s3.amazonaws.com*
site:target.com url:*storage.googleapis.com*
site:target.com url:*blob.core.windows.net*
```

#### 10. Recent Changes

```
site:target.com date:>20260401
site:target.com "api" date:20260501..20260531
```

## Automated Yandex Recon Loop

### The yadexloop.sh Script Pattern

**Concept**: Automated dork categories with result bucketing.

**Categories**:
1. API endpoints
2. JavaScript files
3. Auth/Admin pages
4. Environments
5. Config/Secrets
6. File types
7. Cloud assets

**Features**:
- Auto-categorizes results into separate files
- Rate limiting (sleep between requests)
- Deduplication
- User-Agent spoofing
- Progress tracking

**Output Structure**:
```
results/
├── api.txt
├── javascript.txt
├── auth_admin.txt
├── environments.txt
├── config.txt
├── files.txt
└── cloud.txt
```

**Implementation Pattern**:
```bash
#!/bin/bash

TARGET="$1"
OUTPUT_DIR="results_${TARGET}"
mkdir -p "$OUTPUT_DIR"

# API Endpoints
echo "[*] Searching for API endpoints..."
curl -s "https://yandex.com/search/?text=site:${TARGET}+url:*/api/*" \
    -H "User-Agent: Mozilla/5.0..." \
    | grep -oP 'https?://[^"]+' \
    | sort -u \
    > "${OUTPUT_DIR}/api.txt"
sleep 5

# JavaScript Files
echo "[*] Searching for JavaScript files..."
curl -s "https://yandex.com/search/?text=site:${TARGET}+url:*.js" \
    -H "User-Agent: Mozilla/5.0..." \
    | grep -oP 'https?://[^"]+\.js' \
    | sort -u \
    > "${OUTPUT_DIR}/javascript.txt"
sleep 5

# Continue for other categories...
```

## Advanced File Search: ripgrep-all (rga)

### Why rga?

**Standard grep limitations**:
- Only searches plain text files
- Can't search inside archives
- Can't extract text from PDFs/Office docs
- Can't search databases

**rga capabilities**:
- PDF text extraction
- Office documents (DOCX, ODT, XLSX)
- E-Books (EPUB)
- SQLite databases
- Archives (zip, tar.gz) - recursively
- Video subtitles (mkv, mp4)
- Image metadata (jpg)

### Installation

```bash
# Arch Linux
pacman -S ripgrep-all

# Debian/Ubuntu
apt install ripgrep pandoc poppler-utils ffmpeg

# macOS
brew install rga pandoc poppler ffmpeg

# From source
cargo install --locked ripgrep_all
```

### Usage Examples

```bash
# Search for API keys in all file types
rga "api[_-]?key" /path/to/target

# Search in PDFs only
rga --rga-adapters=poppler "password" ./documents/

# Search in archives recursively
rga "secret" ./downloads/*.zip

# Search SQLite databases
rga "user@email.com" ./app.db

# Search with context
rga -C 3 "token" ./target/

# Disable cache (for fresh results)
rga --rga-no-cache "pattern" ./
```

### Bug Bounty Use Cases

1. **Leaked Document Analysis**:
   ```bash
   rga "password|secret|key|token" ./leaked_docs/
   ```

2. **JavaScript Analysis**:
   ```bash
   rga "api\..*\.com" ./js_files/
   ```

3. **Archive Hunting**:
   ```bash
   rga "internal|staging|dev" ./target_archives/
   ```

4. **Database Extraction**:
   ```bash
   rga "admin@" ./databases/*.db
   ```

5. **PDF Documentation**:
   ```bash
   rga "endpoint|route|api" ./docs/*.pdf
   ```

## Recon Workflow: Complete Pipeline

### Phase 1: Initial Discovery

```bash
# 1. Subdomain enumeration (Yandex)
for letter in {a..z}; do
    # Search: rhost:com.target.$letter*
    # Save results
    sleep 5
done

# 2. Subdomain enumeration (traditional tools)
subfinder -d target.com -o subdomains.txt
amass enum -d target.com -o amass_subs.txt

# 3. Combine and deduplicate
cat subdomains.txt amass_subs.txt yandex_subs.txt | sort -u > all_subs.txt

# 4. Verify live hosts
httpx -l all_subs.txt -o live_hosts.txt
```

### Phase 2: Content Discovery

```bash
# 1. Yandex dorking (automated)
./yadexloop.sh target.com

# 2. JavaScript file discovery
cat results_target.com/javascript.txt | httpx -mc 200 -o js_files.txt

# 3. Download JavaScript files
cat js_files.txt | xargs -I {} wget {}

# 4. Extract endpoints from JavaScript
rga -oP "https?://[^\"']+" ./js_files/ | sort -u > extracted_urls.txt

# 5. Extract API patterns
rga "/api/[^\"']*" ./js_files/ | sort -u > api_endpoints.txt
```

### Phase 3: Deep Analysis

```bash
# 1. Check for open directories
cat extracted_urls.txt | grep -i "index of" > open_dirs.txt

# 2. Search for secrets in all files
rga "api[_-]?key|password|secret|token" ./downloaded_content/ > secrets.txt

# 3. Find configuration files
rga "config|\.env|settings" ./downloaded_content/ > configs.txt

# 4. Identify staging/dev environments
cat all_subs.txt | grep -iE "staging|dev|test|beta|internal" > staging_envs.txt
```

### Phase 4: Validation

```bash
# 1. Test open directories
cat open_dirs.txt | httpx -mc 200 -td -o validated_open_dirs.txt

# 2. Test API endpoints
cat api_endpoints.txt | httpx -mc 200,401,403 -o validated_apis.txt

# 3. Test for authentication
cat validated_apis.txt | while read url; do
    curl -s -o /dev/null -w "%{http_code} $url\n" "$url"
done > api_auth_status.txt
```

### Phase 5: Continuous Monitoring

```bash
# 1. Monitor for new subdomains (daily)
# Re-run Yandex subdomain enumeration
# Compare with previous results

# 2. Monitor for new content (weekly)
# Re-run Yandex dorking
# Diff with previous results

# 3. Monitor for recent changes
# Use date:>YYYYMMDD in Yandex
# Focus on newly indexed content
```

## AI/MCP/Agentic Systems Wordlist

### Modern Attack Surface

**Traditional wordlists miss**:
- MCP routes
- Agent endpoints
- LLM APIs
- Vector databases
- Sensitive config paths

**Resource**: https://github.com/sabir789/api-wordlist

**Categories**:
```
/mcp/*
/agent/*
/llm/*
/ai/*
/vector/*
/embeddings/*
/chat/*
/completion/*
/inference/*
```

**Integration**:
```bash
# Use with ffuf
ffuf -u https://target.com/FUZZ -w api-wordlist.txt

# Use with dirsearch
dirsearch -u https://target.com -w api-wordlist.txt

# Use with feroxbuster
feroxbuster -u https://target.com -w api-wordlist.txt
```

## Recon Automation Checklist

### For Each New Target

- [ ] Yandex subdomain enumeration (letter-by-letter)
- [ ] Traditional subdomain enumeration (subfinder, amass)
- [ ] Verify live hosts (httpx)
- [ ] Yandex dorking (all categories)
- [ ] JavaScript file discovery and download
- [ ] Endpoint extraction from JavaScript (rga)
- [ ] Open directory detection
- [ ] Secret scanning (rga)
- [ ] Configuration file discovery
- [ ] Staging/dev environment identification
- [ ] API endpoint validation
- [ ] Authentication status checking
- [ ] Cloud asset discovery
- [ ] Recent changes monitoring (Yandex date search)

### Continuous Monitoring

- [ ] Daily: New subdomain check
- [ ] Weekly: Content discovery re-run
- [ ] Weekly: Recent changes check (Yandex date search)
- [ ] Monthly: Full recon pipeline re-run
- [ ] On-demand: After major target updates/releases

## Tools Integration

### Required Tools

**Search & Discovery**:
- Yandex (manual + automated)
- Google (parallel searches)
- subfinder
- amass
- httpx

**Content Analysis**:
- ripgrep-all (rga)
- waymore
- Katana
- gospider
- JSMiner
- metasecjs

**Validation**:
- curl
- httpx
- ffuf
- dirsearch
- feroxbuster

### Tool Chain Example

```bash
# 1. Discover subdomains
subfinder -d target.com | httpx -silent | tee subs.txt

# 2. Crawl for JavaScript
cat subs.txt | katana -jc -o js_urls.txt

# 3. Download JavaScript
cat js_urls.txt | xargs -P 10 -I {} wget -q {}

# 4. Extract secrets
rga "api[_-]?key|password|secret" ./ > secrets.txt

# 5. Extract endpoints
rga -oP "/api/[^\"']*" ./ | sort -u > endpoints.txt

# 6. Fuzz endpoints
cat endpoints.txt | while read endpoint; do
    ffuf -u "https://target.com${endpoint}" -w wordlist.txt
done
```

## Success Stories

### Real-World Example (Entry #012)

**Finding**: Private directory via Yandex dork

**Impact**:
- Private Documentation
- Private Conversation
- Private Contract
- Private Data management
- Access to each private user

**Method**:
1. Input target in Yandex dork
2. Look into source code and JavaScript
3. Test discovered endpoints
4. Open Directory found = jackpot

**Quote**: "Yandex dork never Fail" - but requires manual testing, not magic.

## Key Principles

1. **Systematic over Random**: Follow repeatable pipeline, don't just run random dorks
2. **Multiple Sources**: Use Yandex AND Google AND traditional tools
3. **Automation**: Script repetitive tasks, focus human effort on validation
4. **Validation**: Always verify findings, don't trust search results blindly
5. **Continuous**: Recon is ongoing, not one-time
6. **Deep Analysis**: Don't stop at URLs, analyze content with rga
7. **Modern Targets**: Use AI/MCP-specific wordlists for modern apps

## References

- Entry #004: Yandex Dork Recon Loop (Hidden Gems)
- Entry #012: Yandex Dork Success Story (Koupon/Shabosec)
- Entry #013: Advanced Yandex Search Guide (Comprehensive)
- Entry #019: ripgrep-all (rga): Advanced File Search Tool
- Entry #030: RedAI (AI-Driven Vuln Discovery with Live Validation)

## Resources

- Yandex Advanced Search: https://suip.biz/ru/?act=yandex-search
- Yandex Guide: https://hackware.ru/?p=6045
- ripgrep-all: https://github.com/phiresky/ripgrep-all
- AI/MCP Wordlist: https://github.com/sabir789/api-wordlist
