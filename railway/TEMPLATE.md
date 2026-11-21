# Deploy and Host OpenMausBot with Railway

OpenMausBot is an open-source, self-hosted team of AI coding bots. They run on your own Claude Code and Codex sign-ins, and each bot gets its own browser. This template runs the official OpenMausBot image behind a small built-in proxy, so you have it online in minutes with nothing to build.

## About Hosting OpenMausBot

OpenMausBot is designed to trust only connections from its own machine. This template adds Caddy inside the container to accept Railway's traffic and pass it to the server over a private Unix socket. Every visitor is treated as remote, so each device has to be paired with a one-time link before it gets access. There are no passwords to leak. A volume at `/data` keeps chats, engine sign-ins and paired devices across redeploys, and every redeploy pulls the newest official release.

## Common Use Cases

- Run a personal AI coding team you can reach from any browser or phone
- Approve bot actions from your phone while the bots work in the cloud
- Share one always-on bot server across your devices without exposing your own computer

## Dependencies for OpenMausBot Hosting

- A Railway volume mounted at `/data` (included in the template)
- A Claude Code and/or Codex account to sign the bots in
- The Railway CLI, to make pairing links

### Deployment Dependencies

- OpenMausBot: https://github.com/milind-soni/OpenMausBot
- Template source and setup guide: https://github.com/KiraQiez/openmausbot-railway
- Railway CLI: https://docs.railway.com/guides/cli

### Implementation Details

After the deploy is **Active**, make a sign-in link from your terminal:

```sh
railway link                                # choose this project and service
railway ssh keys add                        # only needed once per machine
railway ssh -- openmausbot pair --ttl 24h   # prints a one-time sign-in link
```

Add `--phone` to pair a phone that only gets chat and approvals. Plan for about 1 GB of memory while idle, plus about 700 MB for each bot that's working.

## Why Deploy OpenMausBot on Railway?

Railway is a single platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying OpenMausBot on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
