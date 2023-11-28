#!/bin/bash
AUTOYASTSERVER="10.1.1.1"
INFO="info-oes2023ga-upgrade.txt"
mkdir -p /boot/upgrade
wget -N http://$AUTOYASTSERVER/oes2023/boot/x86_64/loader/linux -P /boot/upgrade/
wget -N http://$AUTOYASTSERVER/oes2023/boot/x86_64/loader/initrd -P /boot/upgrade/
wget -N http://$AUTOYASTSERVER/autoyast/upgrade/oes2023ga.patch -P /boot/upgrade/
sed -i "s/%%AUTOYASTSERVER%%/$AUTOYASTSERVER/g" /boot/upgrade/oes2023ga.patch
sed -i "s/%%INFO%%/$INFO/g" /boot/upgrade/oes2023ga.patch
patch /etc/grub.d/10_linux -i /boot/upgrade/oes2023ga.patch -o /etc/grub.d/99_upgrade
chmod +x /etc/grub.d/99_upgrade
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-once "OES 2023 GA UPGRADE"
echo "Verify if the following line is correct and reboot in case yes"
echo
grep "info=" /boot/grub2/grub.cfg
