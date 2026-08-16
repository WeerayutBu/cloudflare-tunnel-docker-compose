# Cloudflare Tunnel Docker Demo

A small Docker Compose demo that exposes frontend and backend containers through Cloudflare Tunnel and nginx—without opening a host port.

```mermaid
flowchart LR
    Internet --> Cloudflare[Cloudflare Edge]
    Cloudflare --> cloudflared
    cloudflared --> nginx
    nginx -->|/| frontend
    nginx -->|/backend/| backend
```

## Requirements

- Docker, Docker Compose, and Make
- A Cloudflare account with a domain managed by Cloudflare

## Setup

### 1. Create a tunnel

In the [Cloudflare dashboard](https://dash.cloudflare.com), go to **Networking → Tunnels → Create tunnel**, enter a name, and select **Create**.

### 2. Copy the token

Open the tunnel's **Overview** tab and select **Add a replica**. Cloudflare shows a command containing `--token eyJ...`; copy only the `eyJ...` value.

### 3. Add a public hostname

Open **Routes → Add route → Published application** and enter:

- **Hostname:** your Cloudflare-managed domain or subdomain
- **Service URL:** `http://nginx:80`

### 4. Configure the demo

```bash
make setup
```

Open `.env` and paste the token:

```dotenv
CLOUDFLARE_TUNNEL_TOKEN=eyJ...
```

Then start the containers:

```bash
make up
```

The tunnel should become **Healthy** in Cloudflare, and the hostname should show the demo page. Use `make logs` if it does not connect. On a restricted network, allow outbound port `7844`.

### 5. Add a Zero Trust application

Protect the public hostname with Cloudflare Access:

1. Go to **Zero Trust → Integrations → Identity providers → Add new identity provider** and add **One-time PIN**.
2. Go to **Access controls → Applications → Add an application** and select **Self-hosted**.
3. Enter an application name and add the same public hostname used by the tunnel.
4. Create an **Allow** policy for specific email addresses or trusted email domains, and require **One-time PIN** as the login method.
5. Save the application, open its hostname, and verify an allowed user can sign in with the emailed code.

Never allow **One-time PIN** without an email allowlist; that would allow any valid email address to authenticate. See Cloudflare's [self-hosted application](https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/self-hosted-public-app/) and [One-time PIN](https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/one-time-pin/) guides.

### Cloudflare permissions

Account owners already have access. For another member, grant the least scope possible:

- **Cloudflare Access** to create and configure tunnels.
- **DNS** and **Load Balancer** to publish a public hostname.
- When possible, scope access to the required account, domain, or individual tunnel.

See Cloudflare's [tunnel setup](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/get-started/create-remote-tunnel/) and [permission reference](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/remote-tunnel-permissions/).

## Routing

| Path | Service |
|------|---------|
| `/` | Static frontend demo |
| `/backend/` | Placeholder backend container |

`/backend` redirects to `/backend/`. Follow logs with `make logs` and stop everything with `make down`.

## Customize

Replace the `frontend` or `backend` service image in `docker-compose.yml`, then edit routing in `nginx/nginx.conf`. Run `make help` for all commands.

> This is a demo. For production, use managed secrets, monitoring, and a tested image-update process.
