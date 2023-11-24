output "ip_servers" {
   #value = "${zipmap(vsphere_virtual_machine.server[each.key].name, vsphere_virtual_machine.server[each.key].default_ip_address)}"
   #vsphere_virtual_machine.server[each.key].guest_ip_addresses.0
   value = {
        for instance in vsphere_virtual_machine.server:
        instance.name => instance.guest_ip_addresses.0
   }
}
