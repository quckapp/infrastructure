# =============================================================================
# QuckApp NGINX Reverse Proxy
# =============================================================================
# Routes traffic to all 33 microservices with rate limiting, WebSocket support,
# security headers, CORS, and SSL/TLS termination.
#
# Build: docker build -t quckapp-nginx .
# Run:   docker run -p 80:80 -p 443:443 --network quckapp-network quckapp-nginx
# =============================================================================

FROM nginx:1.25-alpine

# Install curl for healthchecks
RUN apk add --no-cache curl

# Remove default config
RUN rm -f /etc/nginx/conf.d/default.conf

# Create required directories
RUN mkdir -p /etc/nginx/ssl \
             /etc/nginx/conf.d \
             /var/cache/nginx/proxy_cache \
             /var/www/static \
             /tmp/positions

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY ssl/ /etc/nginx/ssl/

# Validate configuration
RUN nginx -t

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=15s --timeout=5s --retries=3 \
    CMD curl -sf http://localhost/health || exit 1

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
