#!/bin/bash
#
# Author: Jochen Schaefer <jochen.schaefer@suse.com>
#         Frieder Schmidt <frieder.schmidt@microfocus.com>
#	  Martin Weiss	  <martin.weiss@suse.com>
#
# copyright (c) Novell Deutschland GmbH, 2001-2020. All rights reserved.
# GNU Public License
#
# ay_lib.sh	  		  			23 Jan 2013
# last modified (DSfW support)                          19 Sep 2019
# last modified (NTP  config)                           10 Dec 2019
# last modified (SLE15 support)                         10 Jan 2020
# last update (new xml structure)                       11 Jan 2020


#######################################################################
#######################################################################
##
## This file is the main library for the AutoYaST system developed by
## Novell Consulting Germany.
##
## It provides all the functions required by the AutoYaST system and
## must **not** be modified in any way!


#####################################################################
# Name:		debug
#
# Description:	enables debugging (set -x) if the global variable
# 		$DEBUG is set. Furthermore the name of each function
# 		is printed during execution
#####################################################################

function debug()
{
        if [ "$DEBUG" == "1" ];then
                set -x
        else
                set +x
        fi
}


#####################################################################
#
#	SMALL HELPER FUNCTIONS
#
#####################################################################
#
# Name:		print_func
#
# Description:	prints out function name if $DEBUG == 1
#		does not work if the function returns a value
#		via echo
#
# Used in:	almost every other function in this library ;-)
#               Functions that use the echo command to generate
#		their return value cannot use this funtion!
#####################################################################

function print_func()
{
	local MY_FN=$1
	if [ "$DEBUG" == "1" ];then
		echo -e "\n\nEntering '$MY_FN' . . .\n\n"
	fi
}


#####################################################################

# Name:		set_vars
#
# Description:	initializes PATH variables for autoyast xml files
#   		and common binaries
# 
# Used in:	pre-fetch.sh
#####################################################################

function set_vars()
{
	print_func $FUNCNAME	

	# defining files and directories
        AUTOYAST_FILE=$PROFILE_DIR/autoinst.xml
        AUTOYAST_CHANGE_FILE=$PROFILE_DIR/modified.xml
        AUTOYAST_CHANGE_FILE_JS=$PROFILE_DIR/js_modified.xml
        XSLT_TEMPL=/usr/share/autoinstall/xslt/merge.xslt
	XSLT_TMP_FILE=$PROFILE_DIR/XSLT_TMP.xml
	ERROR_FILE=$PROFILE_DIR/errors.txt
	FRD_ADC_XML_FILE=oes_base_frd_adc.xml
	FRD_ASK_XML_FILE=ask-dsfw-frd.xml
	FRD_FDC_XML_FILE=oes_base_frd_fdc.xml
	NSS_AD_XML_FILE=nss-ad.xml
	NSS_AD_ASK_XML_FILE=ask-ad.xml
	VAR_FILE=$PROFILE_DIR/variables.txt

	# defining OS commands
        IP_CMD=/sbin/ip
	WGETCMD="/usr/bin/wget -N"
	XSLT_CMD=/usr/bin/xsltproc

	# defining ZENworks Configuration Management agent command
	ZAC_CMD=/opt/novell/zenworks/bin/zac		
}


#####################################################################
# Name:		get_file
#
# Description:	retrieves first argument via wget
#
# Used in:	any funtion that needs to retrieve a file via wget
#####################################################################

function get_file()
{
	local FILE=$1

        $WGETCMD $FILE
	if [ $? -ne 0 ];then
		echo -ne "URL $FILE not found\n" >>$ERROR_FILE
                false
	fi
}


#####################################################################
# Name:		get_ip_list
#
# Description:	derives a list of all ip addresses of the
#		running machine and returns that list
#
# Used in:	get_vars
#####################################################################

function get_ip_list()
{
	# determine the only IP address bound to the installation system
	local ip_list=$($IP_CMD a s|sed -rne 's#^.*inet\s+([^/]*)/.*global.*$#\1#p') 
        echo "$ip_list"
}


#####################################################################
# Name:		get_mac_list
#
# Description:	derives a list of all mac addresses of the
# 		running machine and returns that list
#
# Used in:	get_vars
#####################################################################

function get_mac_list()
{
        local mac_list=$($IP_CMD a s|sed -rne 's#^.*link/ether\s+([^ ]*)\s+.*#\1#p')
        echo "$mac_list"
}


#####################################################################
# Name:		prepare_xml
#
# Description:	copies autoinst.xml to modified.xml
#
# Used in:	pre-fetch.sh
#####################################################################

function prepare_xml()
{
	print_func $FUNCNAME	

        cp $AUTOYAST_FILE $AUTOYAST_CHANGE_FILE
}


#####################################################################

# Name:		split_ip_cidr
#
# Description:	first argument contains ip/cidr
# 		this function splits ip from cidr and returns either
#		ip or cidr dependent on the second argument (ip|cidr)
#
# Used in:	parse_line
#####################################################################

function split_ip_cidr()
{
        local my_ip=$1
        local my_want=$2
        if [ "$my_want" == "ip" ];then
                echo $(awk -F"/" '{print $1}' <<<$my_ip)
        elif [ "$my_want" == "cidr" ];then
                echo $(awk -F"/" '{print $2}' <<<$my_ip)
        else
                echo "unknown error in $FUNCNAME"
                exit 127
        fi
}


#####################################################################
# Name:		get_sles_version
#
# Description:  derives the sles version from /etc/issue
#
# Used in:	do_replace
#####################################################################

function get_sles_version()
{
        if grep CaaS /etc/issue >/dev/null 2>&1; then
                SLES_VERSION="CAASP"
        fi
        if grep 2018 /etc/issue >/dev/null 2>&1; then
                SLES_VERSION=2018
        fi
        if grep 15 /etc/issue  >/dev/null 2>&1; then
                SLES_VERSION=15
        fi
        if grep 12 /etc/issue  >/dev/null 2>&1; then
                SLES_VERSION=12
        fi
        if grep 11 /etc/issue  >/dev/null 2>&1; then
                SLES_VERSION=11
        fi

	# If executed to validate parameter file entries we don't have
	# SLES_VERSION on the command line because the script will be
	# executed from the validation server
	# (typically the AutoYaST server itself)
	if [ -z "$SLES_VERSION" ];then
	 	  SLES_VERSION=12
	fi

        echo $SLES_VERSION
}


#####################################################################
# Name:		get_sles_sp
#
# Description:	derives the sles service pack from /proc/cmdline
#   		by evaluation of "install="-string
#
# Used in:	do_replace
#####################################################################

function get_sles_sp()
{
        local cmdline=$(cat /proc/cmdline)
        local SLES_SERVICE_PACK=$(sed -r -ne 's#^.*sles[0-9]{,2}([^_]{3}).*$#\1#p' <<<$cmdline)
        echo $SLES_SERVICE_PACK
}


#####################################################################
# Name:		guess_arch
#
# Description:	detection of architecture, returns i586 if not x86_64
#
# Used in:	do_replace, make_server
#####################################################################

function guess_arch()
{
        local my_arch=$(uname -m)
        if [ $my_arch != "x86_64" ];then
                my_arch=i586
        fi
        echo $my_arch
}


#####################################################################
#
#	FUNCTIONS TO HANDLE CSV
#
#####################################################################
#
# Name:		get_vars
#
# Description:	searching for all local ip|mac addresses in field 02
# 		of the server configuration file (server.txt)
#		stops when a match has been found and returns the
#		whole line
#
# Used in:	pre-fetch.sh
#####################################################################

