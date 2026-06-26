# Convenience wrapper. Each stack is its own compose project but they all
# share the external `proxy` network and the root .env file.

ENV := --env-file .env
# Order matters: socket-proxy before traefik (everything else routes via it).
STACKS := socket-proxy traefik cloudflared apps/private/portainer \
          apps/public/home apps/whitelist/pdf apps/whitelist/image

.PHONY: net up down restart logs ps pull

net:            ## create the shared docker networks (run once)
	docker network inspect proxy        >/dev/null 2>&1 || docker network create proxy
	docker network inspect socket_proxy >/dev/null 2>&1 || docker network create --internal socket_proxy

up: net         ## start the whole web platform
	@for s in $(STACKS); do echo "==> $$s"; docker compose $(ENV) -f $$s/docker-compose.yml up -d; done

down:           ## stop the web platform
	@for s in $(STACKS); do docker compose $(ENV) -f $$s/docker-compose.yml down; done

restart: down up

pull:           ## pull newer images
	@for s in $(STACKS); do docker compose $(ENV) -f $$s/docker-compose.yml pull; done

logs:           ## tail traefik + cloudflared
	docker compose $(ENV) -f traefik/docker-compose.yml -f cloudflared/docker-compose.yml logs -f

ps:
	docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
