# Simplon-OpenStack

OpenStack lab, fully declarative: Terraform builds the Azure host, Ansible
installs DevStack on it, Terraform then drives OpenStack itself.

## Layout

```
scripts/               every step, one script per job
terraform/azure/       host VM, network, NSG
ansible/               DevStack install playbook
terraform/openstack/   instances, networks and security groups in the lab
```

The Makefile holds no logic, each target points at a script.

## Walkthrough

```bash
make env        # create .env and the tfvars files, generate a password
                # then edit allowed_ssh_cidr in terraform/azure/terraform.tfvars
make one-shot   # checks, host VM, inventory and DevStack, about an hour
make connect    # SSH with Horizon on http://localhost:8080/dashboard
make stop       # end of session, otherwise billing keeps running
```

`make one-shot` chains `preflight`, `host`, `inventory` and `install`, each of
which can also be run on its own. The playbook is idempotent: it skips
`stack.sh` when the stack is already up. Add `YES=1` to skip the prompts.

Once DevStack answers, fill in `~/.config/openstack/clouds.yaml` from
`clouds.yaml.example`, then `make os-init && make os-apply`.

## Requirements

- Azure CLI, logged in: `az login`
- Terraform and Ansible
- OpenStack client: `pipx install python-openstackclient`

## Configuration

| File | Holds |
|---|---|
| `.env` | resource group, VM name, admin user, Horizon port |
| `terraform/azure/terraform.tfvars` | subscription, region, VM size, SSH source |
| `ansible/site.yml` | DevStack branch, passwords, floating range |

Both `.env` and `terraform.tfvars` are gitignored, their `.example` twins are
committed.

## Caveats

The Azure subscription is shared with the class. The vCPU quota is shared too,
and the Dv5 series is not available on it: `Standard_D4s_v4` is the safe size.

Trusted Launch disables nested virtualization, so the VM is deliberately left
on the standard security type.

Port 22 is opened only to `allowed_ssh_cidr`. Horizon is never exposed, it is
reached through the SSH tunnel opened by `make connect`.
