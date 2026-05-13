---
inclusion: auto
description: Cloud security standards covering bucket squatting, IAM misconfigurations, and multi-tenant vulnerabilities
keywords: cloud, aws, gcp, azure, bucket, s3, iam, multi-tenant, cloud-storage
---

# Cloud Security Standards

## Bucket Squatting: The Silent Attack

### What is Bucket Squatting?

**Definition**: Pre-registering cloud storage buckets with predictable names before the legitimate owner creates them.

**Affected Services**:
- AWS S3 (globally unique namespace)
- GCP Cloud Storage (globally unique namespace)
- Azure Blob Storage (globally unique namespace)

**Real-World Impact** (April 2026):
- **GeminiSquat** (CVE-2026-1727): Gemini Enterprise compromise
- **VertexSquat** (CVE-2026-2473): Vertex AI RCE via pickle files
- Cloud Run vulnerability
- All pre-auth, cross-tenant attacks

### Attack Conditions (All 3 Required)

1. **Bucket name is predictable**
   - Project names
   - Region identifiers
   - Date patterns
   - Environment names (dev, staging, prod)
   - Company naming conventions

2. **Bucket not yet provisioned**
   - Service hasn't created it yet
   - Expansion to new regions
   - New product launches
   - Migration periods

3. **Service doesn't verify ownership**
   - No account ID checks
   - No IAM validation before use
   - Trusts bucket existence = ownership

### Impact Categories

**1. Data Exfiltration**:
- Application logs containing sensitive data
- User data written to bucket
- Analytics data
- Backup data
- Debug information

**2. Supply Chain / Code Injection**:
- CI/CD artifacts
- Build outputs
- Deployment packages
- Container images
- Lambda/Cloud Function code

**3. Remote Code Execution**:
- Pickle files (Python serialization)
- Serialized objects
- Executable artifacts
- Configuration files with code

**4. Cross-Tenant Impact**:
- Platform-wide vulnerabilities
- Affects all customers of cloud provider
- Not just single organization

### Finding Methodology (5 Steps)

#### Step 1: Understand Naming Patterns

**Reconnaissance Techniques**:
- Analyze JavaScript files for bucket references
- Check API responses for storage URLs
- Use Wayback Machine CDX API
- Extract from documentation
- Analyze error messages

**Tools**:
- waymore (Wayback Machine scraper)
- Katana (web crawler)
- gospider (web spider)
- JSMiner (JavaScript analysis)
- metasecjs (JavaScript secrets)

**Common Patterns**:
```
company-env-region
projectname-assets-prod
appname-logs-us-east-1
orgname-backups-2026
service-uploads-staging
```

**Pattern Analysis**:
```bash
# Extract bucket names from JavaScript
rga "s3\.amazonaws\.com|storage\.googleapis\.com|blob\.core\.windows\.net" ./js_files/

# Analyze naming convention
# Example: acme-logs-us-east-1
# Pattern: {company}-{purpose}-{region}
```

#### Step 2: Map Provisioning Behavior

**Predict When Buckets Created**:
- New region launches
- New product releases
- Seasonal expansions
- Migration events
- Scaling events

**Expansion Moments**:
- Company announces new region support
- New service launch
- Infrastructure migration
- Compliance requirements (data residency)

**Tools**:
- cloud_enum (cloud asset enumeration)
- s3scanner (S3 bucket scanner)

**Monitoring**:
```bash
# Monitor for new regions
# If pattern is: company-logs-{region}
# Test: company-logs-eu-west-3 (when new region announced)
```

#### Step 3: Check Ownership (Not Just Existence)

**CRITICAL**: Bucket existence ≠ bucket ownership

**AWS S3 Testing**:
```bash
# Test if bucket exists and who owns it
aws s3 ls s3://predicted-bucket-name --no-sign-request

# Responses:
# NoSuchBucket = unclaimed (squatting window!)
# AccessDenied = exists, private, someone owns it
# Successful listing = public, check account ID
# Empty listing = possibly already squatted
```

