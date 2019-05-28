Quick howto:
----------------------------------------------

mkdir /data

copy autoyast to /data/autoyast

mkdir /isos

Copy OS ISOS to /data/isos

Create ISO mount points at /srv/www/htdocs/<os> (i.e. sles12sp3, caasp3, sles11sp4)

Adjust /etc/fstab to loop mount the isos to /srv/www/htdocs/<os>

- cd /srv/www/htdocs
- ln -s /data/isos
- ln -s /data/autoyast

Adjust /etc/apache/conf.d/inst_server.conf to export /srv/www/htdocs including follow symlinks

Restart apache2

Adjust AutoYaST templates

Replace 10.1.1.1 with the IP of your gateway (grep -ir 10.1.1.1)

Replace 10.1.1.1 with the IP of your autoyast server (grep -ir 10.1.1.1)

Replace 10.1.1.1 with the IP of your dns server (grep -ir 10.1.1.1)

Adjust autoyast/config/CUSTOMER.txt (enter proper variables to CUSTOMER.txt)

Create and adjust network variables files in 

Create and adjust tree variables files

Adjust server.txt, hint: vda for kvm, sda for vmware, xda for xen

Adjust IP in autoyast/xml/default

Adjust autoyast/info-<os>.txt file to your autoyast and iso server

Adjust BOOT_CD: /data/boot_cd_build/grub/*.lst and /data/boot_cd_build/grub2.cfg

Copy initrd linux to boot cd kernel sub-directories

Adjust paths in create-ay-cd-v01.sh

Build bootcd using create-ay-cd-v01.sh

Install server using the boot-cd and specifying the IP for the server from server.txt in the format <ip>/<mask> i.e. 10.1.1.100/24

KVM example:

virt-install --connect qemu:///system --virt-type kvm  --name ay-test-sles11sp4 --memory 2048 --network network=10-1-1 --disk pool=images-nvme,size=50,sparse=true --graphics vnc --os-variant sles11sp4 --vcpus 2 --cdrom /srv/www/htdocs/isos/autoyast-suse.iso

-> Enter IP and gateway that matches server.txt when prompted

For for alpha to upgrade to sles 15 sp1 this check out on a sles 12 sp3 server:

- curl -Sks http://10.1.1.1/autoyast/upgrade/sles15sp1.sh | /bin/bash

Open Tasks:
----------------------------------------------
- Test EFI
- Add release rpms for addons
- Add PXE/DHCP

	Adjust /etc/dhcpd.conf

	Adjust /srv/tftpboot/... grub.cfg, message, pxelinux.sys/default

	Start tftserver, start dhcp server

- Add upgrade (down server and online)
- SUMA, ZCM or SMT registration based on variables

Known Issues:
----------------------------------------------
- NTP pre-sles12sp3 --> error with ntp.conf comments starting with sles12sp3
- Add pci-bus-id also for kvm sles11sp4? (net.xml and script)

Changelog:
----------------------------------------------
- 20190507-01 added ssh.keys.sh to sles scripts, added ses-5-rgw example to server.txt
- 20190507-02 added sles15sp1, ses6, oes2018sp1 (not yet tested)
- 20190508-01 changed ntp config for sles15 (no offline for chrony)
- 20190513-01 added efi boot for boot cd (not yet tested)
- 20190514-01 fix localboot option in efi boot, add netsetup nameserver
- 20190514-02 caasp: disable cloud-init(not needed with autoyast), add timezone config, fix ntp settings, ipv6 off
- 20190514-03 caasp: add example for gpt and efi partitioning
- 20190514-04 fixing / adding partitioning examples with gpt plus mdraid and efi plus mdraid
- 20190528-01 added first alpha for upgrade to sles15sp1
