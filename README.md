# Homelab

## Scripts

### install.sh

- Install Tailscale for Debian: https://tailscale.com/kb/1174/install-debian-bookworm
  - Envs:
    - TS_AUTH_KEY: auth key for the server
- Update UFW to lockdown server ssh, only with Tailscale: https://tailscale.com/kb/1077/secure-server-ubuntu


## Services

### Traefik

Traefik with Docker for reverse proxy with Dashboard: https://doc.traefik.io/traefik/providers/docker/

- Dashboard: traefik.domain.dev
- Envs https://go-acme.github.io/lego/dns/cloudflare/
  - CLOUDFLARE_EMAIL
  - secrets/cloudflard-api-token.txt