**GCP Cloud Storage Testing**:
```bash
# Test bucket ownership
gsutil ls gs://predicted-bucket-name

# Responses:
# BucketNotFoundException = unclaimed
# AccessDeniedException = exists, owned
# Successful listing = public or you own it
```

**Azure Blob Testing**:
```bash
# Test container existence
az storage container exists --name predicted-container-name --account-name accountname

# Check public access
curl https://accountname.blob.core.windows.net/predicted-container-name?restype=container
```

**Ownership Verification**:
- Don't stop at "AccessDenied"
- Verify account ID if accessible
- Check creation date
- Verify IAM policies

#### Step 4: Confirm System Trusts Bucket

**Trigger Workflow**:
- Deploy application
- Run CI/CD pipeline
- Trigger backup process
- Upload file
- Generate report

**Observation Points**:
- Error messages (bucket references)
- HTTP headers (storage URLs)
- SDK logs (connection attempts)
- Network traffic (DNS queries)

**Validation**:
```bash
# Create bucket with predicted name
aws s3 mb s3://predicted-bucket-name

# Set up logging to capture writes
aws s3api put-bucket-logging --bucket predicted-bucket-name --bucket-logging-status file://logging.json

# Trigger target application workflow
# Monitor for writes to your bucket
aws s3 ls s3://predicted-bucket-name --recursive
```

#### Step 5: Define Impact Clearly

**Document What Gets Written**:
- User data (PII, credentials)
- Application logs (secrets, tokens)
- Build artifacts (source code)
- ML models (proprietary algorithms)
- Configuration files (infrastructure details)

**Build Impact Chain**:
```
1. Application writes logs to bucket
2. Logs contain user session tokens
3. Attacker reads logs from squatted bucket
4. Attacker uses tokens to impersonate users
5. Full account takeover
```

**Severity Assessment**:
- Data sensitivity
- Exploitability (pre-auth vs post-auth)
- Scope (single org vs cross-tenant)
- Reliability (always works vs race condition)

### Prevention Strategies

#### 1. Unpredictable Names

**Bad**:
```
companyname-logs
projectname-assets-prod
appname-backups-2026
```

**Good**:
```
companyname-logs-a3f9b1c7
projectname-assets-prod-8d2e4f1a
appname-backups-2026-c5b7d9e2
```

**Implementation**:
```python
import secrets

def generate_bucket_name(prefix):
    random_suffix = secrets.token_hex(4)  # 8 characters
    return f"{prefix}-{random_suffix}"

# Example: "acme-logs-a3f9b1c7"
```

#### 2. Pre-Provision All Buckets

**Strategy**: Create buckets during infrastructure deployment, not on-demand.

**Infrastructure as Code**:
```terraform
# Terraform example
resource "aws_s3_bucket" "logs" {
  bucket = "acme-logs-${random_id.bucket_suffix.hex}"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
```

**Benefits**:
- Controlled creation process
- No race condition
- Ownership guaranteed
- Auditable

#### 3. Verify Ownership Before Writing

**AWS S3 Example**:
```python
import boto3

def verify_bucket_ownership(bucket_name, expected_account_id):
    s3 = boto3.client('s3')
    
    try:
        # Get bucket owner
        response = s3.get_bucket_acl(Bucket=bucket_name)
        owner_id = response['Owner']['ID']
        
        # Verify owner matches expected account
        if owner_id != expected_account_id:
            raise SecurityError(f"Bucket owned by unexpected account: {owner_id}")
        
        return True
    except Exception as e:
        raise SecurityError(f"Cannot verify bucket ownership: {e}")

# Use before writing
verify_bucket_ownership("my-bucket", "123456789012")
s3.put_object(Bucket="my-bucket", Key="file.txt", Body=data)
```

**GCP Cloud Storage Example**:
```python
from google.cloud import storage

def verify_bucket_ownership(bucket_name, expected_project_id):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    
    try:
        bucket.reload()
        
        # Verify project ID
        if bucket.project_number != expected_project_id:
            raise SecurityError(f"Bucket in unexpected project")
        
        return True
    except Exception as e:
        raise SecurityError(f"Cannot verify bucket ownership: {e}")
```

