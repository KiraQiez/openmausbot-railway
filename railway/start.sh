#!/bin/bash
# Container entrypoint (runs as root under tini).
# Prepares the volume and socket dir, then runs the OpenMausBot server and
# Caddy side by side as the unprivileged `maus` user.
set -euo pipefail

# Railway mounts a fresh volume owned by root; hand it to maus once.
# Skipped on later boots so a large volume doesn't slow every start.
if [ "$(stat -c %U /data)" != maus ]; then
  chown -R maus:maus /data
fi

# The server leaves a lease file tying /data to the machine it ran on. After a
# redeploy the new container may land on another machine, and the server would
# refuse to start, thinking the folder is still in use. Railway attaches a
# volume to only one running container at a time, so any lease found here is
# stale and safe to remove.
rm -f /data/.openmausbot/openmausbot-server.lease

# Directory for the Unix sockets that connect Caddy to the server.
install -d -o maus -g maus -m 0755 /run/openmausbot

# Run a command as maus, with HOME on the volume so engine sign-ins persist.
as_maus() { setpriv --reuid maus --regid maus --init-groups env HOME=/data "$@"; }

cd /app
as_maus node /app/dist-server/server-launcher.js &
as_maus caddy run --config /app/railway/Caddyfile --adapter caddyfile &

# On shutdown (Railway sends SIGTERM), stop both children and wait for them.
trap 'kill -TERM $(jobs -p) 2>/dev/null; wait' TERM INT

# If either process exits, exit non-zero so Railway restarts the container
# instead of leaving it half-alive.
wait -n
exit 1
