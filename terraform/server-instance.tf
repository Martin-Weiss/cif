data "local_file" "server-txt" {
        filename = "${path.module}/server.txt"
}

locals {
  instances = csvdecode(data.local_file.server-txt.content)
}

data "template_file" "server_repositories" {
  template = file("cloud-init/repository.tpl")
  count    = length(var.repositories)

  vars = {
    repository_url  = element(values(var.repositories), count.index)
    repository_name = element(keys(var.repositories), count.index)
  }
}

data "template_file" "server_register_scc" {
  template = file("cloud-init/register-scc.tpl")
  count    = var.caasp_registry_code == "" ? 0 : 1

  vars = {
    caasp_registry_code = var.caasp_registry_code
  }
}

data "template_file" "server_register_rmt" {
  template = file("cloud-init/register-rmt.tpl")
  count    = var.rmt_server_name == "" ? 0 : 1

  vars = {
    rmt_server_name = var.rmt_server_name
  }
}

data "template_file" "server_register_suma" {
  template = file("cloud-init/register-suma.tpl")

  for_each = { for inst in local.instances : inst.servername => inst }
  #count    = var.suma_server_name == "" ? 0 : 1


  vars = {
    suma_server_name = var.suma_server_name
    activationkey = each.value.activationkey
  }
}

data "template_file" "server_commands" {
  template = file("cloud-init/commands.tpl")
  count    = join("", var.packages) == "" ? 0 : 1

  vars = {
    packages = join(", ", var.packages)
  }
}

data "template_file" "server_network_cloud_init" {
  template = file("cloud-init/network-config.tpl")

  for_each = { for inst in local.instances : inst.servername => inst }

  vars = {
    ipaddress = each.value.ipaddress
    gateway = each.value.gateway
    dnsserver1 = each.value.dnsserver1
    dnsserver2 = each.value.dnsserver2
    domainname = each.value.domainname
  }
}

data "template_file" "server_cloud_init_metadata" {
  template = file("cloud-init/metadata.tpl")

  for_each = { for inst in local.instances : inst.servername => inst }

  vars = {
    network_config = base64gzip(data.template_file.server_network_cloud_init[each.key].rendered)
    instance_id    = each.value.servername
  }
}

data "template_file" "server_cloud_init_userdata" {
  template = file("cloud-init/common.tpl")

  for_each = { for inst in local.instances : inst.servername => inst }

  vars = {
    authorized_keys = join("\n", formatlist("  - %s", var.authorized_keys))
    repositories    = join("\n", data.template_file.server_repositories.*.rendered)
    register_scc    = join("\n", data.template_file.server_register_scc.*.rendered)
    register_rmt    = join("\n", data.template_file.server_register_rmt.*.rendered)
    #register_suma   = join("\n", data.template_file.server_register_suma[each.key].rendered)
    register_suma   = data.template_file.server_register_suma[each.key].rendered
    commands        = join("\n", data.template_file.server_commands.*.rendered)
    ntp_servers     = join("\n", formatlist("    - %s", var.ntp_servers))
    servername        = each.value.servername
    ipaddress = each.value.ipaddress
    gateway = each.value.gateway
    dnsserver1 = each.value.dnsserver1
    dnsserver2 = each.value.dnsserver2
    domainname = each.value.domainname
  }
}

#resource "null_resource" "create-servers" {
#
#  provisioner "local-exec" {
#    command = "echo servername = ${each.value.servername}, ipaddress = ${each.value.ipaddress}, gateway = ${each.value.gateway}, dnsservers = ${each.value.dnsservers}, domainname =  ${each.value.domainname}"
#  }
#}

resource "vsphere_folder" "folder" {
  path          = var.stack_name
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "server" {
  depends_on = [vsphere_folder.folder]

  for_each = { for inst in local.instances : inst.servername => inst }

  name             = each.value.servername
  num_cpus         = each.value.cpus
  memory           = each.value.memory
  guest_id         = var.guest_id
  firmware         = var.firmware
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.stack_name
  wait_for_guest_net_timeout = 20
  scsi_controller_count = 1

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  disk {
    label = "disk0"
    size  = var.server_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    unit_number = 0
  }

  dynamic "disk" {
        for_each        = each.value.data_disk_size > 0 ? [1] : []
        content {
            label = "disk1"
            size  = each.value.data_disk_size
            eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
            thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
            unit_number = 1
        }
  }

  dynamic "disk" {
        for_each        = each.value.longhorn_disk_size > 0 ? [1] : []
        content {
            label = "disk2"
            size  = each.value.longhorn_disk_size
            eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
            thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
            unit_number = 2
            }
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(data.template_file.server_cloud_init_metadata[each.key].rendered)
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(data.template_file.server_cloud_init_userdata[each.key].rendered)
    "guestinfo.userdata.encoding" = "gzip+base64"
  }

  enable_disk_uuid = true

  network_interface {
    network_id = data.vsphere_network.network.id
  }
}

resource "null_resource" "server_wait_cloudinit" {
  depends_on = [vsphere_virtual_machine.server]
#  count = var.servers

  for_each = { for inst in local.instances : inst.servername => inst }

  connection {
    host = vsphere_virtual_machine.server[each.key].guest_ip_addresses.0
#      count.index,
#       each.key,
    user  = var.username
    type  = "ssh"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait > /dev/null",
    ]
  }
}

