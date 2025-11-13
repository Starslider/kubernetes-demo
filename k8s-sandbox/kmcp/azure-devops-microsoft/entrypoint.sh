#!/bin/sh

# Read organization from environment variable or use first argument
ORG="${AZURE_DEVOPS_ORG:-${1}}"

if [ -z "$ORG" ]; then
  echo "Error: AZURE_DEVOPS_ORG environment variable or organization argument required"
  exit 1
fi

# Extract org name if full URL is provided
# Handles formats like:
# - https://dev.azure.com/myorg -> myorg
# - myorg -> myorg
if echo "$ORG" | grep -q "dev.azure.com"; then
  ORG=$(echo "$ORG" | sed 's|https\?://dev.azure.com/||' | sed 's|/.*||')
  echo "Extracted organization name: $ORG"
fi

echo "Starting Microsoft Azure DevOps MCP server for organization: $ORG"

# Run the Microsoft Azure DevOps MCP server
# Uses envvar authentication which reads from ADO_MCP_AUTH_TOKEN
# Note: The @azure-devops/mcp server runs in stdio mode, designed for local npx usage
# We need to keep it running, so we use tail -f to prevent exit
npx @azure-devops/mcp "$ORG" --authentication envvar &
MCP_PID=$!

# Keep container alive
echo "MCP server started with PID $MCP_PID"
wait $MCP_PID
