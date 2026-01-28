# Multi-stage build for reveal.js presentation
FROM node:20-alpine AS builder

# Install reveal.js and markdown plugin
WORKDIR /slides
RUN npm init -y && \
    npm install reveal.js@5.0.4

# Copy markdown slides
COPY slides.md /slides/

# Create index.html
COPY index.html /slides/

# Production stage - serve with nginx
FROM nginx:1.25-alpine

# Copy reveal.js assets and slides from builder
COPY --from=builder /slides/node_modules/reveal.js/dist /usr/share/nginx/html/dist
COPY --from=builder /slides/node_modules/reveal.js/plugin /usr/share/nginx/html/plugin
COPY --from=builder /slides/slides.md /usr/share/nginx/html/
COPY --from=builder /slides/index.html /usr/share/nginx/html/

# Add nginx config for SPA routing
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    # Cache static assets \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|woff2|ttf|svg)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Modify existing nginx user and fix permissions for non-root operation
RUN deluser nginx && \
    adduser -D -u 1001 -g nginx nginx && \
    # Create necessary directories with proper permissions
    mkdir -p /var/run/nginx /var/lib/nginx /var/log/nginx /var/cache/nginx/client_temp && \
    chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/run/nginx /var/lib/nginx /var/log/nginx && \
    chmod -R 755 /var/run/nginx /var/lib/nginx /var/log/nginx /var/cache/nginx && \
    # Update nginx config to use port 8080 and non-privileged paths
    sed -i 's/listen 80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
    # Update main nginx.conf to write PID file in accessible location
    sed -i 's|pid /var/run/nginx.pid;|pid /var/run/nginx/nginx.pid;|' /etc/nginx/nginx.conf

# Switch to non-root user
USER 1001

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
