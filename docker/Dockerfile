# Minimal static web image for the optional containerised delivery path.
#
# nginx:alpine keeps the image around 10 MB, which matters because it is pulled
# on every instance launch during a self-healing event - a large image would add
# directly to recovery time.
FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="autoheal-web" \
      org.opencontainers.image.description="Static page for the auto-healing web tier" \
      org.opencontainers.image.source="https://github.com/sxenix-coder/autoheal-web" \
      org.opencontainers.image.licenses="MIT"

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

# Container-level health check. This complements rather than duplicates the ALB
# health check: Docker restarts the container locally if it stops serving, while
# the ASG replaces the whole instance if the problem is more fundamental.
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ > /dev/null || exit 1

# nginx:alpine already runs nginx in the foreground as its default command.
