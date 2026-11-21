# OpenMausBot on Railway

Run [OpenMausBot](https://github.com/milind-soni/OpenMausBot) on [Railway](https://railway.com) from the official image, with nothing to build from source.

This repo is a thin layer on top of `ghcr.io/milind-soni/openmausbot:latest`:

| File | What it does |
|---|---|
| `Dockerfile` | Starts from the official image and adds Caddy, plus the Claude Code and Codex CLIs. |
| `Caddyfile` | Listens on Railway's `$PORT` and forwards to the server's Unix socket. |
| `start.sh` | Fixes the volume's owner, then runs the server and Caddy as the unprivileged `maus` user. |
| `openmausbot.sh` | The `openmausbot` command; run as root (as `railway ssh` does), it switches to `maus` first. |

## Why the layer is needed

The official image only listens on `127.0.0.1` inside the container. Loopback trust is OpenMausBot's security model, so Railway's proxy can't reach it directly. Caddy, in the same container, takes Railway's traffic and passes it to the server over a Unix socket. Every request that comes in that way counts as remote and has to be paired.

Railway also mounts volumes owned by root, while the image runs as `maus`; `start.sh` fixes that on start.

## Deploy

1. In Railway, create a project and pick **Deploy from GitHub repo**, choosing this repo (or your fork of it).
2. **Add a volume** to the service, mounted at `/data`. Chats, engine sign-ins and paired devices live there.
3. Under **Settings → Networking**, choose **Generate Domain**, with port `8080`.
4. Set these variables on the service:

   | Variable | Value |
   |---|---|
   | `PORT` | `8080` |
   | `OMB_PUBLIC_URL` | `https://<your-domain>.up.railway.app` |
   | `OMB_WEBHOOK_PUBLIC_URL` | same as `OMB_PUBLIC_URL` |

5. Optional, under **Settings → Deploy**: set the healthcheck path to `/api/health` with a 300 s timeout, and the restart policy to *On failure*.

Every push to this repo redeploys the service. A redeploy also pulls the newest official OpenMausBot image.

To leave out the engine CLIs, or choose others, set `ENGINES` as a variable. Railway passes service variables to the Docker build as build arguments. An empty value installs none.

## Sign in

OpenMausBot has no passwords: a device signs in once with a one-time pairing code. With the [Railway CLI](https://docs.railway.com/guides/cli) linked to the service:

```sh
railway ssh -- openmausbot pair --ttl 24h
```

Open the link it prints. The browser stays signed in for 30 days, and each visit renews that up to 180 days. Run the command again for each new device; `--phone` gives a phone chat and approvals only.

`railway ssh` needs an SSH key registered with Railway (`railway ssh keys add`).

## Sizing

The server uses about 1 GB of memory idle, plus about 700 MB for each bot that is working. See OpenMausBot's [self-hosting guide](https://github.com/milind-soni/OpenMausBot/blob/main/docs/self-hosting.md#running-on-a-container-platform-railway-render-kubernetes-cloud-run) for process and memory limits.
