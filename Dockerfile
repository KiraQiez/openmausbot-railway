FROM caddy:2.10.2 AS edge
# Official Caddy carries a privileged-port file capability; a copy to a fresh inode drops it.
RUN cp /usr/bin/caddy /caddy

FROM ghcr.io/milind-soni/openmausbot:latest
USER root
COPY --from=edge /caddy /usr/local/bin/caddy
ARG ENGINES="@anthropic-ai/claude-code @openai/codex"
RUN if [ -n "$ENGINES" ]; then HOME=/tmp/omb-build-home npm install -g $ENGINES && rm -rf /tmp/omb-build-home /tmp/node-compile-cache; fi
COPY --chmod=0755 openmausbot.sh /usr/local/bin/openmausbot
COPY --chmod=0755 start.sh /app/railway/start.sh
COPY Caddyfile /app/railway/Caddyfile
ENV OMB_TUNNEL_SOCKET=/run/openmausbot/http.sock \
    OMB_WEBHOOK_SOCKET=/run/openmausbot/hooks.sock \
    OMB_SERVER_NAME=railway \
    OMB_CLI_PREFIX="railway ssh -- openmausbot"
HEALTHCHECK NONE
ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["/app/railway/start.sh"]
