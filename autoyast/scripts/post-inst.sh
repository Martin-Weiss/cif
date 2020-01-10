#!/bin/bash
#
# Author: Jochen Schaefer <jochen.schaefer@microfocus.com>
#	  Frieder Schmidt <frieder.schmidt@microfocus.com>
# 
# copyright (c) Novell Deutschland GmbH, 2001-2016. All rights reserved.
#
# post-inst.sh	  					 9 Jan 2013
# last modified (disable IPv6)				21 Dec 2018
# last modified (complete_ntp)				10 Dec 2019
# last modified (add $PREFIX)				10 Jan 2020

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


function complete_ntp()
{
        local NTP_CONF_FILE="/etc/ntp.conf"
        local NTP_TMP_FILE="/etc/ntp.tmp"
        cat <<HERE >>$NTP_TMP_FILE
################################################################################
## /etc/ntp.conf
##
## Sample NTP configuration file.
## See package 'ntp-doc' for documentation, Mini-HOWTO and FAQ.
## Copyright (c) 1998 S.u.S.E. GmbH Fuerth, Germany.
##
## Author: Michael Andres,  <ma@suse.de>
##         Michael Skibbe,  <mskibbe@suse.de>
##
################################################################################

##
## Radio and modem clocks by convention have addresses in the form 127.127.t.u,
## where t is the clock type and u is a unit number in the range 0-3.
##
## Most of these clocks require support in the form of a serial port or special
## bus peripheral. The particular device is normally specified by adding a soft
## link /dev/device-u to the particular hardware device involved, where u does
## correspond to the unit number above.
##
## Generic DCF77 clock on serial port (Conrad DCF77)
## Address:     127.127.8.u
## Serial Port: /dev/refclock-u
##
## (create soft link /dev/refclock-0 to the particular ttyS?)
##
# server 127.127.8.0 mode 5 prefer

##
## Undisciplined Local Clock. This is a fake driver intended for backup and when
## no outside source of synchronized time is available.
##
# server 127.127.1.0             # local clock (LCL)
# fudge  127.127.1.0 stratum 10  # LCL is unsynchronized

##
## Add external Servers using
## # rcntpd addserver <;yourserver>;
## The servers will only be added to the currently running instance, not to
## /etc/ntp.conf.
##

# Access control configuration; see /usr/share/doc/packages/ntp/html/accopt.html
# for details.
# The web page <http://support.ntp.org/bin/view/Support/AccessRestrictions> might
# also be helpful.
#
# Note that "restrict" applies to both servers and clients, so a configuration
# that might be intended to block requests from certain clients could also end
# up blocking replies from your own upstream servers.

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1

# Clients from this (example!) subnet have unlimited access, but only if
# cryptographically authenticated.
# restrict 192.168.123.0 mask 255.255.255.0 notrust

##
## Miscellaneous stuff
##

driftfile /var/lib/ntp/drift/ntp.drift  # path for drift file

logfile   /var/log/ntp                  # alternate log file

# logconfig =syncstatus + sysevents
# logconfig =all

# statsdir /tmp/                        # directory for statistics files
# filegen peerstats  file peerstats  type day enable
# filegen loopstats  file loopstats  type day enable
# filegen clockstats file clockstats type day enable

#
# Authentication stuff
#

keys       /etc/ntp.keys                # path for key file
trustedkey 1                            # define trusted keys
requestkey 1                            # key (7) for accessing server variables
controlkey 1                            # key (6) for accessing server variables


## configure ${CUSTOMER_NAME} time sources
HERE

        /usr/bin/grep -i "server" ${NTP_CONF_FILE} >> ${NTP_TMP_FILE}
        /bin/rm ${NTP_CONF_FILE}
        /bin/mv ${NTP_TMP_FILE} ${NTP_CONF_FILE}
}


function correct_things()
{
        # disable ipv6
	echo -ne "\nDisable IPV6\n"

	if grep 11 >/dev/null /etc/os-release; then 
		# SLES 11
		echo "SLES 11"; 
	        /usr/bin/sed -i -r 's/^#install/install/' /etc/modprobe.d/50-ipv6.conf
	else
		# SLES12 and later
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

#complete ntp.conf for SLES/OES releases pre SLE15
if [ -n $(egrep "11|12|20"<<<$my_release) ]; then
     complete_ntp
fi
correct_things
enable_xforwarding_sshd
exec_vendor_scripts

exit 0
