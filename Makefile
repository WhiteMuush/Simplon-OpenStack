# Thin entry point. Every target is a pointer to a script in scripts/,
# the logic lives there. Settings come from .env, see .env.example.

SHELL := /bin/bash
.DEFAULT_GOAL := help
S := ./scripts

.PHONY: help env one-shot preflight host inventory install reset connect \
        status start stop demo demo-clean tunnel k8s k8s-clean os-apply os-destroy destroy fmt validate clean

help: ## Show this help
	@grep -hE '^[a-z0-9-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-11s\033[0m %s\n", $$1, $$2}'

env: ## Create .env and the tfvars files from their examples
	@$(S)/env.sh

one-shot: ## Checks, host VM, inventory and DevStack in a single run
	@$(S)/one-shot.sh

## Host

preflight: ## Check tools, login, quota and the SSH source range
	@$(S)/preflight.sh

host: ## Create or update the Azure host VM
	@$(S)/host-apply.sh

inventory: ## Write the Ansible inventory from the Terraform outputs
	@$(S)/inventory.sh

install: ## Install DevStack, 30 to 60 minutes
	@$(S)/devstack-install.sh

reset: ## Wipe a broken DevStack install before retrying
	@$(S)/devstack-reset.sh

connect: ## SSH in with Horizon tunnelled to a local port
	@$(S)/connect.sh

## Billing

status: ## Show the power state of the host VM
	@$(S)/power.sh status

start: ## Start the host VM after a deallocate
	@$(S)/power.sh start

stop: ## Deallocate the host VM, run this at the end of every session
	@$(S)/power.sh stop

## OpenStack resources

demo: ## Guided run for a presentation, ends with a live instance
	@$(S)/demo.sh

demo-clean: ## Remove what the demo created
	@$(S)/openstack-destroy.sh

tunnel: ## Open the SSH tunnel to the lab API in the background
	@$(S)/tunnel.sh

os-apply: ## Create the instances, networks and security groups
	@$(S)/openstack-apply.sh

os-destroy: ## Remove every OpenStack resource
	@$(S)/openstack-destroy.sh

## Kubernetes

k8s: ## Single node k3s inside the lab, created with Terraform
	@$(S)/k8s.sh

k8s-clean: ## Destroy the Kubernetes node
	@$(S)/k8s-clean.sh

## Housekeeping

destroy: ## Destroy the host VM and its network, irreversible
	@$(S)/host-destroy.sh

fmt: ## Format every Terraform stack
	@for d in terraform/*/; do terraform -chdir=$$d fmt; done

validate: ## Validate every Terraform stack
	@for d in terraform/*/; do echo "$$d"; terraform -chdir=$$d init -backend=false -input=false >/dev/null && terraform -chdir=$$d validate; done

clean: ## Remove local state, caches and the generated inventory
	@rm -rf terraform/*/.terraform terraform/*/*.tfstate* ansible/inventory.ini
