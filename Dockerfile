# ── Stage 1: grab the Caddy binary ────────────────────────────────────────────
# The official Caddy binary carries a file capability (cap_net_bind_service) for
# privileged ports. Copying it to a fresh inode drops that capability, which lets
# it run as the unprivileged `maus` user (we only bind to $PORT, never <1024).
FROM caddy:2.10.2 AS edge
RUN cp /usr/bin/caddy /caddy

# ── Stage 2: official OpenMausBot image + Railway glue ───────────────────────
# `latest` is deliberate: every Railway redeploy picks up the newest release.
FROM ghcr.io/milind-soni/openmausbot:latest

# Root is needed at startup so start.sh can chown the Railway volume;
# start.sh then drops to `maus` for every long-running process.
USER root

COPY --from=edge /caddy /usr/local/bin/caddy

# Coding-engine CLIs baked into the image. Override with an `ENGINES` service
# variable on Railway (passed as a build arg); an empty value installs none.
# A throwaway HOME keeps npm's cache out of the final image.
ARG ENGINES="@anthropic-ai/claude-code @openai/codex"
RUN if [ -n "$ENGINES" ]; then \
      HOME=/tmp/omb-build-home npm install -g $ENGINES \
      && rm -rf /tmp/omb-build-home /tmp/node-compile-cache; \
    fi

COPY --chmod=0755 railway/openmausbot.sh /usr/local/bin/openmausbot
COPY --chmod=0755 railway/start.sh /app/railway/start.sh
COPY railway/Caddyfile /app/railway/Caddyfile

# The server listens on Unix sockets instead of loopback, so requests proxied
# in by Caddy are treated as remote and must be paired.
# OMB_CLI_PREFIX makes the server print commands users can actually run here.
ENV OMB_TUNNEL_SOCKET=/run/openmausbot/http.sock \
    OMB_WEBHOOK_SOCKET=/run/openmausbot/hooks.sock \
    OMB_SERVER_NAME=railway \
    OMB_CLI_PREFIX="railway ssh -- openmausbot"

# Railway runs its own healthcheck (configured in the dashboard), so disable
# the base image's Docker HEALTHCHECK.
HEALTHCHECK NONE

# tini forwards signals and reaps zombies; -s registers it as a subreaper
# in case it is not PID 1.
ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["/app/railway/start.sh"]
