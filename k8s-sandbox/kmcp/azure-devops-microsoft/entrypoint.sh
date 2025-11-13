#!/bin/sh

# Read organization from environment variable or use first argument
ORG="${AZURE_DEVOPS_ORG:-${1}}"

if [ -z "$ORG" ]; then
  echo "Error: AZURE_DEVOPS_ORG environment variable or organization argument required"
  exit 1
fi

# Run the Microsoft Azure DevOps MCP server
# Uses envvar authentication which reads from ADO_MCP_AUTH_TOKEN
exec npx @azure-devops/mcp "$ORG" --authentication envvar
