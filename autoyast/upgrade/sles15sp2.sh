#!/bin/bash
AUTOYASTSERVER="10.1.1.1"
INFO="info-sles15sp2-upgrade.txt"
mkdir -p /boot/upgrade
wget -N http://$AUTOYASTSERVER/sles15sp2/boot/x86_64/loader/linux -P /boot/upgrade/
wget -N http://$AUTOYASTSERVER/sles15sp2/boot/x86_64/loader/initrd -P /boot/upgrade/
wget -N http://$AUTOYASTSERVER/autoyast/upgrade/sles15sp2.patch -P /boot/upgrade/
sed -i "s/%%AUTOYASTSERVER%%/$AUTOYASTSERVER/g" /boot/upgrade/sles15sp2.patch
sed -i "s/%%INFO%%/$INFO/g" /boot/upgrade/sles15sp2.patch
patch /etc/grub.d/10_linux -i /boot/upgrade/sles15sp2.patch -o /etc/grub.d/99_upgrade
chmod +x /etc/grub.d/99_upgrade
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-once "SLES 15 SP2 UPGRADE"
echo "Verify if the following line is correct and reboot in case yes"
echo
grep "info=" /boot/grub2/grub.cfg