#### 4. Lock Down CDK Bootstrapping (AWS)

**Problem**: AWS CDK uses predictable bootstrap bucket names.

**Default Pattern**:
```
cdk-{qualifier}-assets-{account}-{region}
```

**Solution**: Customize qualifier.

```bash
# Use custom qualifier instead of default
cdk bootstrap --qualifier custom8chars

# Results in:
# cdk-custom8chars-assets-{account}-{region}
```

**Additional Protection**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::cdk-*-assets-*",
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalAccount": "YOUR_ACCOUNT_ID"
        }
      }
    }
  ]
}
```

### Automation Checklist

**For Each Target**:
- [ ] Extract bucket naming patterns from JavaScript
- [ ] Extract bucket names from API responses
- [ ] Check Wayback Machine for historical bucket references
- [ ] Identify naming convention (company-purpose-region, etc.)
- [ ] Predict future bucket names based on pattern
- [ ] Test predicted names for existence
- [ ] Verify ownership (not just existence)
- [ ] Monitor for new regions/products
- [ ] Test if application trusts bucket
- [ ] Document what data gets written
- [ ] Build complete impact chain

**Tools Integration**:
```bash
# 1. Extract bucket names
rga "s3\.amazonaws\.com/([^/\"']+)" ./js_files/ -o > buckets.txt

# 2. Test existence
cat buckets.txt | while read bucket; do
    aws s3 ls s3://$bucket --no-sign-request 2>&1 | tee -a results.txt
done

# 3. Identify pattern
# Manual analysis of results.txt

# 4. Generate predictions
# Based on identified pattern

# 5. Test predictions
# Repeat step 2 with predicted names
```

## Multi-Tenant Vulnerabilities

### Cross-Tenant Data Access

**Definition**: Accessing data belonging to other tenants/customers in shared infrastructure.

**Common Causes**:
- Shared encryption keys
- Insufficient tenant isolation
- Missing tenant ID validation
- Predictable resource identifiers

### Salesforce Marketing Cloud Case Study (Entry #021)

**Vulnerabilities Found**:
1. Template injection (AMPScript/SSJS)
2. CBC padding oracle (unauthenticated encryption)
3. Ancient XOR "encryption" still active
4. Static shared keys across ALL instances

**Impact**:
- Read all emails stored in ANY SFMC instance
- Access all customer PII across ANY tenant
- Cross-tenant data access
- Unauthenticated access

**Key Lessons**:
- Never share encryption keys across tenants
- Never use unauthenticated encryption (CBC without HMAC)
- Never use XOR as encryption
- Disable legacy crypto formats
- Validate tenant boundaries on every operation

### Testing Multi-Tenant Systems

**Checklist**:
- [ ] Can I access other tenant's data by changing IDs?
- [ ] Are encryption keys shared across tenants?
- [ ] Can I enumerate other tenant identifiers?
- [ ] Are tenant boundaries enforced at database level?
- [ ] Can I trigger actions in other tenant's context?
- [ ] Are API keys/tokens scoped to single tenant?
- [ ] Can I see other tenant's metadata?
- [ ] Are file uploads isolated per tenant?
- [ ] Can I access other tenant's exports?
- [ ] Are background jobs properly scoped?

**Common Patterns**:
```
# Test tenant isolation
# User A (Tenant 1): /api/users/123
# User B (Tenant 2): /api/users/456

# Try accessing User B's data as User A
GET /api/users/456
# Should return 403/404, not User B's data

