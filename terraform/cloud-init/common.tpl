#cloud-config

# set locale
locale: en_US.UTF-8

# set timezone
timezone: Europe/Berlin

ssh_authorized_keys:
${authorized_keys}

ntp:
  enabled: true
  ntp_client: chrony
  config:
    confpath: /etc/chrony.conf
  servers:
${ntp_servers}

# need to disable gpg checks because the cloud image has an untrusted repo
zypper:
  repos:
${repositories}
  config:
    gpgcheck: "off"
    solver.onlyRequires: "true"
    download.use_deltarpm: "true"

# need to remove the standard docker packages that are pre-installed on the
# cloud image because they conflict with the kubic- ones that are pulled by
# the kubernetes packages
# WARNING!!! Do not use cloud-init packages module when SUSE CaaSP Registraion
# Code is provided. In this case repositories will be added in runcmd module
# with SUSEConnect command after packages module is ran
#packages:

# trying workarond for error in cloud-init status -l after deployments when cloning 50G template to 50G vm
# disable the resize by cloud-init and add it to runcmd
# suse@caasp-master-1:~> cloud-init status -l
# status: error
# time: Tue, 12 May 2020 08:04:13 +0000
# detail:
# ('resizefs', ProcessExecutionError("Unexpected error while running command.\nCommand: ('btrfs', 'filesystem', 'resize', 'max', '/')\nExit code: 1\nReason: -\nStdout: Resize '/' of 'max'\nStderr: ERROR: resizing of '/' failed: add/delete/balance/replace/resize operation in progress",))
resize_rootfs: false

runcmd:
  # setup network properly
  # default route
  - echo "default ${gateway} - -" > /etc/sysconfig/network/routes
  - /usr/sbin/ip route add default via ${gateway}
  # /etc/hosts
  - echo ${ipaddress} ${servername}.${domainname} ${servername} >> /etc/hosts
  # /etc/resolv.conf
  - sed -i 's/^NETCONFIG_DNS_STATIC_SERVERS=.*/NETCONFIG_DNS_STATIC_SERVERS="${dnsserver1} ${dnsserver2}"/g' /etc/sysconfig/network/config
  - sed -i 's/^NETCONFIG_DNS_STATIC_SEARCHLIST=.*/NETCONFIG_DNS_STATIC_SEARCHLIST="${domainname}"/g' /etc/sysconfig/network/config
  - netconfig update -f
  # workaround for root fs resize
  - btrfs filesystem resize max /
  # Since we are currently inside of the cloud-init systemd unit, trying to
  # start another service by either `enable --now` or `start` will create a
  # deadlock. Instead, we have to use the `--no-block-` flag.
  # The template machine should have been cleaned up, so no machine-id exists
  - uuidgen --sha1 --namespace @dns --name ${servername}.${domainname} |sed 's/-//g' >/var/lib/dbus/machine-id
  - dbus-uuidgen --ensure
  # try to ensure the machine-id is persistent and based on FQDN
  - uuidgen --sha1 --namespace @dns --name ${servername}.${domainname} |sed 's/-//g' >/etc/machine-id
  - systemd-machine-id-setup
  # With a new machine-id generated the journald daemon will work and can be restarted
  # Without a new machine-id it should be in a failed state
  - systemctl restart systemd-journald
  # Workaround for bsc#1138557 . Disable root and password SSH login
#  - sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
#  - sed -i -e '/^#ChallengeResponseAuthentication/s/^.*$/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
#  - sed -i -e '/^#PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
#  - sshd -t || echo "ssh syntax failure"
#  - systemctl restart sshd
${register_scc}
${register_rmt}
${register_suma}
${commands}

#bootcmd:
#  # Hostnames from DHCP - otherwise `localhost` will be used
# - /usr/bin/sed -ie "s#DHCLIENT_SET_HOSTNAME=\"no\"#DHCLIENT_SET_HOSTNAME=\"yes\"#" /etc/sysconfig/network/dhcp

preserve_hostname: false
fqdn: ${servername}
hostname: ${servername}

system_info:
   # This will affect which distro class gets used
   distro: sles
   # Default user name + that default users groups (if added/used)
   default_user:
     name: suse
     lock_passwd: True
     gecos: sles Cloud User
     groups: [cdrom, users]
     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
     shell: /bin/bash
   # Other config here will be given to the distro class and/or path classes
   ssh_svcname: sshd

final_message: "The system is finally up, after $UPTIME seconds"
