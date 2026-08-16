# Cloudflare Tunnel Docker Demo

A small Docker Compose demo that exposes frontend and backend containers through Cloudflare Tunnel and nginx—without opening a host port.

## Requirements

- Docker and Docker Compose
- A Cloudflare account and a remotely managed tunnel

## Setup

1. In [Cloudflare Zero Trust](https://one.dash.cloudflare.com), create a tunnel and set its public hostname service to `http://nginx:80`.
2. Create your local environment file:

```bash
make setup
```

3. Paste the tunnel token into `.env`, then start the demo:

```bash
make up
```

## Routing

| Path | Service |
|------|---------|
| `/` | Static frontend demo |
| `/backend/` | Placeholder backend container |

`/backend` redirects to `/backend/`. Follow logs with `make logs` and stop everything with `make down`.

## Customize

Replace the `frontend` or `backend` service image in `docker-compose.yml`, then edit routing in `nginx/nginx.conf`. Run `make help` for all commands.

> This is a demo. For production, add Cloudflare Access, managed secrets, monitoring, and a tested image-update process.
