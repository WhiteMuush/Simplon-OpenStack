# OpenStack lab: Azure host VM + DevStack + Terraform.
# Run `make` to list the available targets.

SHELL := /bin/bash
.DEFAULT_GOAL := help

RG      ?= mpetitRG
VM      ?= devstack
LOC     ?= francecentral
ADMIN   ?= azureuser
TF      := terraform -chdir=terraform

.PHONY: help vm-create vm-ip vm-status connect vm-start vm-stop vm-delete \
        check-nested tf-init tf-plan tf-apply tf-destroy tf-fmt os-status clean

help: ## Show this help
	@grep -hE '^[a-z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

## --- Azure host VM -----------------------------------------------------

vm-create: ## Create the host VM, nested virtualization enabled
	@./azure/01-create-vm.sh

vm-ip: ## Print the public IP of the host VM
	@az vm show -d -g $(RG) -n $(VM) --query publicIps -o tsv

vm-status: ## Show the power state, deallocated means no compute billing
	@az vm show -d -g $(RG) -n $(VM) --query powerState -o tsv

connect: ## SSH into the VM, Horizon tunnelled to localhost:8080
	@./azure/02-connect.sh

vm-start: ## Start the VM again after a deallocate
	@az vm start -g $(RG) -n $(VM)

vm-stop: ## Deallocate the VM, run this at the end of every session
	@./azure/99-deallocate.sh

vm-delete: ## Delete the VM and its disk, irreversible
	@read -p "Delete VM $(VM) in $(RG)? [y/N] " ok && [[ $$ok == y ]] || exit 1
	@az vm delete -g $(RG) -n $(VM) --yes

## --- DevStack ----------------------------------------------------------

check-nested: ## Check KVM availability, run this ON the VM
	@./azure/check-nested.sh

## --- Terraform ---------------------------------------------------------

tf-init: ## Download the OpenStack provider
	@$(TF) init

tf-plan: ## Preview the changes
	@$(TF) plan

tf-apply: ## Apply the changes
	@$(TF) apply

tf-destroy: ## Destroy every managed resource
	@$(TF) destroy

tf-fmt: ## Format the Terraform files
	@$(TF) fmt -recursive

## --- OpenStack ---------------------------------------------------------

os-status: ## List services, hypervisors and instances
	@openstack compute service list
	@openstack hypervisor list
	@openstack server list

clean: ## Remove local Terraform state and cache
	@rm -rf terraform/.terraform terraform/*.tfstate*
