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

There are 2 Traefik services deployed

#### Traefik public

- Expose port 80 and 443
- Root of the domain
- DNS setup:
  - A record domain.dev -> IP public of server
  - For rach service, CNAME record *.domain.dev -> domain.dev
- Requires Docker label: traefik-proxy: true
- Requires Docker networks: traefik
- Envs https://go-acme.github.io/lego/dns/cloudflare/
  - CLOUDFLARE_EMAIL
  - CLOUDFLARE_API_TOKEN

#### Traefik Tailscale

- Uses the Tailscale service with Docker network_mode so alle routes exposed needs Tailnet
- Routes are exposed under: *.ts.domain.dev
- DNS setup:
  - A record ts.domain.dev -> IP of Tailscale server
  - For each service, CNAME record *.ts.domain.dev -> ts.domain.dev
- Requires Docker label: traefik-tailscale: true
- Requires Docker network: traefik-tailscale
- Same envs

Traefik Tailscale dashboard: traefik.ts.domain.dev


### Tailscale

- Service used by Traefik to VPN proxy
- Envs:
  - TS_DOCKER_AUTH_KEY


### Portainer

Portainer in Docker: https://docs.portainer.io/start/install-ce/server/docker/linux

Portainer dashboard: portaine.ts.domain.dev

### Home

Home: domain.dev

### Dashboard

Dashboard: ts.domain.dev