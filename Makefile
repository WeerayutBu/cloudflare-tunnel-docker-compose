.DEFAULT_GOAL := help

COMPOSE := docker compose
TERRAFORM ?= terraform
TF := $(TERRAFORM) -chdir=terraform
TFVARS := terraform/terraform.tfvars

.PHONY: help setup plan deploy down logs destroy

help:
	@echo "make setup    Create terraform.tfvars"
	@echo "make plan     Preview Cloudflare changes"
	@echo "make deploy   Apply Terraform and start the demo"
	@echo "make logs     Follow container logs"
	@echo "make down     Stop the containers"
	@echo "make destroy  Stop everything and delete Cloudflare resources"

setup:
	@test -f $(TFVARS) || cp terraform/terraform.tfvars.example $(TFVARS)
	@chmod 600 $(TFVARS)
	@echo "Edit $(TFVARS), then run: make plan"

plan:
	@umask 077; $(TF) init
	@umask 077; $(TF) plan

deploy:
	@umask 077; $(TF) init
	@umask 077; $(TF) apply
	@set -eu; \
	token="$$( $(TF) output -raw tunnel_token )"; \
	umask 077; \
	printf 'CLOUDFLARE_TUNNEL_TOKEN=%s\n' "$$token" > .env; \
	chmod 600 .env
	$(COMPOSE) up -d

down:
	@CLOUDFLARE_TUNNEL_TOKEN=unused $(COMPOSE) down

logs:
	$(COMPOSE) logs -f

destroy:
	@test -n "$$CLOUDFLARE_API_TOKEN" || { echo "Export CLOUDFLARE_API_TOKEN first"; exit 1; }
	@$(MAKE) --no-print-directory down
	@umask 077; $(TF) destroy
