# OpenStack lab: Terraform builds the Azure host, Ansible installs DevStack,
# Terraform then drives OpenStack itself. Run `make` to list the targets.

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Settings live in .env, copied from .env.example. Values below are fallbacks.
-include .env
export

RG           ?= mpetitRG
VM           ?= devstack
ADMIN        ?= azureuser
HORIZON_PORT ?= 8080

TF_AZURE := terraform -chdir=terraform/azure
TF_OS    := terraform -chdir=terraform/openstack
INVENTORY := ansible/inventory.ini

.PHONY: help env lab tf-init tf-plan tf-apply tf-destroy inventory install \
        connect vm-start vm-stop vm-status os-init os-plan os-apply os-destroy \
        fmt clean

help: ## Show this help
	@echo "VM $(VM) in $(RG)"
	@echo
	@grep -hE '^[a-z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

env: ## Create .env and the tfvars files from their examples
	@[[ -f .env ]] || cp .env.example .env
	@[[ -f terraform/azure/terraform.tfvars ]] || cp terraform/azure/terraform.tfvars.example terraform/azure/terraform.tfvars
	@echo "Edit .env and terraform/azure/terraform.tfvars before applying"

lab: tf-apply inventory install ## Build the host and install DevStack in one go

## Azure host

tf-init: ## Download the azurerm provider
	@$(TF_AZURE) init

tf-plan: ## Preview the host changes
	@$(TF_AZURE) plan

tf-apply: ## Create or update the host VM
	@$(TF_AZURE) apply

tf-destroy: ## Destroy the host VM and its network
	@$(TF_AZURE) destroy

## DevStack

inventory: ## Write the Ansible inventory from the Terraform outputs
	@printf '[devstack]\n%s ansible_user=%s\n\n[devstack:vars]\nprivate_ip=%s\nhorizon_port=%s\n' \
		"$$($(TF_AZURE) output -raw public_ip)" \
		"$$($(TF_AZURE) output -raw admin_username)" \
		"$$($(TF_AZURE) output -raw private_ip)" \
		"$(HORIZON_PORT)" > $(INVENTORY)
	@cat $(INVENTORY)

install: ## Run the playbook, stack.sh takes 30 to 60 minutes
	@cd ansible && ansible-playbook site.yml

connect: ## SSH in with Horizon tunnelled to localhost
	@echo "Horizon: http://localhost:$(HORIZON_PORT)/dashboard"
	@ssh -L $(HORIZON_PORT):localhost:80 \
		$$($(TF_AZURE) output -raw admin_username)@$$($(TF_AZURE) output -raw public_ip)

## Billing

vm-status: ## Show the power state, deallocated means no compute billing
	@az vm show -d -g $(RG) -n $(VM) --query powerState -o tsv

vm-start: ## Start the VM again after a deallocate
	@az vm start -g $(RG) -n $(VM)

vm-stop: ## Deallocate the VM, run this at the end of every session
	@az vm deallocate -g $(RG) -n $(VM)

## OpenStack resources

os-init: ## Download the openstack provider
	@$(TF_OS) init

os-plan: ## Preview the OpenStack changes
	@$(TF_OS) plan

os-apply: ## Create the instances, networks and security groups
	@$(TF_OS) apply

os-destroy: ## Remove every OpenStack resource
	@$(TF_OS) destroy

## Housekeeping

fmt: ## Format both Terraform stacks
	@$(TF_AZURE) fmt -recursive
	@$(TF_OS) fmt -recursive

clean: ## Remove local state, caches and the generated inventory
	@rm -rf terraform/*/.terraform terraform/*/*.tfstate* $(INVENTORY)
