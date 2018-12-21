#!/bin/bash
#
# Author: Jochen Schaefer <jochen.schaefer@microfocus.com>
#
# copyright (c) Novell Deutschland GmbH, 2001-2016. All rights reserved.
# GNU Public License
#
# generic-script-executor.sh                             9 Jan 2013
# last modified:                                         1 May 2016

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

	# some information cannot be derived from a configuration file! Also used in pre-fetch.sh
	PREFIX=autoyast
	AY_CONFIG_DIR=configs
	MAIN_CONFIG_FILE=AY_MAIN.txt

	AY_BASE_DIR_URL=$AY_SERVER/$PREFIX
	AY_CONFIG_DIR_URL=$AY_BASE_DIR_URL/$AY_CONFIG_DIR

	# fetch and source the main configuration file	
	rm -rf /tmp/profile
	mkdir -p /tmp/profile
	cd /tmp/profile

 	/usr/bin/wget $AY_CONFIG_DIR_URL/$MAIN_CONFIG_FILE
	source $MAIN_CONFIG_FILE

	# fetch the main library and the customer configuration file
	/usr/bin/wget $AY_MAIN_LIB_FILE_URL
	/usr/bin/wget $AY_CUSTOMER_FILE_URL

	# source the main library and the customer configuration file
	source $AY_MAIN_LIB_FILE
	source $AY_CUSTOMER_FILE
}	

function execute_post_scripts()
{
	local SCRIPT_LIST=""
	local script
	for script in $SCRIPT_LIST;do
		test -n $script && /usr/bin/wget $AY_BASE_DIR_URL/scripts/$script
		test -n $script && sh -x $script
	done
}

function main()
{
	get_main_config_files
	execute_post_scripts
}

main
