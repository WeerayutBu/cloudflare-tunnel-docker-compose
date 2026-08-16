# Cloudflare Tunnel Docker Demo

A small Docker Compose demo that exposes frontend and backend containers through Cloudflare Tunnel and nginx—without opening a host port.

## Requirements

- Docker and Docker Compose
- A Cloudflare account and a remotely managed tunnel

## Setup

1. Open **Cloudflare Dashboard → Networking → Tunnels**, select **Create tunnel**, and give it a name.
2. Open the tunnel's **Routes** tab and add a **Published application**:
   - Hostname: a domain or subdomain managed by Cloudflare
   - Service URL: `http://nginx:80`
3. On **Overview**, select **Add a replica** and copy only the `eyJ...` token from the install command. Treat it like a password.
4. Configure and start the demo:

```bash
make setup
# Paste the token after CLOUDFLARE_TUNNEL_TOKEN= in .env
make up
```

5. Confirm the tunnel is **Healthy** in Cloudflare, then open its public hostname. If outbound traffic is restricted, allow `cloudflared` to reach Cloudflare on port `7844`.

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

> This is a demo. For production, add Cloudflare Access, managed secrets, monitoring, and a tested image-update process.
