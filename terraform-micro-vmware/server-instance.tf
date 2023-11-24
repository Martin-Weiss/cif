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

data "template_file" "combustionscript" {
  template = file("combustion/script.tpl")

  for_each = { for inst in local.instances : inst.servername => inst }

  vars = {
    servername = each.value.servername
  }
}

data "template_file" "networkconfig" {
  template = file("ignition/networkconfig.tpl")

  for_each = { for inst in local.instances : inst.servername => inst }

  vars = {
    ipaddress = each.value.ipaddress
    gateway = each.value.gateway
    dnsserver1 = each.value.dnsserver1
    dnsserver2 = each.value.dnsserver2
    domainname = each.value.domainname
  }
}

data "template_file" "ignition" {
  template = file("ignition/ignition.tpl")

  for_each = { for inst in local.instances : inst.servername => inst }

  vars = {
    servername = each.value.servername
    networkconfig = base64encode(data.template_file.networkconfig[each.key].rendered)
    combustionscript = base64encode(data.template_file.combustionscript[each.key].rendered)
    authorized_keys = jsonencode(var.authorized_keys)
  }
}

resource "vsphere_virtual_machine" "server" {
  #depends_on = [vsphere_folder.folder]

  for_each = { for inst in local.instances : inst.servername => inst }

  name             = each.value.servername
  num_cpus         = each.value.cpus
  memory           = each.value.memory
  guest_id         = var.guest_id
  firmware         = var.firmware
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  #folder           = var.stack_name
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

  dynamic "disk" {
        for_each        = each.value.ceph_disk_1_size > 0 ? [1] : []
        content {
            label = "disk3"
            size  = each.value.ceph_disk_1_size
            eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
            thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
            unit_number = 3
            }
  }

  dynamic "disk" {
        for_each        = each.value.ceph_disk_2_size > 0 ? [1] : []
        content {
            label = "disk4"
            size  = each.value.ceph_disk_2_size
            eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
            thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
            unit_number = 4
            }
  }

  dynamic "disk" {
        for_each        = each.value.ceph_disk_3_size > 0 ? [1] : []
        content {
            label = "disk5"
            size  = each.value.ceph_disk_3_size
            eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
            thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
            unit_number = 5
            }
  }

  dynamic "disk" {
        for_each        = each.value.ceph_disk_4_size > 0 ? [1] : []
        content {
            label = "disk6"
            size  = each.value.ceph_disk_4_size
            eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
            thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
            unit_number = 6
            }
  }

  extra_config = {
    "guestinfo.combustion.script"          = base64gzip(data.template_file.combustionscript[each.key].rendered)
    "guestinfo.ignition.config.data"          = base64gzip(data.template_file.ignition[each.key].rendered)
    "guestinfo.ignition.config.data.encoding" = "gzip+base64"
    "guestinfo.metadata"          = base64gzip(data.template_file.server_cloud_init_metadata[each.key].rendered)
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(data.template_file.server_cloud_init_userdata[each.key].rendered)
    "guestinfo.userdata.encoding" = "gzip+base64"
    "scsi0:5.virtualSSD" = "1"
    "scsi0:6.virtualSSD" = "1"
  }

  lifecycle {
	ignore_changes = [
		# ignore changes to extra_config scsi..virtualSSD in case the host does not have the device
		extra_config,ept_rvi_mode,hv_mode
	]
  }

  enable_disk_uuid = true

  network_interface {
    network_id = data.vsphere_network.network.id
  }
}

