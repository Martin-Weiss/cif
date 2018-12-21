Open ToDo:
----------------------------------------------
- add caas ntp server with variable function
- add caas hostname and resolv.conf function
- add rescue mode and manual install to iso
- add EFI for bootcd
- add suse manager script
- add release rpms for addons
- ntp pre-sles12sp3 --> error with ntp.conf comments starting with sles12sp3
- add pci-bus-id also for kvm sles11sp4? (net.xml und skript)

Quick howto:
----------------------------------------------

Add ISOS to server to /data/isos
Create ISO mount points
Adjust /etc/fstab to loop mount the ISOS to /srv/www/htdocs/<os>
Adjust /etc/apache/conf.d/inst_server.conf to export /srv/www/htdocs including follow symlinks
restart apache2

Adjust AutoYaST templates
Replace 10.1.1.1 with the IP of your gateway (grep -ir 10.1.1.1 *)
Replace 10.1.1.1 with the IP of your autoyast server (grep -ir 10.1.1.1 *)
Replace 10.1.1.1 with the IP of your dns server (grep -ir 10.1.1.1 *)
Adjust autoyast /config/CUSTOMER.txt
Enter variables to CUSTOMER.txt
Create / adjust tree variables files
Create / adjust network variables files
Adjust server.txt, hint: vda for kvm, sda for vmware, xda for xen

For PXE
Adjust /etc/dhcpd.conf
Adjust /srv/tftpboot/... grub.cfg, message, pxelinux.sys/default
Start tftserver, start dhcp server

Adjust autoyast/info-<os>.txt file to your autoyast and iso server

Adjust BOOT_CD 
/data/boot_cd_build/grub/*.lst
copy initrd linux to boot cd kernel sub-directories
create boot cd
adjust paths in create-ay-cd-v01.sh
build bootcd create-ay-cd-v01.sh

Install server using the boot-cd

KVM example:
virt-install --connect qemu:///system --virt-type kvm  --name ay-test-sles11sp4 --memory 2048 --network network=10-1-1 --disk pool=images-nvme,size=50,sparse=true --graphics vnc --os-variant sles11sp4 --vcpus 2 --cdrom /srv/www/htdocs/isos/autoyast-suse.iso

-> enter IP and Gateway that matches server.txt
