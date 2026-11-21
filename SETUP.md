<div align="center">

<h1>Setup Guide</h1>

<p>From nothing to your own OpenMausBot in about <b>10 minutes</b>.</p>

<p><a href="README.md">← Back to README</a></p>

</div>

<br/>

## Overview

| Step | What you'll do | Time |
|:---:|---|:---:|
| [1](#step-1--deploy-the-repo) | Deploy this repo to Railway | 2 min |
| [2](#step-2--add-storage) | Add storage so your data is kept | 1 min |
| [3](#step-3--get-a-web-address) | Get a public web address | 1 min |
| [4](#step-4--add-the-settings) | Tell the app its address | 2 min |
| [5](#step-5--turn-on-health-checks) | Turn on health checks | 1 min |
| [6](#step-6--sign-in) | Sign in from your browser | 3 min |

### You'll need

- A **[Railway](https://railway.com)** account. The **Hobby plan or higher** is recommended, because the app needs more than 1 GB of memory.
- A **[GitHub](https://github.com)** account.
- The **Railway CLI** on your computer:
  ```sh
  brew install railway        # macOS
  npm install -g @railway/cli # any OS
  railway login
  ```

<br/>

## Step 1 · Deploy the repo

1. Click **Fork** at the top of this repo's GitHub page. This gives you your own copy.
2. In Railway, click **New Project → Deploy from GitHub repo** and pick your fork.

Railway starts building straight away.

> [!NOTE]
> The first deploy might crash. That's normal, because it has nowhere to save data yet. Step 2 fixes it.

<br/>

## Step 2 · Add storage

The app needs somewhere permanent to keep your chats, sign-ins and paired devices.

1. Right-click your service on the Railway canvas.
2. Choose **Attach volume**.
3. Set the **mount path** to:
   ```
   /data
   ```

> [!IMPORTANT]
> Skip this step and **everything is wiped** every time the app redeploys.

<br/>

## Step 3 · Get a web address

1. Open your service and go to **Settings → Networking**.
2. Click **Generate Domain**.
3. When Railway asks for a port, type **`8080`**.

Copy the address it gives you (something like `my-bot.up.railway.app`). You'll need it next.

<br/>

## Step 4 · Add the settings

The app needs to know its own address so its sign-in links point to the right place.

1. Open the **Variables** tab and click **Raw Editor**.
2. Paste this, with `my-bot.up.railway.app` replaced by **your** address:
   ```env
   PORT=8080
   OMB_PUBLIC_URL=https://my-bot.up.railway.app
   OMB_WEBHOOK_PUBLIC_URL=https://my-bot.up.railway.app
   ```
3. Click **Deploy**.

<br/>

## Step 5 · Turn on health checks

With health checks on, Railway waits until the app is really ready before it sends visitors, and restarts it if it crashes.

Go to **Settings → Deploy** and set:

| Setting | Value |
|---|---|
| Healthcheck Path | `/api/health` |
| Healthcheck Timeout | `300` |
| Restart Policy | `On Failure` |

Wait until the deployment says **Active**, then open your address in a browser.

> [!TIP]
> **What you should see:** a sign-in page that won't let you in yet. That's correct. You'll pair your browser next.

<br/>

## Step 6 · Sign in

OpenMausBot has no passwords. Instead, you make a one-time link from the server and open it on the device you want to use.

Run these on your computer:

```sh
# 1. Let Railway know your computer (only needed once)
railway ssh keys add

# 2. Connect this terminal to your project (choose your service)
railway link

# 3. Create a sign-in link, valid for 24 hours
railway ssh -- openmausbot pair --ttl 24h
```

Open the link it prints. **You're in!** 🎉

Your browser stays signed in for 30 days, and each visit extends that, up to 180 days.

<details>
<summary><b>Adding more devices</b></summary>
<br/>

Run the `pair` command again for each new device. For a phone that only needs chat and approvals, add `--phone`:

```sh
railway ssh -- openmausbot pair --ttl 24h --phone
```

</details>

<details>
<summary><b>Connecting Claude Code or Codex</b></summary>
<br/>

Once you're signed in, follow the app's prompts to connect an AI engine. Your sign-in is saved on the volume, so you only do this once.

</details>

<br/>

## Troubleshooting

<details>
<summary><b>The deploy fails or the health check times out</b></summary>
<br/>

Check that `PORT=8080` is set (Step 4), the volume is mounted at `/data` (Step 2) and the health check timeout is `300` (Step 5). Then open the service's **Deploy Logs** for the exact error.

</details>

<details>
<summary><b>"Application failed to respond"</b></summary>
<br/>

The domain's port and `PORT` don't match. Make sure both are `8080`.

</details>

<details>
<summary><b>"502 Bad Gateway" right after deploying</b></summary>
<br/>

The app is still starting. Wait 30 seconds and refresh.

</details>

<details>
<summary><b>The sign-in link opens the wrong website</b></summary>
<br/>

`OMB_PUBLIC_URL` is wrong. It must be your exact address and start with `https://`.

</details>

<details>
<summary><b>My chats disappeared after a redeploy</b></summary>
<br/>

The volume is missing or isn't mounted at `/data`. Go back to Step 2.

</details>

<details>
<summary><b><code>railway ssh</code> says "permission denied"</b></summary>
<br/>

Run `railway ssh keys add`, then `railway link`, and pick the right service.

</details>

<details>
<summary><b>The app keeps restarting or is killed</b></summary>
<br/>

It's probably running out of memory. Allow about 1 GB, plus 700 MB for each bot that's working, and raise the limit in **Settings → Resources**.

</details>

<br/>

<div align="center">
<sub>Still stuck? <a href="https://github.com/KiraQiez/openmausbot-railway/issues">Open an issue</a>.</sub>
</div>
