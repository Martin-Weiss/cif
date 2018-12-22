#!/bin/sh
#
# Author: Jochen Schaefer <jochen.schaefer@microfocus.com>
#         Frieder Schmidt <frieder.schmidt@microfocus.com>
# 
# copyright (c) Novell Deutschland GmbH, 2001-2017. All rights reserved.
# GNU Public License
#
# zcm-install.sh	 					 9 Jan 2013
# last modified		 					28 Nov 2017

SCRIPT_NAME="zcm-install.sh"

function get_main_config_files()
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

	# some information cannot be derived from a configuration file!
	# Also used in pre-fetch.sh
	PREFIX="autoyast"

	AY_CONFIG_DIR="configs"
	MAIN_CONFIG_FILE="AY_MAIN.txt"

	AY_BASE_DIR_URL="$AY_SERVER/$PREFIX"
	AY_CONFIG_DIR_URL="$AY_BASE_DIR_URL/$AY_CONFIG_DIR"

	# change to the profile directory on the installation system
	PROFILE_DIR=/tmp/profile
	rm -rf $PROFILE_DIR
	mkdir -p $PROFILE_DIR
	cd $PROFILE_DIR

	# fetch and source the main configuration file (default: AY_MAIN.txt)	
	/usr/bin/wget -N $AY_CONFIG_DIR_URL/$MAIN_CONFIG_FILE
	source ./$MAIN_CONFIG_FILE

	# fetch and source the main library (default: ay_lib.sh)
	/usr/bin/wget -N $AY_MAIN_LIB_FILE_URL
	source ./$AY_MAIN_LIB_FILE
}


function get_customer_library()
{
	# fetch and source the customer library (default: customer_lib.sh)
	source_file $AY_LIB_DIR_URL/customer $AY_CUSTOMER_LIB_FILE
}	


function get_agent()
{
	get_file $ZCM_AGENT_URL	
	chmod 700 $ZCM_AGENT_BIN
}


function write_tty()
{
	local my_message="$@"
	local my_tty=/dev/tty1
	echo -e "\n$my_message\n" >$my_tty
}



####################################################################
#	start the real actions
####################################################################

function reg_zcm()
{
        local RC=0
	ZCM_DELAY=90

	write_tty "$SCRIPT_NAME: Retrieving Agent from AutoYaST Server  . . ."
	write_tty "$SCRIPT_NAME: This may take 15 - 30 min over slower WAN links"
	get_agent

	# retrieve first ZCM key (location)
	local SUBSCR_KEY=$(ret_firstval_list $my_zcmkey)

	if [ -n "$SUBSCR_KEY" ];then
		# install AGENT and register with ZCM location key
		./$ZCM_AGENT_BIN  -G -k $SUBSCR_KEY
		RC=$?

		write_tty "$SCRIPT_NAME: Wait $ZCM_DELAY seconds for ZCM agent to be installed."
		sleep $ZCM_DELAY

		if [ "$RC" = "0" ]; then
			write_tty "$SCRIPT_NAME: ZCM agent registered succesfully with ZCM server"
		else
			write_tty "$SCRIPT_NAME: Failed to register ZCM agent with ZCM server; RC=$RC"
		fi

		# optionally subscribe with additional ZCM keys (configuration, update)
		for f in $(split_list $my_zcmkey);do 
			if [ "$f" == "$SUBSCR_KEY" ];then
				:
			elif [ -n "$f" ]; then
				$ZAC_CMD ark $f
				RC=$?

				if [ "$RC" = "0" ]; then
					write_tty "$SCRIPT_NAME: Succesfully added registration key $f"
				else
					write_tty "$SCRIPT_NAME: Failed to add registration key $f; RC=$RC"
				fi
			else
				:
			fi
		done

		# set installation checkpoint
		$ZAC_CMD set rollback True
		$ZAC_CMD cpa install
		RC=$?

		if [ "$RC" = "0" ]; then
			write_tty "$SCRIPT_NAME: ZCM installation checkpoint has been set"
			write_tty "$SCRIPT_NAME: ZCM registration completed"
		else
			write_tty "$SCRIPT_NAME: Failed to set ZCM installation checkpoint; RC=$RC"
		fi
	else
		write_tty "$SCRIPT_NAME: !!! No ZCM key found!!!"
		exit 7
	fi
}


function main()
{
	# get main configuration file
	get_main_config_files

        # set some environment variables (library function)
        set_vars

        # get customer library
        # - requires set_vars ! -
        get_customer_library

        # determine wether the system being installed is identified
        # by its MAC address or by its IP address (default: IP)
        AY_MACHINE_IDENTIFIER=${AY_MACHINE_IDENTIFIER:="IP"}

        # using eDirectory as AY_CONFIG_BASE
        if [ -n "$(sed -n '/edir/Ip' <<<$AY_CONFIG_BASE)" ];then
                get_vars $AY_MACHINE_IDENTIFIER

        # using csv as AY_CONFIG_BASE
        else
		# get and source customer configuration file (default: CUSTOMER.txt),
                # (library function)
                get_customer_configuration_file

                # parse line from csv file (default: server.txt) to
                # locate the line with information for the system
                # being installed
                parse_line $(get_vars $AY_MACHINE_IDENTIFIER)

                # get and source customer tree and optionally location
                # information files (library function)
                get_customer_config_files

                # parse line from csv file (server.txt) again to preserve
                # more local variables from server.txt over variables from
                # customer configuration files
                parse_line $(get_vars $AY_MACHINE_IDENTIFIER)
        fi

	# register at ZCM server
	if ! egrep -q '.*ZCM' <<< $my_service_type; then
		reg_zcm
	fi

	# clean up
	cd ~; rm -rf $PROFILE_DIR
}


main

exit $?

