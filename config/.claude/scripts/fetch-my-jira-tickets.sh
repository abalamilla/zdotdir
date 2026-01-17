#!/bin/bash
# READ-ONLY: Fetch pending Jira tickets for the current user
# This script only performs GET requests - no write operations allowed

set -euo pipefail

# Validate environment variables
if [ -z "${JIRA_URL:-}" ] || [ -z "${JIRA_API_TOKEN:-}" ] || [ -z "${LLID_FQDA:-}" ]; then
    echo "Error: JIRA_URL, JIRA_API_TOKEN, and LLID_FQDA environment variables must be set" >&2
    exit 1
fi

JIRA_BASE="${JIRA_URL%/}"

# READ-ONLY GET request only
curl -s -X GET \
  -H "Authorization: Bearer ${JIRA_API_TOKEN}" \
  "${JIRA_BASE}/rest/api/2/search?jql=$(printf '%s' "\"Product Domain\" = Architecture AND (assignee = \"${LLID_FQDA}\" OR \"Engineer #2\" = \"${LLID_FQDA}\") AND status in (\"Prototype\", \"Prototype Review\", \"In Progress\", \"Needs QR\") ORDER BY updated DESC" | jq -sRr @uri)&fields=summary,status,description&maxResults=50"
