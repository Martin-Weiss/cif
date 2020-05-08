#!/bin/bash
#
# Author: Jochen Schaefer <jochen.schaefer@microfocus.com>
#	  Frieder Schmidt <frieder.schmidt@microfocus.com>
# 
# copyright (c) Novell Deutschland GmbH, 2001-2016. All rights reserved.
# GNU Public License
#
# pre-fetch.sh	  					 9 Jan 2013
# last modified (AY_SERVER) 				13 Jan 2020

###########################################################################
###########################################################################
##
## This is the main script of the AutoYaST system developed by Novell
## Consulting Germany.
##
## It retrieves all relevant configuration information and merges it
## with the xml template files to produce the server specific autoinst.xml
## file for the installation.


#########################################################
# Name:		get_main_config_files
#
# Description:	retrieves first argument via wget
#########################################################

function get_main_config_files()
{
	# derive  http://<[IP|DNS] of the AutoYaST Server> from /proc/cmdline
	# asuming that autoyast= or info= do point to the AutoYaST server
	AY_SERVER=$(cat /proc/cmdline | sed -r -ne 's#^.*(autoyast|info)\s*=\s*([^:]+://[^/]+)/.*#\2#p')

	# some information cannot be derived from a configuration file!
	# Also used in zcm-install.sh and other post-scripts
	PREFIX="autoyast"

	AY_CONFIG_DIR="configs"
	MAIN_CONFIG_FILE="AY_MAIN.txt"

	AY_BASE_DIR_URL="$AY_SERVER/$PREFIX"
	AY_CONFIG_DIR_URL="$AY_BASE_DIR_URL/$AY_CONFIG_DIR"

	# change to the profile directory on the installation system
        PROFILE_DIR=/tmp/profile
	cd "$PROFILE_DIR"

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

	# redefine AY_CONFIG_BASE if found on bootprompt
	AY_CONFIG_BASE_PROMPT=$(get_ay_config_base)
	test -n "$AY_CONFIG_BASE_PROMPT" && AY_CONFIG_BASE="$AY_CONFIG_BASE_PROMPT"

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

		# get and source customer tree and optionally customer location
		# information files (library function)
		get_customer_config_files

		# parse line from csv file (server.txt) again to preserve
		# more local variables from server.txt over variables from
		# customer configuration files
		parse_line $(get_vars $AY_MACHINE_IDENTIFIER)

		create_var_file
	fi

	# copy autoinst.xml to modified.xml, etc.
	prepare_xml

	# make differences between sles/oes, and their service packs
        make_server $my_server_type

        # process multi-value fields from server.txt configuration file
        multi_value

        # set udev_rules
        set_pciID "$(get_pci_values)"

        # replace placeholders in xml file
        do_replace

	# replace placeholders a second time
	# to properly replace placeholders
	# that contain placeholders
        do_replace

	# warn user if errors exists like failing wget or %% chars
	create_error_popup
}	

#####################################################################
#####################################################################
#	executing main
#
DEBUG=0
main