# Try changing tenant ID in token
# JWT payload: {"user_id": 123, "tenant_id": 1}
# Modify to: {"user_id": 123, "tenant_id": 2}
# Should be rejected
```

## IAM Misconfigurations

### Common Issues

**1. Overly Permissive Policies**:
```json
{
  "Effect": "Allow",
  "Action": "s3:*",
  "Resource": "*"
}
```

**2. Missing Condition Keys**:
```json
{
  "Effect": "Allow",
  "Action": "s3:PutObject",
  "Resource": "arn:aws:s3:::my-bucket/*"
  // Missing: Condition to verify account ownership
}
```

**3. Public Access**:
```json
{
  "Effect": "Allow",
  "Principal": "*",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/*"
}
```

### Testing IAM Policies

**Checklist**:
- [ ] Can unauthenticated users access resources?
- [ ] Can low-privilege users escalate privileges?
- [ ] Are condition keys properly enforced?
- [ ] Are resource ARNs specific (not wildcards)?
- [ ] Are actions minimally scoped?
- [ ] Are cross-account access controls in place?
- [ ] Are temporary credentials properly scoped?
- [ ] Are service roles minimally privileged?

**Tools**:
- AWS IAM Policy Simulator
- GCP Policy Analyzer
- Azure Policy Analyzer
- ScoutSuite (multi-cloud security auditing)
- Prowler (AWS security assessment)

## Cloud Recon Methodology

### Phase 1: Asset Discovery

```bash
# Subdomain enumeration
subfinder -d target.com | grep -E "s3|storage|blob|cloud" > cloud_subdomains.txt

# DNS enumeration for cloud patterns
cat subdomains.txt | grep -E "click\.|view\.|cloud\.|pages\.|images\." > cloud_assets.txt

# CNAME checking
cat subdomains.txt | while read sub; do
    dig $sub CNAME | grep -E "amazonaws|googleapis|azure"
done
```

### Phase 2: Bucket Enumeration

```bash
# Extract bucket names from JavaScript
rga "s3\.amazonaws\.com|storage\.googleapis\.com|blob\.core\.windows\.net" ./js_files/ > buckets.txt

# Test bucket existence
cat buckets.txt | while read bucket; do
    aws s3 ls s3://$bucket --no-sign-request 2>&1
done
```

### Phase 3: Permission Testing

```bash
# Test public read
aws s3 ls s3://target-bucket --no-sign-request

# Test public write (DANGEROUS - use test file only)
echo "test" > test.txt
aws s3 cp test.txt s3://target-bucket/test.txt --no-sign-request

# Test public delete (DANGEROUS - only on your test file)
aws s3 rm s3://target-bucket/test.txt --no-sign-request
```

### Phase 4: Content Analysis

```bash
# Download accessible files
aws s3 sync s3://target-bucket ./downloaded/ --no-sign-request

# Search for secrets
rga "api[_-]?key|password|secret|token" ./downloaded/

# Search for PII
rga "email|ssn|credit.?card|phone" ./downloaded/
```

## References

- Entry #006: Bucket Squatting: Cloud Attack (Medusa0xf)
- Entry #021: Salesforce Marketing Cloud (SFMC) Critical Vulnerabilities
- Entry #071: Cloud security patterns (if available)

## Key Takeaways

1. **Bucket squatting is silent** - No alerts, no anomalies
2. **Predictable names = vulnerability** - Always use random suffixes
3. **Existence ≠ Ownership** - Verify account ID before trusting
4. **Pre-provision buckets** - Don't create on-demand
5. **Never share keys across tenants** - Catastrophic impact
6. **Test tenant boundaries** - Cross-tenant access = critical
7. **IAM policies must be minimal** - Least privilege principle
8. **Monitor for new regions** - Expansion = new attack surface

## Tools Reference

**Reconnaissance**:
- waymore, Katana, gospider (crawling)
- JSMiner, metasecjs (JavaScript analysis)
- ripgrep-all (content search)

**Enumeration**:
- cloud_enum (multi-cloud enumeration)
- s3scanner (S3 bucket scanner)
- subfinder (subdomain enumeration)

**Testing**:
- AWS CLI (S3 testing)
- gsutil (GCP testing)
- az CLI (Azure testing)

**Analysis**:
- ScoutSuite (multi-cloud auditing)
- Prowler (AWS security)
- GCP Policy Analyzer
- Azure Policy Analyzer
