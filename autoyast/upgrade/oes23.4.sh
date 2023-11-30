#!/bin/bash
AUTOYASTSERVER="10.1.1.1"
INFO="info-oes23.4-upgrade.txt"
mkdir -p /boot/upgrade
wget -N http://$AUTOYASTSERVER/oes23.4/boot/x86_64/loader/linux -P /boot/upgrade/
wget -N http://$AUTOYASTSERVER/oes23.4/boot/x86_64/loader/initrd -P /boot/upgrade/
wget -N http://$AUTOYASTSERVER/autoyast/upgrade/oes23.4.patch -P /boot/upgrade/
sed -i "s/%%AUTOYASTSERVER%%/$AUTOYASTSERVER/g" /boot/upgrade/oes23.4.patch
sed -i "s/%%INFO%%/$INFO/g" /boot/upgrade/oes23.4.patch
patch /etc/grub.d/10_linux -i /boot/upgrade/oes23.4.patch -o /etc/grub.d/99_upgrade
chmod +x /etc/grub.d/99_upgrade
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-once "OES 23.4 UPGRADE"
# ensure this does not run during / after the upgtade, again (hostname -i will not work)
# rm /etc/grub.d/99_upgrade
# added it to oes23.4.xml in scripts
echo "Verify if the following line is correct and reboot in case yes"
echo
grep "info=" /boot/grub2/grub.cfg
