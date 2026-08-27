# Simplon-OpenStack

Lab OpenStack : une VM Azure qui héberge DevStack, pilotée en Terraform.

## Arborescence

```
azure/       créer, joindre et désallouer la VM hôte
devstack/    configuration de DevStack à copier sur la VM
terraform/   décrire les ressources OpenStack une fois le lab debout
```

## Déroulé

1. `./azure/01-create-vm.sh` crée la VM hôte
2. `./azure/02-connect.sh` ouvre le SSH et le tunnel vers Horizon
3. Sur la VM, installer DevStack avec `devstack/local.conf.example`
4. Remplir `~/.config/openstack/clouds.yaml` sur le poste
5. `cd terraform && terraform init && terraform apply`
6. `./azure/99-deallocate.sh` en fin de session, sinon la facturation continue

## Prérequis

- Azure CLI connectée : `az login`
- Terraform
- Client OpenStack : `pipx install python-openstackclient`

## Attention

L'abonnement Azure est partagé avec la promo. Le quota vCPU est commun, et la
série Dv5 n'y est pas disponible : utiliser `Standard_D4s_v4`.

Trusted Launch bloque la virtualisation imbriquée, d'où `--security-type
Standard` dans le script de création.
