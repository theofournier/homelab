# Homelab — OVH VPS + Docker + Cloudflare Tunnel + Traefik

Self-hosted platform for public sites, whitelisted web tools, private apps, and
background scripts (e.g. a crypto bot). No inbound ports are ever opened on the
VPS — Cloudflare Tunnel connects outbound, so your real IP stays hidden and the
firewall can deny everything inbound.

## Layout

```
homelab/
├── socket-proxy/       filtered, read-only Docker API in front of Traefik
├── traefik/            reverse proxy (routes by hostname, internal HTTP only)
├── cloudflared/        the outbound tunnel to Cloudflare
├── portainer/          container GUI, TIER: only me (Cloudflare Access)
├── apps/
│   ├── public-site/        TIER: everyone
│   ├── whitelisted-tool/   TIER: a few emails  (Cloudflare Access group)
│   └── private-dashboard/  TIER: only me       (Cloudflare Access)
```

## The three access tiers

All web traffic flows: `Cloudflare edge → tunnel → Traefik :80 → container`.
The tier is decided by the **Cloudflare Access policy** on each hostname, not in
Docker:

| Tier        | Cloudflare Access policy                    |
|-------------|---------------------------------------------|
| Public      | none                                        |
| Whitelisted | Allow → Include → Emails / Access Group     |
| Only me     | Allow → Include → your email                |

Because the tunnel is the *only* way in, edge Access can't be bypassed.

## First-time setup (on the VPS)

1. **Install Docker + compose plugin** and clone this repo.
2. **Create the Cloudflare tunnel** — Zero Trust → Networks → Tunnels → Create →
   Cloudflared. Copy the token.
3. `cp .env.example .env` and fill in `DOMAIN` + `CLOUDFLARE_TUNNEL_TOKEN`.
4. In the tunnel's **Public Hostnames**, add one entry per app, each pointing to
   service `http://traefik:80`:
   - `example.com`          (and `www`)  → public site
   - `tool.example.com`     → whitelisted tool
   - `dash.example.com`     → private dashboard
   - `portainer.example.com`→ Portainer (container GUI)
   - `traefik.example.com`  → Traefik dashboard
5. In **Zero Trust → Access → Applications**, add a self-hosted app + policy for
   every hostname that is *not* public (`tool`, `dash`, `portainer`, `traefik`).
   Lock `portainer` and `dash` to your email only.
6. Bring it up:
   ```bash
   make net      # once: create the shared `proxy` network
   make up       # start traefik, cloudflared, and all apps
   make ps
   ```

## Adding a new app

1. Copy an `apps/*/docker-compose.yml`, change the router name, `Host(...)` rule,
   and `loadbalancer.server.port`.
2. Add the hostname → `http://traefik:80` in the tunnel, plus an Access policy if
   it's not public.
3. `docker compose --env-file ../../.env -f apps/<name>/docker-compose.yml up -d`

## Why socket-proxy

Traefik no longer mounts the raw Docker socket. Instead `socket-proxy`
(tecnativa) exposes a read-only, write-denied subset of the Docker API over an
`--internal` network, and Traefik reads from that. If Traefik is ever
compromised it cannot create containers or escape to the host. Portainer is the
deliberate exception — it needs full control, so it keeps the real socket, and is
locked down behind a Cloudflare Access policy scoped to your email only.

## Secrets

`.env` files are gitignored. `chmod 600` them on the server. Never bake API keys
into images.
```
