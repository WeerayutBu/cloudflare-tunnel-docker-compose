.DEFAULT_GOAL := help

COMPOSE := docker compose

.PHONY: help setup up down restart logs ps pull clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

setup: ## Create .env from .env.example (if missing)
	@if [ -f .env ]; then echo ".env already exists"; \
	else cp .env.example .env && echo "Created .env — paste your tunnel token inside"; fi

up: ## Start all services in the background
	$(COMPOSE) up -d

down: ## Stop and remove all services
	$(COMPOSE) down

restart: ## Restart all services
	$(COMPOSE) restart

logs: ## Follow logs from all services
	$(COMPOSE) logs -f

ps: ## Show service status
	$(COMPOSE) ps

pull: ## Pull latest images
	$(COMPOSE) pull

clean: ## Stop services and remove volumes and orphans
	$(COMPOSE) down -v --remove-orphans
