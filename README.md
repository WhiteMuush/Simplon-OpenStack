# Simplon-OpenStack

OpenStack lab: an Azure VM hosting DevStack, driven with Terraform.

## Layout

```
azure/       create, connect to and deallocate the host VM
devstack/    DevStack configuration to copy onto the VM
terraform/   describe OpenStack resources once the lab is up
```

## Walkthrough

Run `make` to list every target.

1. `make env` creates `.env`, then edit it if the defaults do not fit
2. `make vm-create` creates the host VM
3. `make connect` opens SSH plus a tunnel to Horizon
4. On the VM, `make check-nested`, then install DevStack using
   `devstack/local.conf.example`
5. Fill in `~/.config/openstack/clouds.yaml` on your workstation
6. `make tf-init && make tf-apply`
7. `make vm-stop` at the end of every session, or billing keeps running

## Configuration

Every setting lives in `.env`: resource group, region, VM name and size, admin
user, disk size, auto shutdown time, Horizon port. Scripts and Makefile read
it, so nothing has to be edited in the code.

`.env` is gitignored, `.env.example` is the committed template.

## Requirements

- Azure CLI, logged in: `az login`
- Terraform
- OpenStack client: `pipx install python-openstackclient`

## Caveats

The Azure subscription is shared with the class. The vCPU quota is shared too,
and the Dv5 series is not available on it: use `Standard_D4s_v4`.

Trusted Launch blocks nested virtualization, hence `--security-type Standard`
in the create script.
