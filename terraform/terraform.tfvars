# datastore to use in vSphere
# EXAMPLE:
# vsphere_datastore = "STORAGE-0"
vsphere_datastore = "Datastore1"

# datacenter to use in vSphere
# EXAMPLE:
# vsphere_datacenter = "DATACENTER"
vsphere_datacenter = "Datacenter"

# network to use in vSphere
# EXAMPLE:
# vsphere_network = "VM Network"
vsphere_network = "VM Network"

# resource pool the machines will be running in
# EXAMPLE:
# vsphere_resource_pool = "CaaSP_RP"
vsphere_resource_pool = "CaaSP_RP"

# Folder the machines will be running in 
vsphere_vm_folder     = "CaaSP_VM_Folder"

# template name the machines will be copied from
# EXAMPLE:
# template_name = "SLES15-SP1-cloud-init"
template_name = "SLES15SP1-Template"

# IMPORTANT: Replace by "efi" string in case your template was created by using EFI firmware
firmware = "bios"

# prefix that all of the booted machines will use
# IMPORTANT: please enter unique identifier below as value of
# stack_name variable to not interfere with other deployments
stack_name = "caasp"

# Number of servers
# NOT USED
#servers = 1

# Optional: Size of the root disk in GB on server
# NOT USED
#server_disk_size = 55

# Optional: Define the repositories to use
# EXAMPLE:
# repositories = {
#   repository1 = "http://repo.example.com/repository1/"
#   repository2 = "http://repo.example.com/repository2/"
# }
repositories = {
    SLE-Module-Basesystem15-SP1-Pool = "http://base.esx.local/repo/SUSE/Products/SLE-Module-Basesystem/15-SP1/x86_64/product/"
    SLE-Module-Basesystem15-SP1-Updates = "http://base.esx.local/repo/SUSE/Updates/SLE-Module-Basesystem/15-SP1/x86_64/update/"
    SLE-Module-CAP-Tools15-SP1-Pool = "http://base.esx.local/repo/SUSE/Products/SLE-Module-CAP-Tools/15-SP1/x86_64/product/"
    SLE-Module-CAP-Tools15-SP1-Updates = "http://base.esx.local/repo/SUSE/Updates/SLE-Module-CAP-Tools/15-SP1/x86_64/update/"
    SLE-Module-Containers15-SP1-Pool = "http://base.esx.local/repo/SUSE/Products/SLE-Module-Containers/15-SP1/x86_64/product/"
    SLE-Module-Containers15-SP1-Updates = "http://base.esx.local/repo/SUSE/Updates/SLE-Module-Containers/15-SP1/x86_64/update/"
    SLE-Module-Server-Applications15-SP1-Pool = "http://base.esx.local/repo/SUSE/Products/SLE-Module-Server-Applications/15-SP1/x86_64/product/"
    SLE-Module-Server-Applications15-SP1-Updates = "http://base.esx.local/repo/SUSE/Updates/SLE-Module-Server-Applications/15-SP1/x86_64/update/"
    SLE-Product-HA15-SP1-Pool = "http://base.esx.local/repo/SUSE/Products/SLE-Product-HA/15-SP1/x86_64/product/"
    SLE-Product-HA15-SP1-Updates = "http://base.esx.local/repo/SUSE/Updates/SLE-Product-HA/15-SP1/x86_64/update"
    SLE-Product-SLES15-SP1-Pool = "http://base.esx.local/repo/SUSE/Products/SLE-Product-SLES/15-SP1/x86_64/product/"
    SLE-Product-SLES15-SP1-Updates = "http://base.esx.local/repo/SUSE/Updates/SLE-Product-SLES/15-SP1/x86_64/update/"
    "SUSE-CAASP-4.0-Pool" = "http://base.esx.local/repo/SUSE/Products/SUSE-CAASP/4.0/x86_64/product/"
    "SUSE-CAASP-4.0-Updates" = "http://base.esx.local/repo/SUSE/Updates/SUSE-CAASP/4.0/x86_64/update/"
}

# Minimum required packages. Do not remove them.
# Feel free to add more packages
packages = [
]

admin-packages = [
 "patterns-caasp-Management"
]

# ssh keys to inject into all the nodes
# EXAMPLE:
# authorized_keys = [
#   "ssh-rsa <key-content>"
# ]
authorized_keys = [
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC44eVPVTcxJ6FDDr+ay3UNwU4VTlZvDsLZ60F6Byyek1Gqfmt1DGgQul8+sx11KCFpyQAJjChbH3fqeZi/YBMU/H/l6pdPSKvgaDhBf1HmpIYliKi2fZc8cVgoyUBTVk9MA/onO/NqXk9n7n3+W8iDxb2yicA9QULFk0oNzs8uKxQMnjO5OPAQ+giW89NsRMT0CzLNmrJk6Ni443hejhrMOPqbNgC6qs8mUJMEx4v01q0D9cyVB1sbbd5cM0ole0R3Ev8sv8PW3iLaneLhmHwbRjIH6qpId+IUKnpK2g3q48Py32RTGiRojOFmgPn+MN3/DFq/REbQyvl2TJYt/g5d root@base"
]

# IMPORTANT: Replace these ntp servers with ones from your infrastructure
ntp_servers = ["1.pool.ntp.org", "0.pool.ntp.org"]
