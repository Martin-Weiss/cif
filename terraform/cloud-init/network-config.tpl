version: 2 
ethernets:
  eth0:
    dhcp4: false
    addresses: [${ipaddress}]
    gateway4: ${gateway}
#    nameservers:
#      search: [${domainname}]
#      addresses: [${dnsserver1}, ${dnsserver2}]
#    routes:
#      - to: 0.0.0.0/0
#        via: ${gateway}
