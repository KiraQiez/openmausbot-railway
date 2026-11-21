#!/bin/sh
# `railway ssh` enters the container as root; the server's data belongs to maus.
if [ "$(id -u)" = 0 ]; then
  exec setpriv --reuid maus --regid maus --init-groups env HOME=/data node /app/dist-server/openmausbot.js "$@"
fi
exec node /app/dist-server/openmausbot.js "$@"
