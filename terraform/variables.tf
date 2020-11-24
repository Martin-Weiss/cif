variable "template_name" {
  type        = string
  description = "VM template that should be used for the VMs"
}

variable "stack_name" {
  type        = string
  description = "Prefix to be added to VM names in vSphere"
}

variable "vsphere_datastore" {
  type        = string
  description = "vSphere datastore to use"
}

variable "vsphere_datacenter" {
  type        = string
  description = "vSphere datacenter to use"
}

variable "vsphere_network" {
  type        = string
  description = "vSphere network to be attached to the VMs"
}

variable "vsphere_resource_pool" {
  type        = string
  description = "vSphere resource pool VMs should be assigned to"
}

variable "vsphere_vm_folder" {
  type        = string
  description = "VM folder the VMs should be placed in"
}

variable "authorized_keys" {
  type        = list(string)
  default     = []
  description = "SSH keys to inject into all the nodes"
}

variable "caasp_registry_code" {
  default     = ""
  description = "SUSE CaaSP Product Registration Code"
}

variable "firmware" {
  default     = "bios"
  description = "Firmware interface to use"
}

variable "guest_id" {
  default     = "sles15_64Guest"
  description = "Guest ID of the virtual machine"
}

variable "ntp_servers" {
  type        = list(string)
  default     = []
  description = "List of ntp servers to configure"
}

variable "packages" {
  type        = list(string)
  default     = []
  description = "List of additional packages to install"
}

variable "admin-packages" {
  type        = list(string)
  default     = []
  description = "List of additional packages to install"
}

variable "repositories" {
  type        = map(string)
  default     = {}
  description = "URLs of the repositories to mount via cloud-init"
}

variable "rmt_server_name" {
  default     = ""
  description = "SUSE Repository Mirroring Server Name"
}

variable "suma_server_name" {
  default     = ""
  description = "SUSE Manager Server Name"
}

variable "username" {
  default     = "caaspadm"
  description = "Default user for the cluster nodes created by cloud-init default configuration for all SUSE SLES systems"
}

variable "servers" {
  default     = 1
  description = "Number of servers"
}

variable "server_cpus" {
  default     = 4
  description = "Number of CPUs used on server"
}

variable "server_memory" {
#  default     = 8192
  default     = 4096
  description = "Amount of memory used on server node"
}

variable "server_disk_size" {
  default     = 50
  description = "Size of the root disk in GB on server node"
}

variable "server_data_disk_size" {
  default     = 100
  description = "Size of the data disk in GB on server node"
}

