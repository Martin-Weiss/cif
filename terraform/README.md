## Introduction

These terraform definitions are going to create the CaaSP v4 cluster on top of VMWare vSphere cluster.

This code was developed and tested on VMware vSphere cluster based on VMware ESXi 7

## Deployment

Prepare a VM template machine in vSphere by following [vmware-deployment guide](https://susedoc.github.io/doc-caasp/master/caasp-deployment/single-html/#_vm_preparation_for_creating_a_template).

It doesn't matter if you deploy the VM template for SLES15-SP1 manually by using ISO or you use pregenerated vmdk SLES15-SP1 JeOS image but in both cases you'll need `cloud-init-vmware-guestinfo` package (from SUSE CaaS Platform module), `cloud-init` package (from Public Cloud Module) and its dependent packages installed. The respective services must be enabled:

```sh
systemctl enable cloud-init cloud-init-local cloud-config cloud-final
```

Next you need to define following environment variables in your current shell with proper value:

```sh
# HINT: Please enter just a hostname without specifing a protocol in VSPHERE_SERVER variable (using https by default).
export VSPHERE_SERVER="vsphere.cluster.endpoint.fqdn"
export VSPHERE_USER="vsphere-admin-username"
export VSPHERE_PASSWORD="password"
export VSPHERE_ALLOW_UNVERIFIED_SSL="true"
```

Once you perform a [Customization](#Customization) you can use `terraform` to deploy the cluster:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

## Machine access

It is important to have your public ssh key within the `authorized_keys`, this is done by `cloud-init` through a terraform variable called `authorized_keys`.

All the instances have a `caaspadm` user, password is not set. User can login as `caaspadm` user over SSH by using his private ssh key. The `caaspadm` user can perform `sudo` without specifying a password.

## Variables

`vsphere_datastore` - Provide the datastore to use in vSphere\
`vsphere_datacenter` - Provide the datacenter to use in vSphere\
`vsphere_network` - Provide the network to use in vSphere - this network must be able to access the ntp servers and the nodes must be able to reach each other\
`vsphere_resource_pool` - Provide the resource pool the machines will be running in\
`template_name` - The template name the machines will be copied from\
`firmware` - Replace the default "bios" value with "efi" in case your template was created by using EFI firmware\
`authorized_keys` - A list of ssh public keys that will be installed on all nodes\
`repositories` - Additional repositories that will be added on all nodes\
`packages` - Additional packages that will be installed on all nodes

`adjust server.txt with the list of servers you want to create (see server.txt.example)

### Please use one of the following options:

`caasp_registry_code` - Provide SUSE CaaSP Product Registration Code in `registration.auto.tfvars` file to register product against official SCC server\
`rmt_server_name` - Provide SUSE Repository Mirroring Tool Server Name in `registration.auto.tfvars` file to use repositories stored on RMT server
`suma_server_name` - Provide SUSE Manager Server Name in `registration.auto.tfvars` file to use repositories stored on SUSE Manager server

### Open ToDo:

 terraform destroy -> need to delete servers from rmt/scc/suse manager
 add suma registration only in case a suma server is specified (not "")
 register only in case an activation key is specified for a system
 find out how to re-register a system with the same name but different machine-id to suse manager
