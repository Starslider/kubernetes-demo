# Azure DevOps MCP Server (Jordiag .NET Implementation)

This directory contains the Docker configuration to build the Jordiag Azure DevOps MCP server.

## Build

The GitHub Actions workflow automatically builds and publishes this image to:
`ghcr.io/starslider/kubernetes-demo/azure-devops-mcp-jordiag:latest`

## Environment Variables

Required:
- `AZURE_DEVOPS_ORG_URL`: Full organization URL (e.g., https://dev.azure.com/myorg)
- `AZURE_DEVOPS_SEARCH_ORG_URL`: Search organization URL (e.g., https://almsearch.dev.azure.com/myorg/)
- `AZURE_DEVOPS_PAT`: Personal Access Token
- `AZURE_DEVOPS_PROJECT_NAME`: Default project name

Optional:
- `MCP_McpServer__Port`: Server port (default: 5050)
- `MCP_McpServer__LogLevel`: Log level (default: Information)
- `MCP_McpServer__EnableOpenTelemetry`: Enable telemetry (default: true)

## Features

- HTTP server with SSE (Server-Sent Events) transport
- Compatible with MCP protocol
- Comprehensive Azure DevOps coverage:
  - Boards (work items, iterations, queries)
  - Repos (pull requests, branches, commits)
  - Pipelines (builds, runs, definitions)
  - Artifacts (feeds, packages)
  - Test Plans
  - Wiki
  - Search
