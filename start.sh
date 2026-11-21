#!/bin/bash
set -euo pipefail

# Railway mounts a fresh volume owned by root.
if [ "$(stat -c %U /data)" != maus ]; then
  chown -R maus:maus /data
fi
install -d -o maus -g maus -m 0755 /run/openmausbot

as_maus() { setpriv --reuid maus --regid maus --init-groups env HOME=/data "$@"; }

cd /app
as_maus node /app/dist-server/server-launcher.js &
as_maus caddy run --config /app/railway/Caddyfile --adapter caddyfile &

trap 'kill -TERM $(jobs -p) 2>/dev/null; wait' TERM INT
wait -n
exit 1