function get_vars()
{
	print_func $FUNCNAME
	
        ## parm1  "IP" | "MAC" 
        local parm1=$1
        local result_line
        local search_list
	local device_address

        if [ "$parm1" == "IP" ];then
                search_list=$(get_ip_list)
        elif [ "$parm1" == "MAC" ];then
                search_list=$(get_mac_list)
        else
             echo "unknown param in $FUNCNAME"
                exit 127
        fi

	## get variables from eDirectory
        if [ -n "$(sed -n '/edir/Ip' <<<$AY_CONFIG_BASE)" ];then

		# determine environment
		AY_CONFIG_ENV=$(sed -rne  /ncif_env/{'s/^.*ncif_env=([^ ]*).*$/\1/p'} <<<$(cat /proc/cmdline))
		
		AY_CONFIG_ENV=${AY_CONFIG_ENV:="prd"}

		# remove whitespaces from begin and end of search_list 
		search_list=$(sed -re 's/^\s+|\s+$//g' <<<"$search_list")
		# search_list needs to be comma delimited for web-service
		search_list=$(tr " " ,<<<$search_list)

		$WGETCMD "$AY_SERVER/ncif/variables?env=$AY_CONFIG_ENV&macs=$search_list" -O $VAR_FILE
		if [ $? -ne 0 ];then
			echo -e "$WGETCMD $AY_SERVER/ncif/variables?env=$AY_CONFIG_ENV&addresses=$search_list returned an error\n" >> $ERROR_FILE
			echo -e "No NCIF Device object with address $search_list could be found in eDirectory\n" >>$ERROR_FILE
			create_error_popup
		fi

		source $VAR_FILE

		# eval edirectory attribute values which are BASH-VARIABLES
		local ev_liste="$(grep '\$' $VAR_FILE|grep -v ROOT_PWD| awk -F'=' '{print $1}')"
		for variable in $ev_liste;do
			eval $variable=$(eval echo \$$variable)
		done
	
	## get variables from csv
	else

		## retrieve csv file
		get_file $AY_SERVERTXT_FILE_URL

		## remove leading path from csv URL
		local CSV_FILE=$(sed -rne 's#^.*/([^/]+$)#\1#p' <<<$AY_SERVERTXT_FILE_URL)

		for i in $search_list;do
			if [ $parm1 == "IP" ];then
				# we are comparing ip addresses in field 2 of AY_SERVERTXT_FILE
				# format of field 2 is <IP>/<CIDR>, e.g. 10.0.0.1/24
				result_line=$(sed -rne 's!^[^;#]+;'$i'/[0-9]{,2};!&!p' $CSV_FILE)

				if [ -n "$result_line" ];then
					break
				fi
			else
				# we are comparing mac adresses in field 2 of AY_SERVERTXT_FILE
				result_line=$(sed -rne 's!^[^;#]+;'$i';!&!pi' $CSV_FILE)
				if [ -n "$result_line" ];then 
					break 
				fi 
			fi

		done

		if [ -n "$result_line" ];then
			echo "$result_line"
		fi
	fi

}


#####################################################################
# Name:		create_var_file
#
# Description: creates /tmp/profile/variables.txt	
#
# Used in:	pre-fetch.sh
#####################################################################

function create_var_file()
{
	local known=""
	local my_var=""
	local unknown=""

	local var_list="	
        AD_COMPUTER_CONTAINER
        AD_CREATE_NIT_UIDS
	AD_DOMAIN_ADMIN_GROUP
        AD_DOMAIN_NAME
        AD_NIT_UID_END
        AD_NIT_UID_START
        AD_USER_NAME
        AD_USE_PRECREATED_COMPUTEROBJ
        AFP_SEARCH_BASE
        AY_CONFIG_BASE
        AY_CONFIG_ENV
        AY_MACHINE_IDENTIFIER
        AY_SERVER
        CA_CN
        CA_COUNTRY
        CA_EMAIL
        CA_LOCALITY
        CA_NAME
        CA_O
        CA_OU
        CA_STATE
        CIFS_SEARCH_BASE
        CUSTOMER_NAME
        DHCP_GROUP_CONTEXT
        DHCP_INTERFACES
        DHCP_LOCATOR_CONTEXT
        DHCP_SERVER_CTX
        DNS_GROUP_CONTEXT
        DNS_LOCATOR_CONTEXT
        DNS_ROOTSERVERINFO_CONTEXT
        DNS_SERVER_CTX
	DOMAIN_NAME
	DSFW_CONTEXT
	DSFW_CONFIG_DC_DNS
	DSFW_CONFIG_DC_WINS
	DSFW_DC_TYPE
	DSFW_DOMAIN_NETBIOS
	DSFW_EXISTING_DNS_IP
	DSFW_ROOT_DOMAIN
	DSFW_ROOT_DOMAIN_ADMIN
	DSFW_ROOT_PDC_IP
        GATEWAY
	HOST_NAME
        HWCLOCK
        IPRINT_SEARCH_BASE
        ISO_SERVER
        KEYMAP
        LANGUAGE
        LDAP_SERVER_LIST
        LUM_ADMIN_GROUP
        NAME_SERVER_LIST
        NETSTORAGE_SEARCH_BASE
        NTP_SERVER_LIST
        OES_INSTALL_USER
        PREFIX
        REPLICA_SERVER
	SALT_MASTER
        SEARCH_BASE
	SLES_VERSION
        SLPDA_SERVER_LIST
        SLP_SCOPE_LIST
        SLP_TYPE
        SMT12_SERVER
        SMT12_CLIENT_URL
        SMT_CLIENT_URL
        SMT_SERVER
	SUMA_SERVER
	SUMA_BOOTSTRAP_FILE
	SUMA_BOOTSTRAP_URL
	SUMA_SERVER
        SUFFIX_SEARCH_LIST
        TIME_ZONE
        UCO_CONTEXT
        UPDATE_SYSTEM
        YUM_SERVER
        ZCM_AGENT_BIN
        ZCM_AGENT_URL
        ZCM_SERVER
        my_diskdevice_1
        my_diskdevice_2
        my_gateway
        my_hostname
        my_ipaddress
        my_location_file
        my_partfile
        my_preflen_1
        my_server_context
        my_server_type
        my_service_type
        my_software_file
        my_tree_name
        my_tree_type
        my_zcmkey"

	# derive DOMAIN_NAME and HOST_NAME
        if [ -n "$SUFFIX_SEARCH_LIST" ]; then
                DOMAIN_NAME=$(ret_firstval_list "$SUFFIX_SEARCH_LIST")
        fi
        if [ -n "$my_hostname" ]; then
                HOST_NAME=$my_hostname
        fi

	# list defined variables
	for  my_var in $var_list;do
		known=$(set|grep  "^$my_var=")
		if [ $? -eq 0 ];then
			echo "$known" >>$VAR_FILE
		else
			UNDEFINED_LIST="$UNDEFINED_LIST $my_var"
		fi
	done

	echo -e "#----------------------------------------------------------------------" >>$VAR_FILE

	# list undefined variables
	for unknown in $UNDEFINED_LIST;do
		echo "$unknown=undefined" >>$VAR_FILE
	done
}


#####################################################################
# Name:		get_random_list_value
#
# Description:	returns a random value from a list which must be
# 		passed as first argument
#
# Used in:	create_ntp_sles, create_ldap_entries
#####################################################################

function get_random_list_value()
{
        local server_list=$1
        local server_count=$(awk '{print NF}' <<<$server_list)

        local mod_value=$(expr $RANDOM % $server_count)

        local my_array
        declare -a my_array

        local count=0
        for server in $server_list;do
                my_array[$count]=$server
                let count=$count+1
        done

        # returns array index of modulo result
        echo ${my_array[$mod_value]}
}


#####################################################################
# Name:		check4errors
#
# Description:	checking for errors like "%%" within driverfile and 
#		putting result into $ERROR_FILE
#
# Used in:	create_error_popup
#####################################################################

function check4errors()
{
	print_func $FUNCNAME	

	if [ -f $AUTOYAST_CHANGE_FILE ]; then
		grep -q "%%" $AUTOYAST_CHANGE_FILE
		if [ $? -eq 0 ];then
			echo -ne "\n\n Found %% characters within $AUTOYAST_CHANGE_FILE:\n" >>$ERROR_FILE
			grep  -o "%%.*%%" $AUTOYAST_CHANGE_FILE 2>&1 >>$ERROR_FILE
		fi
	fi
}


