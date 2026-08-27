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

1. `make vm-create` creates the host VM
2. `make connect` opens SSH plus a tunnel to Horizon
3. On the VM, `make check-nested`, then install DevStack using
   `devstack/local.conf.example`
4. Fill in `~/.config/openstack/clouds.yaml` on your workstation
5. `make tf-init && make tf-apply`
6. `make vm-stop` at the end of every session, or billing keeps running

## Requirements

- Azure CLI, logged in: `az login`
- Terraform
- OpenStack client: `pipx install python-openstackclient`

## Caveats

The Azure subscription is shared with the class. The vCPU quota is shared too,
and the Dv5 series is not available on it: use `Standard_D4s_v4`.

Trusted Launch blocks nested virtualization, hence `--security-type Standard`
in the create script.
