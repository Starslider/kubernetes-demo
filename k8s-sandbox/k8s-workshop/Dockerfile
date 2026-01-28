# Multi-stage build for reveal.js presentation
FROM node:20-alpine AS builder

# Install reveal.js and markdown plugin
WORKDIR /slides
RUN npm init -y && \
    npm install reveal.js@5.0.4

# Copy markdown slides (English and German)
COPY slides.md /slides/
COPY slides-de.md /slides/
COPY ai-slides.md /slides/
COPY ai-slides-de.md /slides/

# Copy HTML files and nginx config
COPY landing.html /slides/
COPY k8s-workshop.html /slides/
COPY ai-workshop.html /slides/
COPY nginx.conf /slides/

# Production stage - serve with nginx
FROM nginx:1.25-alpine

# Copy reveal.js assets and slides from builder
COPY --from=builder /slides/node_modules/reveal.js/dist /usr/share/nginx/html/dist
COPY --from=builder /slides/node_modules/reveal.js/plugin /usr/share/nginx/html/plugin
COPY --from=builder /slides/slides.md /usr/share/nginx/html/
COPY --from=builder /slides/slides-de.md /usr/share/nginx/html/
COPY --from=builder /slides/ai-slides.md /usr/share/nginx/html/
COPY --from=builder /slides/ai-slides-de.md /usr/share/nginx/html/
COPY --from=builder /slides/landing.html /usr/share/nginx/html/
COPY --from=builder /slides/k8s-workshop.html /usr/share/nginx/html/
COPY --from=builder /slides/ai-workshop.html /usr/share/nginx/html/

# Copy custom nginx config for non-root operation
COPY --from=builder /slides/nginx.conf /etc/nginx/nginx.conf

# Setup non-root user and permissions
RUN deluser nginx && \
    adduser -D -u 1001 -g nginx nginx && \
    # Create temp directories for nginx in /tmp (writable by non-root)
    mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp && \
    chown -R nginx:nginx /usr/share/nginx/html /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp && \
    # Remove default configs
    rm -f /etc/nginx/conf.d/*.conf

# Switch to non-root user
USER 1001

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
