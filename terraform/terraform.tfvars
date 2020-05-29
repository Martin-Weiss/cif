# datastore to use in vSphere
# EXAMPLE:
# vsphere_datastore = "STORAGE-0"
vsphere_datastore = "datastore1"

# datacenter to use in vSphere
# EXAMPLE:
# vsphere_datacenter = "DATACENTER"
vsphere_datacenter = "Datacenter1"

# network to use in vSphere
# EXAMPLE:
# vsphere_network = "VM Network"
vsphere_network = "VM Network"

# resource pool the machines will be running in
# EXAMPLE:
# vsphere_resource_pool = "CaaSP_RP"
vsphere_resource_pool = "Cluster1/Resources"

# template name the machines will be copied from
# EXAMPLE:
# template_name = "SLES15-SP1-cloud-init"
template_name = "sles15sp1-3-template"

# IMPORTANT: Replace by "efi" string in case your template was created by using EFI firmware
firmware = "bios"

# prefix that all of the booted machines will use
# IMPORTANT: please enter unique identifier below as value of
# stack_name variable to not interfere with other deployments
stack_name = "caasp"

# Number of servers
servers = 1

# Optional: Size of the root disk in GB on server
server_disk_size = 55

# Optional: Define the repositories to use
# EXAMPLE:
# repositories = {
#   repository1 = "http://repo.example.com/repository1/"
#   repository2 = "http://repo.example.com/repository2/"
# }
repositories = {
    SES6-POOL = "http://smt.suse/repo/SUSE/Products/Storage/6/x86_64/product/"
    SES6-UPDATES = "http://smt.suse/repo/SUSE/Updates/Storage/6/x86_64/update/"
    SLE-Module-Basesystem15-SP1-Pool = "http://smt.suse/repo/SUSE/Products/SLE-Module-Basesystem/15-SP1/x86_64/product/"
    SLE-Module-Basesystem15-SP1-Updates = "http://smt.suse/repo/SUSE/Updates/SLE-Module-Basesystem/15-SP1/x86_64/update/"
    SLE-Module-CAP-Tools15-SP1-Pool = "http://smt.suse/SUSE/Products/SLE-Module-CAP-Tools/15-SP1/x86_64/product/"
    SLE-Module-CAP-Tools15-SP1-Updates = "http://smt.suse/SUSE/Updates/SLE-Module-CAP-Tools/15-SP1/x86_64/update/"
    SLE-Module-Containers15-SP1-Pool = "http://smt.suse/repo/SUSE/Products/SLE-Module-Containers/15-SP1/x86_64/product/"
    SLE-Module-Containers15-SP1-Updates = "http://smt.suse/repo/SUSE/Updates/SLE-Module-Containers/15-SP1/x86_64/update/"
    SLE-Module-Server-Applications15-SP1-Pool = "http://smt.suse/repo/SUSE/Products/SLE-Module-Server-Applications/15-SP1/x86_64/product/"
    SLE-Module-Server-Applications15-SP1-Updates = "http://smt.suse/repo/SUSE/Updates/SLE-Module-Server-Applications/15-SP1/x86_64/update/"
    SLE-Product-HA15-SP1-Pool = "http://smt.suse/SUSE/Products/SLE-Product-HA/15-SP1/x86_64/product/"
    SLE-Product-HA15-SP1-Updates = "http://smt.suse/SUSE/Updates/SLE-Product-HA/15-SP1/x86_64/update"
    SLE-Product-SLES15-SP1-Pool = "http://smt.suse/repo/SUSE/Products/SLE-Product-SLES/15-SP1/x86_64/product/"
    SLE-Product-SLES15-SP1-Updates = "http://smt.suse/repo/SUSE/Updates/SLE-Product-SLES/15-SP1/x86_64/update/"
    "SLES15-SP1-15.1-0" =  "http://smt.suse/sles15sp1/"
    "SUSE-CAASP-4.0-Pool" = "http://smt.suse/repo/SUSE/Products/SUSE-CAASP/4.0/x86_64/product/"
    "SUSE-CAASP-4.0-Updates" = "http://smt.suse/repo/SUSE/Updates/SUSE-CAASP/4.0/x86_64/update/"
}

# Minimum required packages. Do not remove them.
# Feel free to add more packages
packages = [
]

# ssh keys to inject into all the nodes
# EXAMPLE:
# authorized_keys = [
#   "ssh-rsa <key-content>"
# ]
authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD2rDHak8G11Qn3UvA85MNzm+nXpEFFpJV37LD2OBaohrXOBF3+zuw+Yxy7kbraFdzw6jEXtS6LjuaoxBMYRgqUcXOswo+xzSkLsJBOIDRMDIOFF8g+8sYwR4lIPs5WozM6hJpuiUwmz8MK/prJN6MR/znZFcot53pokkZp1Z4sgCbz/1ad2xr51kgB+XQqKrVf0G1H5rfe+HK6xQlZlL7i7y/BRkaIkKTLnSeXTKOqozY4n7vIp7Vy9zL0soS+bGBmMkxubvFvGx4GaP4QebRiRcME3MaZ4G5Fem4HVoq4Wdtlk/AYF74PSt0wQnTEGavbisyISXPr+J9bFJAd7b/b root@caasp4-01",
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAv1DS2t+Kmh7spHYFg2t0592otcq8YUnZXb17WgkpaWU5cS/2eLZoNbImURkbqpVC54zVwT2dUauJZG/2bXQBul8p2OK0Rgo+Vhhrbmtnvs4GXMfgxRUo3b+zadbMPZzOAxrEWJj8nkg5PV5+5jdxLR6/3ykZtRXn2kvh2/TMHMRpxE7x5xKwyAvXiGMK9kN0dTNEun9KKfNycXX1ZbvfJ02WuzQPA7K3i8eUZZeHlnRXso/66RWsmEPCipNua23wPrBXocsNFx75hvxDFwwvj1rj4SwB9afzcQbvvnLwPheEt8pl30Xozl7qZSVaYllZaEUMcrdklXESKhj87fKDhw== root@weiss-2"
]

# IMPORTANT: Replace these ntp servers with ones from your infrastructure
ntp_servers = ["weiss-2.weiss.ddnss.de", "0.pool.ntp.org"]
