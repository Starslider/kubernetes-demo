#!/bin/sh

# Read organization from environment variable or use first argument
ORG="${AZURE_DEVOPS_ORG:-${1}}"

if [ -z "$ORG" ]; then
  echo "Error: AZURE_DEVOPS_ORG environment variable or organization argument required"
  exit 1
fi

echo "Original ORG value: $ORG"

# Extract org name if full URL is provided
# Handles formats like:
# - https://dev.azure.com/myorg -> myorg
# - http://dev.azure.com/myorg -> myorg
# - myorg -> myorg
case "$ORG" in
  *dev.azure.com*)
    # Remove protocol and domain
    ORG=$(echo "$ORG" | sed 's|^https\?://dev\.azure\.com/||')
    # Remove trailing slash and any path after org name
    ORG=$(echo "$ORG" | cut -d'/' -f1)
    echo "Extracted organization name: $ORG"
    ;;
  *)
    echo "Using organization name as-is: $ORG"
    ;;
esac

echo "Starting Microsoft Azure DevOps MCP server for organization: $ORG"

# Run the Microsoft Azure DevOps MCP server
# Uses envvar authentication which reads from ADO_MCP_AUTH_TOKEN
# Note: The @azure-devops/mcp server runs in stdio mode, designed for local npx usage
# We need to keep it running, so we use tail -f to prevent exit
echo "Executing: npx @azure-devops/mcp $ORG --authentication envvar"
echo "ADO_MCP_AUTH_TOKEN is set: $(if [ -n "$ADO_MCP_AUTH_TOKEN" ]; then echo 'YES (length: '${#ADO_MCP_AUTH_TOKEN}')'; else echo 'NO'; fi)"
echo "Starting MCP server in background..."

npx @azure-devops/mcp "$ORG" --authentication envvar &
MCP_PID=$!

# Keep container alive
echo "MCP server started with PID $MCP_PID"
echo "Waiting for MCP server process..."
wait $MCP_PID
EXIT_CODE=$?
echo "MCP server exited with code: $EXIT_CODE"
exit $EXIT_CODE
