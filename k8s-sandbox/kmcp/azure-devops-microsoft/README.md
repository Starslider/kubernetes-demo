# Microsoft Azure DevOps MCP Container

This directory contains a Dockerfile to containerize the official Microsoft Azure DevOps MCP server.

## Build

```bash
docker build -t your-registry/azure-devops-mcp:latest .
docker push your-registry/azure-devops-mcp:latest
```

## Environment Variables

- `AZURE_DEVOPS_ORG`: Your Azure DevOps organization name (required)
- `ADO_MCP_AUTH_TOKEN`: Personal Access Token for authentication (required)

## Usage

The container runs the Microsoft MCP server with `envvar` authentication type, which reads the PAT from the `ADO_MCP_AUTH_TOKEN` environment variable.
