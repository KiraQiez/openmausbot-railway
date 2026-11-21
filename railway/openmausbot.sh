#!/bin/sh
# Wrapper installed as `openmausbot` (e.g. `railway ssh -- openmausbot pair`).
# `railway ssh` enters the container as root, but the server's data on /data
# belongs to maus. Running the CLI as root would create root-owned files the
# server can't read, so switch to maus first.
if [ "$(id -u)" = 0 ]; then
  exec setpriv --reuid maus --regid maus --init-groups env HOME=/data node /app/dist-server/openmausbot.js "$@"
fi
exec node /app/dist-server/openmausbot.js "$@"
