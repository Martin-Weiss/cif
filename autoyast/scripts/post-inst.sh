#!/bin/bash
#
# Author: Jochen Schaefer <jochen.schaefer@microfocus.com>
#	  Frieder Schmidt <frieder.schmidt@microfocus.com>
#	  Martin Weiss <martin.weiss@suse.com>
# 
# copyright (c) Novell Deutschland GmbH, 2001-2016. All rights reserved.
#
# post-inst.sh	  					 9 Jan 2013
# last modified: 					21 Dec 2018

###########################################################################
###########################################################################
##
## This is the post-installation script of the AutoYaST system developed
## by Novell Consulting Germany.
##
## This script is used to trigger some cleanup oerations that are to be
## performed on every system.
##
## Feel free to adjust to meet your needs.

function set_vars()
{
        HOST_FILE=/etc/hosts
	SSHD_CONFIG=/etc/ssh/sshd_config
	VAR_FILE=/root/install/variables.txt
	AY_DIR=/var/adm/autoinstall/scripts
	VENDOR_DIR=vendor

        if [ -f $VAR_FILE ]; then
	   source $VAR_FILE
        fi
}

function correct_things()
{
        # disable ipv6
	echo -ne "\nDisable IPV6\n"
	
	if grep 11 >/dev/null /etc/os-release; then 
		# sles 11
		echo "SLES 11"; 
	        /usr/bin/sed -i -r 's/^#install/install/' /etc/modprobe.d/50-ipv6.conf
	else
		# sles12 and later
		sed -i "/net.ipv6.conf.all.disable_ipv6/d" /etc/sysctl.conf
		echo net.ipv6.conf.all.disable_ipv6 = 1 >> /etc/sysctl.conf
		sysctl --system
	fi

        # remove localhost from ::1     
	echo -ne "\nRemove localhost from ::1\n"
        /usr/bin/sed -i -r  's/(^::1.*)\s+\<localhost\>(\s+.*$)/\1\2/' $HOST_FILE
}

function enable_xforwarding_sshd()
{
	# this enables X forwarding for ssh connections
	echo -ne "\nEnable X forwarding for ssh (AddressFamily inet)\n"
	/usr/bin/sed -i "/AddressFamily/d" $SSHD_CONFIG
	echo "AddressFamily inet" >>$SSHD_CONFIG
	/etc/init.d/sshd restart
}

function exec_vendor_scripts()
{
	# derive autoyast URL from installedSystem.xml, applicable in stage2
	local XML_FILE="/var/adm/autoinstall/cache/installedSystem.xml"

        # determine installation server
	AY_SERVER_LIST=$(sed -rn -e 's#.*<location>([^/]*://[^/]*)/.*'$PREFIX'.*</location>#\1#p' $XML_FILE )

	# dirty workarround, overwrite server until the last occurence 
	local server
	for server in $AY_SERVER_LIST;do
		AY_SERVER=$server
	done	

	local script
	cd $AY_DIR
	wget -r -np -nH --reject "index.html*" $AY_SERVER/$PREFIX/scripts/$VENDOR_DIR/
	if [ $? -eq 0 ];then
		VENDOR_DIR=$(find -type d -name $VENDOR_DIR)	
		if [ -d $VENDOR_DIR ];then
			cd $VENDOR_DIR
			for script in $(ls *.sh);do
				sh $script
			done
		fi
		cd -
		test -d "$VENDOR_DIR" && rm -r "$VENDOR_DIR"

	fi
	
}

set_vars
correct_things
enable_xforwarding_sshd
exec_vendor_scripts

exit 0
