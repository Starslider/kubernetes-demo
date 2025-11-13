FROM node:20-alpine

# Install npx and the Microsoft Azure DevOps MCP package
RUN npm install -g @azure-devops/mcp

# Set working directory
WORKDIR /app

# The MCP server expects the organization as an argument
# We'll use an entrypoint script to handle this
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
