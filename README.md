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

Adjust /etc/apache2/conf.d/inst_server.conf to export /srv/www/htdocs including follow symlinks

\# httpd configuration for Installation Server included by httpd.conf

	<Directory /srv/www/htdocs/>
	        Options +Indexes +FollowSymLinks
        	IndexOptions +NameWidth=*
	</Directory>

Hint: We use http and apache to give access to the AutoYaST files as this allows easy tracking and logging by the apache acess and error logs. You can basically use any web server to provide the autoyast files.

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

or a bit more complex:

virt-install --connect qemu:///system --virt-type kvm  --name ses-5-1 --memory 1024 --network network=172-17-2 --network network=172-17-3 --disk pool=images-nvme,size=20,sparse=true --disk pool=images-nvme,size=20,sparse=true --disk pool=images-nvme,size=20,sparse=true --disk pool=images-nvme,size=20,sparse=true --disk pool=images-nvme,size=20,sparse=true --location http://10.1.1.1/sles12sp3 --graphics vnc --os-variant sles12sp3 --vcpus 2 -x "netsetup=0 hostip=172.17.2.51 nameserver=172.17.2.1 gateway=172.17.2.1 netmask=255.255.255.0 domain=suse hostname=ses-5-1.suse netwait=3 autoyast=http://10.1.1.1/autoyast/xml/"

-> Enter IP and gateway that matches server.txt when prompted

For for alpha to upgrade to sles 15 sp1 this check out on a sles 12 sp3 server:

- curl -Sks http://10.1.1.1/autoyast/upgrade/sles15sp1.sh | /bin/bash

SUSE Manager Integration:
----------------------------------------------
autoyast needs to be served via /srv/www/htdocs/pub/autoyast

(place for non-SUSE Manager http data)



The prefix "autoyast" needs to be adjusted to "pub/autoyast" in

autoyast/*.txt

autoyast/xml/default

autoyast/scripts/*.sh

change PREFIX="autoyast" to PREFIX="pub/autoyast"


SUSE Manager parameters need to be adjusted in CUSTOMER.txt

SUSE Manager registration key needs to be defined in server.txt

addon XML for SUSE Manager needs to be used (see -test/-referenz/-prod examples)


SUSE Manager bootstrap script "/pub/bootstrap/bootstrap.sh" needs to exist.

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
- 20190528-02 fix sles15sp1ses6 installerupdate in info.txt
- 20190528-03 add python2 sles15sp1 module for upgrade to ses6
- 20190813-01 added fix for mac address based server.txt
- 20190917-01 fixed typo in previous fix causing gateway not to be set
- 20190917-02 added caasp4 multidisk setup
- 20190917-03 changed caasp4 multidisk setup to btrfs for /var/lib/containers
- 20190923-01 ip forwarding for CaaSP v4
- 20191004-01 add /repo to the CaaSP v3 URLs to standardize
- 20191025-01 cosmetic change in README.md
- 20191113-01 add SUMA variables to ay_lib.sh
- 20191115-01 fix EFI setup for SLES 15 SP1
- 20191121-01 Added SUSE Manager information, adjusted CaaSP v4 to EFI and new partitioning layout
- 20191210-01 fix services/sles15/system.xml, added sle-ha example
- 20200110-01 update post-inst.sh to create ntp.conf properly
- 20200110-02 merge Frieders changes to lib and some XMLs