#####################################################################
# Name:		create_error_popup
#
# Description:	ensure that a popup informs the admin about errors if
#		$ERROR_FILE exists.
#		This works only for SLES11 and above
#
# Used in:	pre-fetch.sh
#####################################################################

function create_error_popup() 
{
	print_func $FUNCNAME	

	check4errors

	if [ -e $ERROR_FILE ];then

		local url1=$AY_ERROR_HANDLER_FILE_URL
		local file_a=${url1##*/}

		# retrieve file responsible for popup generation of 
		# the error.txt file - this works only from SLES11 or later
		if [ "$(get_sles_version)" != "10" ];then
			#JS distinct between modified.xml exists or not
			if [ -f $AUTOYAST_CHANGE_FILE ];then
				get_file $url1
			
				# preserve edir password question for oes
				if [ "$my_product" == "oes" -a -z "$NO_OES_PWD" ];then
					# adding ask tags from check_errors.xml without 
					# merging  for oes11 and later
					dont_merge_xml $file_a ask
				else
				# merge check_errors.xml only for sles
					merge_xml $file_a dummy
				fi
			# no modified.xml
			else
				get_file $url1
				cp $AY_ERROR_HANDLER_FILE $AUTOYAST_CHANGE_FILE
			fi
		fi

		# replace place holder within ask-list section (admin user)
		do_replace

		local my_file=$(find /tmp -name "pre-fetch.sh")
		local dest_dir=$(dirname $my_file)
		cp $ERROR_FILE $dest_dir
	fi
}       


#####################################################################
# Name:         get_ipaddress_and_prefix
#
# Description:  Returns the IP address and Prefix in format
#		xxx.xxx.xxx.xxx/yy.
#
# Used in:      pre-fetch.sh
#####################################################################

function get_ipaddress_and_prefix()
{
	local my_interface=$($IP_CMD r s| awk '/default/ {print $5}')
	local my_ip_pref=$($IP_CMD a s dev $my_interface |awk '/inet / {print $2}')
	echo $my_ip_pref
}


#####################################################################
# Name:		parse_line
#
# Description:	parsing the result_line from the server configuration
#		file (server.txt) and setting variable values 
#
# Used in:	pre-fetch.sh
#####################################################################

function parse_line()
{
	print_func $FUNCNAME	

        local line="$1"
        function print_col()
        {
                echo $(awk -F';' '{print $col}' col=$1 <<<$line)
        }

        # field 01 hostname
        my_hostname="$(print_col 1)"

        # field 02 ip_address/cidr
        my_ipaddress=$(split_ip_cidr "$(print_col 2)" ip)

        # field 02 cidr
        my_preflen_1=$(split_ip_cidr "$(print_col 2)" cidr)
 
        if [ -z "$my_preflen_1" ];then
		my_ip_and_prefix=$(get_ipaddress_and_prefix)
		my_preflen_1=$(split_ip_cidr "$my_ip_and_prefix" cidr)                
		my_ipaddress=$(split_ip_cidr "$my_ip_and_prefix" ip)		
        fi

        # field 03 gateway
        my_gateway="$(print_col 3)"
	if [ -n "$my_gateway" ];then
		GATEWAY=$my_gateway
	else
		my_gateway=$GATEWAY
	fi

        # field 04 servertype sles11sp1,oes11sp1...
        my_server_type="$(print_col 4)"

        # field 05 first disk
        my_diskdevice_1="$(print_col 5)"

        # field 06 second disk
        my_diskdevice_2="$(print_col 6)"

        # field 07 partition xml file
        my_partfile="$(print_col 7)"

        # field 08 software xml file
        my_software_file="$(print_col 8)"

        # field 09 zcm registration key list
        my_zcmkey="$(print_col 9)"

	# field 10 treename
        my_tree_name="$(print_col 10)"

        # field 11 tree_type
        my_tree_type="$(print_col 11)"

        # field 12 server context
        my_server_context="$(print_col 12)"

        # field 13 location_file
        my_location_file="$(print_col 13)"

        # field 14 service_type
        my_service_type="$(print_col 14)"


	# error handling if no matching entry was found
	if [ -z "$line" ]; then
		
		echo -ne "System to be installed could not be located in $AY_SERVERTXT_FILE!\n" >>$ERROR_FILE
		echo -ne "------------------------------------------------------------------------------------------\n\n" >>$ERROR_FILE

		create_var_file
		cat $VAR_FILE >>$ERROR_FILE
	fi

	# error handling for non-existing Service Type
	if [ "$AY_CONFIG_BASE" == "csv" -a -n "$my_service_type" ]; then
		grep "^${my_service_type}=" "$PROFILE_DIR/$AY_CUSTOMER_FILE"
		RC=$?

		if [ $RC -ne 0 ]; then

			echo -ne "Undefined Service Type  \"$my_service_type\" in $AY_SERVERTXT_FILE!\n\n" >>$ERROR_FILE
			echo -ne "Please verify spelling in $AY_SERVERTXT_FILE and Service Type\n" >>$ERROR_FILE
			echo -ne "definition in $AY_CUSTOMER_FILE!\n" >>$ERROR_FILE
			echo -ne "---------------------------------------------------------------------------------------\n\n" >>$ERROR_FILE
		fi
	fi


	# create YaST popup if errors have been encountered
	if [ -f $ERROR_FILE ]; then
		create_error_popup
		exit 1
	fi
}


#####################################################################
# Name:		replace_placeholders
#
# Description:	define replaces placeholders with their values
#
# Used in:	do_replace
#####################################################################

function replace_placeholders()
{
	print_func $FUNCNAME	

	local place_holder=$1
	local replace_string=$2
	if [ -n "$replace_string" ];then
		sed -i -re "s#%%$place_holder%%#$replace_string#g" $AUTOYAST_CHANGE_FILE
	else
		sed -i -re "s#%%$place_holder%%##g" $AUTOYAST_CHANGE_FILE
	fi
}


#####################################################################
# Name:		get_media_label
#
# Description:	get labels of media when installing from dvd's
#
# Used in:	do_replace
#####################################################################

function get_media_label()
{
	print_func $FUNCNAME

	local REGEX="$1"
	local LABEL=$(ls /dev/disk/by-label|grep $REGEX)
	echo $LABEL

}


#####################################################################
# Name:		do_replace
#
# Description:	executing replace_placeholders
#
# Used in:	pre-fetch.sh
#####################################################################

function do_replace()
{
	print_func $FUNCNAME	

	# SLES Certificate Authority
	# - This block _must_ preceed any other replacements -
	# - because these variables themselves contain 
	# - placeholders 
	replace_placeholders CA_NAME "$CA_NAME"
	replace_placeholders CA_CN "$CA_CN"
	replace_placeholders CA_COUNTRY "$CA_COUNTRY"
	replace_placeholders CA_STATE "$CA_STATE"
	replace_placeholders CA_LOCALITY "$CA_LOCALITY"
	replace_placeholders CA_O "$CA_O"
	replace_placeholders CA_OU "$CA_OU"
	replace_placeholders CA_PWD "$CA_PWD"
	replace_placeholders CA_EMAIL "$CA_EMAIL"

	# customer name
	replace_placeholders CUSTOMER_NAME "$CUSTOMER_NAME"

	# hostname and ip address
	replace_placeholders HOST_NAME "$my_hostname"
	replace_placeholders IP_ADDRESS "$my_ipaddress"
	# CIDR (PREFIXLEN) will be replaced
	replace_placeholders PREFLEN_1 "$my_preflen_1"

	# disk devices
	replace_placeholders DEVICE_NAME0 "$my_diskdevice_1"
	replace_placeholders DEVICE_NAME1 "$my_diskdevice_2"

	# GATEWAY comes from CUSTOMER.txt, $AY_TREE_FILE, $my_location_file
	# or server.txt
	replace_placeholders GATEWAY "$my_gateway"
	replace_placeholders SERVER_CONTEXT "$my_server_context"

	# LDAP_1 comes from create_ldap_entries
	replace_placeholders LDAP_1 $LDAP_1
	replace_placeholders LUM_LDAP_PREFERRED $LUM_LDAP_PREFERRED

	replace_placeholders ARCH $(guess_arch)
	replace_placeholders SLES_VERSION $(get_sles_version)

	# my_product, my_release and my_sp come from function make_server
	replace_placeholders PRODUCT "$my_product"
	replace_placeholders VERSION "$my_release"
	replace_placeholders SP "$my_sp"

	# SUFFIX_SEARCH_LIST comes from CUSTOMER.txt, $AY_TREE_FILE or $my_location_file
	replace_placeholders DOMAIN_NAME $(ret_firstval_list "$SUFFIX_SEARCH_LIST")
	replace_placeholders TREE_NAME "$my_tree_name"
	replace_placeholders TREE_TYPE "$my_tree_type"

	# REPLICA_SERVER comes from CUSTOMER.txt, $AY_TREE_FILE or $my_location_file 
	# first server in tree
	if [ "$my_tree_type" == "new" ]; then
		REPLICA_SERVER=$my_ipaddress
	fi
	replace_placeholders REPLICA_SERVER "$REPLICA_SERVER"

	# LUM_ADMIN_GROUP, OES_INSTALL_USER and UCO_CONTEXT come from
	# CUSTOMER.txt, $AY_TREE_FILE or $my_location_file
	replace_placeholders LUM_ADMIN_GROUP "$LUM_ADMIN_GROUP"
	replace_placeholders OES_INSTALL_USER "$OES_INSTALL_USER"
	replace_placeholders UCO_CONTEXT "$UCO_CONTEXT"

	# DHCP information comes from CUSTOMER.txt, $AY_TREE_FILE or $my_location_file
	replace_placeholders DHCP_GROUP_CONTEXT "$DHCP_GROUP_CONTEXT"
	replace_placeholders DHCP_INTERFACES "$DHCP_INTERFACES"
	replace_placeholders DHCP_LOCATOR_CONTEXT "$DHCP_LOCATOR_CONTEXT"

	# DNS information comes from CUSTOMER.txt, $AY_TREE_FILE or $my_location_file
	replace_placeholders DNS_GROUP_CONTEXT "$DNS_GROUP_CONTEXT"
	replace_placeholders DNS_LOCATOR_CONTEXT "$DNS_LOCATOR_CONTEXT"
	replace_placeholders DNS_ROOTSERVERINFO_CONTEXT "$DNS_ROOTSERVERINFO_CONTEXT"

	# DSfW information comes from CUSTOMER.txt, $AY_TREE_FILE or $my_location_file
        replace_placeholders DSFW_CONTEXT "$DSFW_CONTEXT"
        replace_placeholders DSFW_CONFIG_DC_DNS "$DSFW_CONFIG_DC_DNS" 
        replace_placeholders DSFW_CONFIG_DC_WINS "$DSFW_CONFIG_DC_WINS"
	replace_placeholders DSFW_DC_TYPE "$DSFW_DC_TYPE"
        replace_placeholders DSFW_DOMAIN_NETBIOS "$DSFW_DOMAIN_NETBIOS"
        replace_placeholders DSFW_EXISTING_DNS_IP "$DSFW_EXISTING_DNS_IP"
        replace_placeholders DSFW_ROOT_DOMAIN "$DSFW_ROOT_DOMAIN"
	replace_placeholders DSFW_ROOT_DOMAIN_ADMIN "$DSFW_ROOT_DOMAIN_ADMIN"
	replace_placeholders DSFW_ROOT_PDC_IP "$DSFW_ROOT_PDC_IP"

	# Search base information comes from CUSTOMER.txt, $AY_TREE_FILE
	# or $my_location_file
	replace_placeholders SEARCH_BASE "$SEARCH_BASE"
	replace_placeholders AFP_SEARCH_BASE "$AFP_SEARCH_BASE"
	replace_placeholders CIFS_SEARCH_BASE "$CIFS_SEARCH_BASE"
	replace_placeholders IPRINT_SEARCH_BASE "$IPRINT_SEARCH_BASE"
	replace_placeholders NETSTORAGE_SEARCH_BASE "$NETSTORAGE_SEARCH_BASE"

	# replace AutoYaST Server,  Prefix and source servers in add_on products
	replace_placeholders AY_SERVER "$AY_SERVER"
	replace_placeholders PREFIX "$PREFIX"
	replace_placeholders ISO_SERVER "$ISO_SERVER"
	replace_placeholders SMT_SERVER "$SMT_SERVER"
	replace_placeholders SMT_CLIENT_URL "$SMT_CLIENT_URL"
	replace_placeholders SMT12_SERVER "$SMT12_SERVER"
	replace_placeholders SMT12_CLIENT_URL "$SMT12_CLIENT_URL"
	replace_placeholders YUM_SERVER "$YUM_SERVER"
	replace_placeholders ZCM_SERVER "$ZCM_SERVER"
	replace_placeholders SUMA_SERVER "$SUMA_SERVER"
	replace_placeholders SUMA_BOOTSTRAP_FILE "$SUMA_BOOTSTRAP_FILE"
	replace_placeholders SUMA_BOOTSTRAP_URL "$SUMA_BOOTSTRAP_URL"

	# replace root password 
	# must be encrypted as created by the yast autoinstallationt module
	replace_placeholders ROOT_PWD "$ROOT_PWD"

	# Time Zone
	replace_placeholders TIME_ZONE "$TIME_ZONE"

	# Language
	replace_placeholders LANGUAGE "$LANGUAGE"

	# KEYMAP
	replace_placeholders KEYMAP "$KEYMAP"

	# HWCLOCK
	replace_placeholders HWCLOCK "$HWCLOCK"

	# replace service object contexts
	return_service_ctx DHCP_SERVER_CTX $my_server_context "$DHCP_SERVER_CTX"
	return_service_ctx DNS_SERVER_CTX $my_server_context "$DNS_SERVER_CTX"

	# replace LABELs if installation sources are on images or fixed media and 
	# installation URLs are specified as cd:///oes?devices=/dev/disk/by-label/<LABEL>
	replace_placeholders FPL_LABEL $(get_media_label FPL)
	replace_placeholders OES_LABEL $(get_media_label OES)

	# replace settings for NSS-AD in OES2015
	replace_placeholders AD_COMPUTER_CONTAINER "$AD_COMPUTER_CONTAINER"
	replace_placeholders AD_CREATE_NIT_UIDS "$AD_CREATE_NIT_UIDS"
	replace_placeholders AD_DOMAIN_ADMIN_GROUP "$AD_DOMAIN_ADMIN_GROUP" # only OES2015 SP1 and above	
	replace_placeholders AD_DOMAIN_NAME "$AD_DOMAIN_NAME"
	replace_placeholders AD_NIT_UID_START "$AD_NIT_UID_START"
	replace_placeholders AD_NIT_UID_END "$AD_NIT_UID_END"
	replace_placeholders AD_USER_NAME "$AD_USER_NAME"
	replace_placeholders AD_USE_PRECREATED_COMPUTEROBJ "$AD_USE_PRECREATED_COMPUTEROBJ"

        # replace settings for SALT_MASTER in CAASP
        replace_placeholders SALT_MASTER "$SALT_MASTER"

        # replace settings for SSH_KEYS in CAASP
        replace_placeholders SSH_KEYS "$SSH_KEYS"

}


#####################################################################
#
#	FUNCTIONS TO HANDLE XML TAGS AND FILES
#
#####################################################################
#
# Name:		remove_32
#
# Description:	removes all 32-bit entries from software files
#		in rare cases where 32-bit machines are being
#		installed
#
# Used in:	make_server
#####################################################################

function remove_32()
{
	print_func $FUNCNAME	
        sed -i -e '/-32bit\|32bit/d' $AUTOYAST_CHANGE_FILE
}


#####################################################################
# Name:		un_tag
#
# Description:	uncomments xml tags
#		argument 1: is the tagname
#   		argument 2: is the name of the file being processed
#
#		!!IMPORTANT!!
#		when using this funtion there must not be any tags
#		in any comment in the file being processed!
#
# Used in:	create_ldap_entries
#####################################################################

function un_tag()
{
	print_func $FUNCNAME	

        local tag=$1
        local file=$2
        sed -i -e 's#^\s*<'$tag'>\|^\s*<'$tag' config:type.*>#<!--&#' $file
        sed -i -e 's#^\s*</'$tag'>\s*$#& -->#' $file
}


#####################################################################
# Name:		insert_before_placeholder
#
# Description:	a replacement string (argument 2) will be inserted 
#		into a xml file before the placeholder (argument 1)
#
# Used in:	multi_value()
#####################################################################

function insert_before_placeholder
{
	print_func $FUNCNAME	

        place_holder=$1
        replace_string="$2"
        sed -i '/'$place_holder'/i'"${replace_string}"'' $AUTOYAST_CHANGE_FILE
}


#####################################################################
# Name:		delete_placeholders
#
# Description:	a placeholder for a multi-value field (argument 1)
#		used in a xml file must be deleted after it has been
#		replaced with a value by insert_before_placeholder
#
# Used in:	multi_value()
#####################################################################

function delete_placeholders()
{
	print_func $FUNCNAME	

        place_holder=$1
        sed -i '/%%'$place_holder'%%/d' $AUTOYAST_CHANGE_FILE
}


#####################################################################
# Name:		uncomment_multiple_tags
#
# Description:	in situations where multiple xml-tags exist
#		with the same name like <listentry> a function is
#		needed which identifies and handles the right tags
#
#		argument 1: specifies the outer tag
#		argument 2: specifies the tag which will be uncommented
#		argument 3: specifies a search value which is located
#			    inside the tag to be uncommented
#
# Used in:	* currently not used *
#####################################################################

function uncomment_multiple_tags()
{
	print_func $FUNCNAME	

        export STARTTAG="<"$1
        export ENDTAG="</$1>"
        export SEARCHTAG="<"$2
        export SEARCHENDTAG="</$2>"
        export SEARCHVALUE="$3"

        awk "/$STARTTAG/ {
            i=0
            block[i]=\$0
            do { i++
                 getline line
                 block[i]=line
                } while ( ! match(line,\"$ENDTAG\") )
            sizeok=0
            for(j=0;j<=i;j++)
            {
                if ( match(block[j],\"${SEARCHTAG}.*>.*${SEARCHVALUE}.*${SEARCHENDTAG}\") ) { sizeok=1 }
            }
            if( sizeok==1 )
            {
                sub(\"$STARTTAG\",\"<!--$STARTTAG\",block[0])
                sub(\"$ENDTAG\",\"$ENDTAG-->\",block[i])
            }
            for(j=0;j<=i;j++) { print block[j] }
            next
        } { print \$0 }" $AUTOYAST_CHANGE_FILE >$AUTOYAST_CHANGE_FILE_JS

        mv $AUTOYAST_CHANGE_FILE_JS  $AUTOYAST_CHANGE_FILE
}


#####################################################################
# Name:		merge_xml
#
# Description:	merges xml-snippet (must be a valid xml file)
#		with the main autoyast driverfile
#		argument 1: contains the xml file to be merged
#		argument 2: contains the outer xml-tags from the file
#			    to be merged, e.g. partitioning or software
#
# Used in:	create_ldap_entries, create_ntp_sles, process_xml,
# 		set_pciID, 
#####################################################################

function merge_xml()
{
	print_func $FUNCNAME	

        local start_dir=$PROFILE_DIR
        local with_file=$start_dir/$1
        local out_file=$start_dir/XSLT_TMP.xml
        local change_file=$AUTOYAST_CHANGE_FILE
        local change_type=merge
        local outer_xml_tag=$2

	$XSLT_CMD --novalid --stringparam with $with_file --stringparam replace false --stringparam $change_type $outer_xml_tag --output $out_file $XSLT_TEMPL $change_file

        mv $out_file $AUTOYAST_CHANGE_FILE
        rm $with_file
}


#####################################################################
# Name:		dont_merge_xml
#
# Description:	merges xml-snippet (must be a valid xml file)
#		with the main autoyast driverfile
#		argument 1: contains the xml file to be merged
#		argument 2: contains the outer xml-tags from the file
#			    to be merged, e.g. partitioning or software
#		new entries will be added - not merged !!!
#
# Used in:	create_error_popup
#####################################################################

function dont_merge_xml()
{
        print_func $FUNCNAME

        local start_dir=$PROFILE_DIR
        local with_file=$start_dir/$1
        local out_file=$start_dir/XSLT_TMP.xml
        local change_file=$AUTOYAST_CHANGE_FILE
        local change_type=dontmerge
        local outer_xml_tag=$2

        $XSLT_CMD --novalid --stringparam with $with_file --stringparam replace false --stringparam $change_type $outer_xml_tag --output $out_file $XSLT_TEMPL $change_file

        mv $out_file $AUTOYAST_CHANGE_FILE
        rm $with_file
}


#####################################################################
# Name:		process_xml
#
# Description:	wrapper arround merge_xml which is using 4 arguments
#		argument 1: xml file which needs to be merged
#		argument 2: outer tag from file in argument 1
#		argument 3: class directory below classes which contains
#			    the xml file from argument 1 if argument 4
#			    does not exist
#		argument 4: if existend the xml file from argument 1
#			    will be searched below autoyast/files
#			    In this case argument 3 will be specified
#			    as "dummy" by definition
#
#		The function is responsible for retrieving and
#		merging the xml file
#
# Used in: 	make_server, merge_service_files
#####################################################################

function process_xml()
{
	print_func $FUNCNAME

        local start_dir=$PROFILE_DIR
        cd $PROFILE_DIR
        local file=$1
        local tag=$2
        local class_dir=$3
        local extra_comment=$4
        local xml_file
        if [ -n "$extra_comment" ];then
                xml_file=$AY_FILE_STORE_URL/$class_dir/$file
        else
                xml_file=${AY_XML_CLASS_DIR_URL}/$class_dir/$file
        fi

        get_file $xml_file

	# remove leading path if a subdirectory has been provided, e.g. partitioning/part1.xml
	real_filename=${file##*/}

        if [ -e "$real_filename" ];then
                merge_xml $real_filename "$tag"
        fi
}


#####################################################################
# Name:		create_ntp_sles
#
# Description:	creates the ntp-xml part for ntp.conf
#		one server from the ntp list will be randomly selected 
#		as preferred server to spread the load across different
#		ntp servers.
#
#		merge_xml is used to merge the snippet with the main
#		autoyast driver file
#
#		the ntp_server_list resulting from processing
#		CUSTOMER.txt, $AY_TREE_FILE, and my_location_file
#		will be used as argument 
#
# Used in:	make_server
#####################################################################

function create_ntp_sles()
{
        local NTP_TMP_FILE=ntp.xml
        local ntp_server_list="$1"
        local preferred_server=$(get_random_list_value "$ntp_server_list")

        cat <<HERE >>$NTP_TMP_FILE
<?xml version="1.0"?>
<!DOCTYPE profile>
<profile
xmlns="http://www.suse.com/1.0/yast2ns"
xmlns:config="http://www.suse.com/1.0/configns">
  <ntp-client>
HERE

	# SLES/OES releases pre SLE15
	if [ -n "$(egrep "11|12|2015|2018"<<<$my_release)" ]; then
        	cat <<HERE >>$NTP_TMP_FILE
  <peers config:type="list">
HERE

	for ntp_server in $ntp_server_list;do
		if [ "$ntp_server" == "$preferred_server" ];then

			cat <<HERE >>$NTP_TMP_FILE
    <peer>
    <initial config:type="boolean">true</initial>
        <options>burst iburst prefer</options>
        <type>server</type>
        <address>$ntp_server</address>
    </peer>
HERE
		else

		cat <<HERE >>$NTP_TMP_FILE
    <peer>
    <initial config:type="boolean">true</initial>
        <options>burst iburst</options>
        <type>server</type>
        <address>$ntp_server</address>
    </peer>
HERE
        	fi
        done

        cat <<HERE >>$NTP_TMP_FILE
  </peers>
  <start_at_boot config:type="boolean">true</start_at_boot>
  <start_in_chroot config:type="boolean">true</start_in_chroot>
HERE

	# SLE15 and newer
	else
            cat <<HERE >>$NTP_TMP_FILE
    <ntp_policy>auto</ntp_policy>
    <ntp_servers config:type="list">
HERE

            for ntp_server in $ntp_server_list;do
		cat <<HERE >>$NTP_TMP_FILE
    <ntp_server>
      <address>$ntp_server</address>
      <iburst config:type="boolean">true</iburst>
      <offline config:type="boolean">false</offline>
    </ntp_server>
HERE
	    done

	    cat <<HERE >>$NTP_TMP_FILE
    </ntp_servers>
    <ntp_sync>systemd</ntp_sync>
HERE
	fi

	    cat <<HERE >>$NTP_TMP_FILE
  </ntp-client>
</profile>
HERE

	merge_xml $NTP_TMP_FILE ntp-client
}


#####################################################################
# Name:		remove_from_list
#
# Description:	removes and entry from a space seperated list
#
# Used in:	create_ldap_entries
#####################################################################

function remove_from_list()
{
	local list=$1
	local value=$2

	list=$(sed -re "s#$value##" <<<"$list")
	
	echo "$list"
}


#####################################################################
# Name:		create_ldap_entries
#
# Description:	creates the ldap-xml part for oes-ldap and selects
#		the LDAP servers for novell-lum
#
#		The server itself is always configured as the first
#		LDAP server
#
#		one server from the ldap server list is randomly
#		selected as LDAP server for OES services to spread
#		the load across the different ldap servers
#
#		merge_xml is used to merge the snipped with the main
#		autoyast driver file
#
#		the ldap_server_list from the customer configuration
#		file, from the my_tree_name_file or my_location_file
#		is used as argument 
#
# Used in:	merge_oes_files
#####################################################################

function create_ldap_entries()
{
	local LDAP_2=""
        local LDAP_TMP_FILE=ldap.xml
        local ldap_server_list1="$1"
 	local my_domain=$(ret_firstval_list "$SUFFIX_SEARCH_LIST")
	
	# configure LDAP servers for oes-ldap

        # 1. insert own IP Address as first LDAP server for oes-ldap
        cat <<HERE >>$LDAP_TMP_FILE
<?xml version="1.0"?>
<!DOCTYPE profile>
<profile
  xmlns="http://www.suse.com/1.0/yast2ns"
  xmlns:config="http://www.suse.com/1.0/configns">
  <oes-ldap>
    <ldap_servers config:type="list">
      <listentry>
        <ip_address>%%IP_ADDRESS%%</ip_address>
        <ldap_port config:type="integer">389</ldap_port>
        <ldaps_port config:type="integer">636</ldaps_port>
      </listentry>
HERE

	# 2. determine the LDAP server to be used by OES services
	# afp, cifs, iprint, netstorage and Linux User Management

        local tmp_arr=($ldap_server_list1)

        if [ ${#tmp_arr[@]} -gt 0 ];then
	   # check if the IP address of the server is in ldap_server_list1
	   if [ $(grep -iq $my_ipaddress <<<$ldap_server_list1;echo $?) -eq 0 ]; then
	        LDAP_1=$my_ipaddress
	   else
	   # check if the hostname of the server is in ldap_server_list1
	      for server in $ldap_server_list1; do 	
	        if [ $(grep -iq $my_hostname <<<$server; echo $?) -eq 0 ]; then
                     LDAP_1=$server
		     break
		   else
	             if [ $(grep -iq $my_hostname.$my_domain <<<$server; echo $?) -eq 0 ]; then
                       	  LDAP_1=$server
		     	  break
	             fi		
		fi
	      done
	   fi

	   # if no preferred LDAP server for LUM has been selected
	   # yet, use the first entry from ldap_server_list1
	   if [ -z $LDAP_1 ];then
 	        LDAP_1=$(ret_firstval_list "$ldap_server_list1")
        	cat <<HERE >>$LDAP_TMP_FILE
<listentry>
        <ip_address>$LDAP_1</ip_address>
        <ldap_port config:type="integer">389</ldap_port>
        <ldaps_port config:type="integer">636</ldaps_port>
      </listentry>
HERE
	   fi
	else
	  # LDAP_SERVER_LIST is undefined; we use the local IP for OES services
	  LDAP_1=$my_ipaddress
	fi

	# remove LDAP_1 from ldap_server_list1
	ldap_server_list1=$(remove_from_list "$ldap_server_list1" $LDAP_1)


        # 3. insert remaining entries from ldap_server_list1
	#    in oes-ldap section in random order and add them
	#    to the alternate LDAP servers for LUM if available

	tmp_arr=($ldap_server_list1)

	while [ ${#tmp_arr[@]} -gt 0 ]; do
        	LDAP_2=$(get_random_list_value "$ldap_server_list1")
        	cat <<HERE >>$LDAP_TMP_FILE
<listentry>
        <ip_address>$LDAP_2</ip_address>
        <ldap_port config:type="integer">389</ldap_port>
        <ldaps_port config:type="integer">636</ldaps_port>
      </listentry>
HERE
		# build colon separated randomized list of
		# alternate LDAP servers for LUM
		if [ -z "$ALTERNATE_LDAPSERVERLIST" ]; then
			ALTERNATE_LDAPSERVERLIST="$LDAP_2"
		else
           		ALTERNATE_LDAPSERVERLIST="$ALTERNATE_LDAPSERVERLIST:$LDAP_2"
		fi

		ldap_server_list1=$(remove_from_list "$ldap_server_list1" $LDAP_2)
		tmp_arr=($ldap_server_list1)
        done

        # append closing tags for oes-ldap
        cat <<HERE >>$LDAP_TMP_FILE
    </ldap_servers>
  </oes-ldap>
</profile>
HERE

        merge_xml $LDAP_TMP_FILE ldap_servers
}


#####################################################################
# Name:		get_pci_values					
#
# Description:	utilizes hwinfo to determine device names and their
#		related BusID
#
# Used in:	arguments will be passed to set_pciID()
#####################################################################

get_pci_values()
{
	print_func $FUNCNAME	

        local my_buslist=$(/usr/sbin/hwinfo --netcard|grep -i "SysFS BusID"|sed -re 's/^[^:]+:\s+(.*$)/\1/')

	# if devname contains em - needs to be done for some DELL hardware
	function get_device()
	{
		local org_dev=$1
		local my_pref=$(sed -re 's/^([a-zA-Z]*)[0-9]*.*$/\1/' <<<$org_dev)
		local my_devnum=$(sed -re 's/^([a-zA-Z]*)([0-9]*).*$/\2/' <<<$org_dev)

		if [ $my_devnum -ne 0 -a $my_pref == "em" ];then
			my_devnum=$(($my_devnum -1))
			echo "eth${my_devnum}"
		else
			echo $org_dev   
		fi
	}


        function retr_values()
        {
                local busid=$1
		my_block=$(/usr/sbin/hwinfo --netcard | sed -rne '/^[0-9]{,2}:\s+(PCI|Virtio|None).*Ethernet controller/,/^.*Config Status.*$/Mp'|sed -nr '
                /^\s+Unique ID/ H
                /^\s+SysFS BusID:.*'$busid'.*/ H 
                /^\s+Device File/ H 
                /^\s+Config Status/ {
                x
                s/:\s+/=/g
                s/(\S+)\s(\S+)/\1_\2/g

                        /'$busid'/ {
                        s/^$//
                        p
                        }
                }'
                )

                # generate vars, spaces were converted to '_' some lines above
                if [ -n "$my_block" ];then
                        eval $my_block
			if [ -n "$Device_File" ];then
				Device_File=$(get_device $Device_File)
                        	echo "$Device_File%%$SysFS_BusID"
			fi
                fi
        }

	# execute the real action
        declare -a myarray

        count=0
        for I in $my_buslist;do
                myarray[$count]=$(retr_values $I)
                let count=$count+1
        done

        echo ${myarray[@]}

}


#####################################################################
# Name:		set_pciID
#
# Description:	creates the udev-xml snippet and merges it
#		into the autoyast main driver file to configure
#		pci udev rules for netcards
#
# Used in:	pre-fetch.sh
#####################################################################

function set_pciID()
{
	# bypass this function in case the installation is into a kvm guest
	if [[ ! $1 =~ .*%%vmbus_0_.* ]] && [[ ! $1 =~ .*%%virtio.* ]]
	then
	print_func $FUNCNAME	

        local tmpfile=pcibus.xml
        local arglist="$1"

	# udev pci based vs. mac-address based
	# my_macaddress is only defined in customer_lib.sh for some customers
	if [ -z "$my_macaddress" ]; then
        cat <<HERE >$tmpfile
<?xml version="1.0"?>
<!DOCTYPE profile>
<profile xmlns="http://www.suse.com/1.0/yast2ns" xmlns:config="http://www.suse.com/1.0/configns">
  <networking>
    <net-udev config:type="list">
HERE

        for arg in $arglist;do
                local DEVNAME=$(awk -F"%%" '{print $1}'<<<$arg)
                local PCI_ID=$(awk -F"%%" '{print $2}'<<<$arg)
                cat<<HERE >>$tmpfile
      <rule>
        <name>$DEVNAME</name>
        <rule>KERNELS</rule>
        <value>$PCI_ID</value>
      </rule>
HERE
        done

	# introduced complete else branch for mac-based udev rules
	else
cat <<HERE >$tmpfile
<?xml version="1.0"?>
<!DOCTYPE profile>
<profile xmlns="http://www.suse.com/1.0/yast2ns" xmlns:config="http://www.suse.com/1.0/configns">
  <networking>
    <net-udev config:type="list">
HERE

        for arg in $arglist;do
                local DEVNAME=$(awk -F"%%" '{print $1}'<<<$arg)
                local PCI_ID=$(awk -F"%%" '{print $2}'<<<$arg)
                cat<<HERE >>$tmpfile
      <rule>
        <name>$DEVNAME</name>
        <rule>ATTR{address}</rule>
        <value>%%MAC_ADDRESS%%</value>
      </rule>
HERE

	# remove possible %%MAC_ADDRESS%% entries when installing via IP
	replace_placeholders MAC_ADDRESS " "
        done

	fi

        cat <<HERE >>$tmpfile
    </net-udev>
  </networking>
</profile>
HERE

        merge_xml $tmpfile net-udev
	fi
}


#####################################################################
#
#	MULTIPLE VALUE HANDLING
#
#####################################################################
#
# Name:		split_list
#
# Description:	removes ":" from a multi value field and returns
#		a space separated list
#
# Used in:	merge_oes_files, prepare_lists, ret_firstval_list
#####################################################################

function split_list()
{
        local list="$1"
        local search_items=$(tr : " " <<<$list)
	echo "$search_items"
}


#####################################################################
# Name:		ret_firstval_list
#
# Description:	returns the first value from a colon separated list
#
# Used in:	do_replace
#####################################################################

function ret_firstval_list()
{
        local list=$(split_list "$1")
	local first_list_item=${list%% *}
        echo $first_list_item
}


#####################################################################
# Name:		prepare_lists
#
# Description:	deals with some multi value tags which occur only
#		as one liner in contrast to the xml entries for 
#		ntp servers or oes ldap servers
#
# Used in:	multi_value
#####################################################################

function prepare_lists()
{
        local my_list=$1
        local entry_type=$2
        local f
	for f in $(split_list $my_list);
        do
                if [ -n "$f" ];then
                        if   [ "$entry_type" == "nameserver" ];then
                                echo -e "<nameserver>$f</nameserver>"
                        elif [ "$entry_type" == "domainlist" ];then
                                echo -e "<search>$f</search>"
                        elif [ "$entry_type" == "slpdalist" ];then
                                echo -e "<listentry>$f</listentry>"
                        elif [ "$entry_type" == "ntpserverlist" ];then
                                echo -e "<listentry>$f</listentry>"
                        elif [ "$entry_type" == "alternate_ldapserverlist" ];then
                                echo -e "<listentry>$f</listentry>"
			else
                                :
                        fi
                fi
        done
}


#####################################################################
# Name:		multi_value
#
# Description:	handles multi-value fields from configuration files
#
# Used in:	pre-fetch.sh
#####################################################################

function multi_value()
{
	print_func $FUNCNAME	

	# $NAME_SERVER_LIST, $NTP_SERVER_LIST, $SUFFIX_SEARCH_LIST and
	# $SLPDA_LIST come from CUSTOMER.txt, from $AY_TREE_FILE or from
	# $my_location_file
        local nameservers=$(prepare_lists "$NAME_SERVER_LIST" nameserver)
        local ntpserverlist=$(prepare_lists "$NTP_SERVER_LIST" ntpserverlist)
        local searchlist=$(prepare_lists "$SUFFIX_SEARCH_LIST" domainlist)
        local slpserverlist=$(prepare_lists "$SLPDA_SERVER_LIST" slpdalist)
        local alternate_ldapserverlist=$(prepare_lists "$ALTERNATE_LDAPSERVERLIST" alternate_ldapserverlist)

        # derive namservers
        for i in $nameservers;do
                insert_before_placeholder %%NAME_SERVER_LIST%% $i
        done
        delete_placeholders NAME_SERVER_LIST

        # derive ntpservers
        for i in $ntpserverlist;do
                insert_before_placeholder %%NTP_SERVER_LIST%% $i
        done
        delete_placeholders NTP_SERVER_LIST

        # derive searchlist
        for i in $searchlist;do
                insert_before_placeholder %%SUFFIX_SEARCH_LIST%% $i
        done
        delete_placeholders SUFFIX_SEARCH_LIST

        # derive slp
        for i in $slpserverlist;do
                insert_before_placeholder %%SLPDA_SERVER_LIST%% $i
        done
        delete_placeholders SLPDA_SERVER_LIST

        # derive alternative ldap server list
        for i in $alternate_ldapserverlist;do
                insert_before_placeholder %%ALTERNATE_LDAP_SERVER%% $i
        done
        delete_placeholders ALTERNATE_LDAP_SERVER

	# replace colons with comas as required in <slp_scopes>
	local my_scopes=$(tr : , <<<$SLP_SCOPE_LIST)
	replace_placeholders SLP_SCOPE_LIST "$my_scopes"
}


#####################################################################
# Name:		merge_service_files
#
# Description:	derives which oes xml files to use from service_type
#		($my_service_type and CUSTOMER.txt) and merges them
#		with the main autoyast driver file
#
# Used in:	make_server()
#####################################################################

function merge_service_files()
{
	print_func $FUNCNAME	

	if [ -n "$my_service_type" ];then
		local file	
		local xml_list=$(split_list $(eval echo \$${my_service_type}))
		# retrieve files from  $AY_SERVICES_DIR_URL
		for file in $xml_list;do
			process_xml $file dummy_tag $AY_SERVICES_DIR extra
		done
	fi

}


#####################################################################
#
#	SERVER_TYPE HANDLING
#
#####################################################################
#
# Name:		make_server
#
# Description:	handling of add_on products and oes xml files
#		depending on the server type
#
# Used in:	pre-fetch.sh
#####################################################################

function make_server
{
        local my_servertype=$1
        tmp_server_type=$(tr A-Z a-z <<<$my_servertype)

        # derives product e.g. sles or oes
        my_product=$(sed -r -e 's/^([a-z]*).*$/\1/'<<<$tmp_server_type)

        # derives version e.g. 11 or 2
        my_release=$(sed -r -e 's/^([a-z]*)([0-9]*).*$/\2/'<<<$tmp_server_type)

        # derives feature pack e.g. fp0 or fp1
	my_fp=$(sed -r -e's/^([a-z]*)([0-9]*)(fp[0-9])*(sp[0-9]*|gm|ga).*$/\3/' <<<$tmp_server_type)

        # derives service pack e.g. sp1 or sp3
        my_sp=$(sed -r -e's/^([a-z]*)([0-9]*)(fp[0-9])*(sp[0-9]*|gm|ga).*$/\4/' <<<$tmp_server_type)
        if [ $(egrep -qi "(sp|gm|ga)" <<<$my_sp; echo $?) -ne 0 ];then
                unset my_sp
        fi


        # look into the software or partitioning fields in the server configuration file
	# (server.txt) and retrieve the appropriate files
	# argument 2  = tag, argument 3 = subdir below $AY_FILE_DIR (autoyast/files)
	process_xml $my_partfile partitioning partitioning extra
	process_xml $my_software_file software software extra
        process_xml addon_products-${my_server_type}.xml add-on addon extra

	# merge files like kdump.xml, oes-snippets, etc.
	merge_service_files

	# Query passwords if installing OES
	#
	# OES:    admin_context		 is the eDir install user
	# DSfW:   admin_context		 is the DSfW Administrator user
	# 	  xad_tree_admin_context is the eDir install user
	# NSS-AD: admin_name		 is the AD Administrator user
	if [ "$my_product" == "oes" -a -z "$NO_OES_PWD" ];then

		local xml_list=$(split_list $(eval echo \$${my_service_type}))

		# is this a DSfW FRD FDC?
		grep $FRD_FDC_XML_FILE <<<"$xml_list"
		if [ $? -eq 0 ]; then
			process_xml ask-dsfw-frd.xml ask-list ask
		else
			# is this a DSfW FRD ADC?
			grep $FRD_ADC_XML_FILE <<<"$xml_list"
			if [ $? -eq 0 ]; then
				process_xml ask-dsfw-frd.xml ask-list ask
			# non-DSfW server
			else
				process_xml ask.xml ask-list ask
			fi
		fi
		
		# query password for AD join for AD integrated OES servers (OES2015 and later)
		local xml_list=$(split_list $(eval echo \$${my_service_type}))
		grep $NSS_AD_XML_FILE <<<"$xml_list"
		if [ $? -eq 0 ]; then
			ask_nss_ad_uri=${AY_XML_CLASS_DIR_URL}/ask/$NSS_AD_ASK_XML_FILE
			get_file $ask_nss_ad_uri
			dont_merge_xml $NSS_AD_ASK_XML_FILE ask
		fi

		create_ldap_entries "$(split_list $LDAP_SERVER_LIST)"

	fi

	# remove 32-bit entries from software files if 32-bit system is being installed 
        if [ "$(guess_arch)" == "i586" ];then
                remove_32
        fi

        # create ntp server xml
        create_ntp_sles "$(split_list $NTP_SERVER_LIST)"

        if [ "$my_product" == "caasp" ]; then
		# caasp v3 needs adjustments in other places / scripts due to missing stage 2 in YaST

        	# replace settings for NTP_SERVER in CAASP
        	replace_placeholders NTP_SERVER_LIST_CAASP "$(split_list $NTP_SERVER_LIST)"

        	# replace settings for NAME_SERVER in CAASP
        	replace_placeholders NAME_SERVER_LIST_CAASP "$(split_list $NAME_SERVER_LIST)"

        	# replace settings for SUFFIX_SEARCH_LIST in CAASP
        	replace_placeholders SUFFIX_SEARCH_LIST_CAASP "$(split_list $SUFFIX_SEARCH_LIST)"
        fi
}


#####################################################################
# Name:		get_customer_configuration_file
#
# Description:	determines tree_name and location configuration files
#		retrieves and evaluates these files
#
# Used in:	pre-fetch.sh
#####################################################################

function get_customer_configuration_file()
{
	print_func $FUNCNAME

	# customer configuration file (default: CUSTOMER.txt)
	if [ -n "$AY_CUSTOMER_FILE" ];then
		source_file $AY_CONFIG_DIR_URL $AY_CUSTOMER_FILE
	fi	
}


#####################################################################
# Name:		get_customer_config_files
#
# Description:	determines tree_name and location configuration files
#		retrieves and evaluates these files
#
# Used in:	pre-fetch.sh
#####################################################################

function get_customer_config_files()
{
	print_func $FUNCNAME

	# tree_file
	if [ -n "$my_tree_name" ];then
		local my_tree_file=$my_tree_name.txt

		source_file $AY_CONFIG_DIR_URL $my_tree_file
	fi

	# location_file
	if [ -n "$my_location_file" ];then
		source_file $AY_CONFIG_DIR_URL $my_location_file
	fi
}


#####################################################################
# Name:		source_file
#
# Description:	retrieves file from param 1 and sources it
#
# Used in:	get_customer_configuration_file
#		get_customer_config_files
#####################################################################

function source_file()
{
	print_func $FUNCNAME	

	local my_URL=$1
	local my_file=$2
	get_file $my_URL/$my_file
	if [ $? -eq 0 ];then
		source ./$my_file
	else
		echo -ne "\nfile $my_URL/$my_file not found\n"
	fi
}


#####################################################################
# Name:		return_service_ctx
#
# Description:	specifies a different context for the service object
# 		than the default server context
#
#		Parm 1 placeholder in xml file,
#		 e.g. DHCP_SERVER_CONTEXT
#		Parm 2 default server context, 
#		 e.g. ou=servers,ou=services,ou=department,o=company
#		Parm 3 target container name and number of containers 
#		 upwards relativ to server context from Parm 2, e.g.:
# 		 "ou=dhcp;3"
#
#		example execution: return_service_ctx
#		 DHCP_SERVER_CTX ou=servers,ou=services,o=novell "ou=dhcp;3"
#
# Used in:	pre-fetch.sh
#####################################################################

function return_service_ctx()
{
	local place_holder=$1
	local server_ctx=$2
	local target_service_ctx=$3
	local final_ctx

	# no context specified within config file -> return default 
	# server context

	if [ -z "$target_service_ctx" ];then
		final_ctx=$server_ctx

	# no level specified -> prepend target context to server context
	elif  [ -z "$(awk -F';' '{print $2}'<<<$target_service_ctx)" ];then
		final_ctx="$target_service_ctx,$server_ctx"

	# level and target context specified -> remove n levels from 
	# server context and prepend target context
	else
		local step_number=$(awk -F';' '{print $2}'<<<$target_service_ctx)
		target_service_ctx=$(awk -F';' '{print $1}'<<<$target_service_ctx)
		final_ctx="$target_service_ctx,$(sed -e \
		"s#^\([^,]\+,\)\{$step_number\}##" <<<$server_ctx)"
	fi

	replace_placeholders $place_holder "$final_ctx"
}


#####################################################################
# Name:		get_ay_config_base
#
# Description:	searches for parameter AY_CONFIG_BASE in /proc/cmdline
# 		and returns it if found
#
# Used in:	pre-fetch.sh
#####################################################################

function get_ay_config_base()
{
	AY_CONFIG_BASE=$(sed -rne /AY_CONFIG_BASE/{'s/^.*AY_CONFIG_BASE=([^ ]*).*$/\1/p'} <<<$(cat /proc/cmdline))
	echo -n "$AY_CONFIG_BASE"
}
