#!/bin/bash
#
# Author: Jochen Schäfer <jschaef@novell.com>, 2001-2013
# 
# copyright (c) Novell Deutschland GmbH, 2013. All rights reserved.
# GNU Public License
#
# create-ay-cd-v01.sh 					27 Apr 2013
# last modified (Customer Name)				26 Nov 2018


ARGV=$@

debug=0
function debug()
{
	if [ "$debug" == "1" ];then
		set -x
	else
		set +x
	fi
}

function usage()
{
	cat <<HERE
usage $0
        --name		# name of the iso
			# default: $ISO_NAME
	--workdir	# top level directory where the boot and grub 
			# directory are located
			# default: $WORK_DIR
	--isodir	# output directory where the iso file will be created
			# default: $ISO_DIR
	--debug         # optional - increases verbosity
	--help		# this help


        example1: $0
        example2: $0 --name $ISO_NAME --workdir $WORK_DIR --isodir $ISO_DIR --debug

HERE
	exit 1
}


function getopt()
{
	while [ $# -gt 0 ];do
		case $1 in --name) ISO_NAME=$2;shift;;
			   --workdir) WORK_DIR=$2;shift;;
			   --isodir) ISO_DIR=$2;shift;;
			   --debug) debug=1;debug;;
			   *) usage;;
		esac
		shift
	done	

	if [ -n "$WORK_DIR" -a ! -d "$WORK_DIR" ]; then
		echo directory "$WORK_DIR" does not exists
		usage
	fi

	if [ -n "$ISO_DIR" -a ! -d "$ISO_DIR" ]; then
		echo directory "$ISO_DIR" does not exists
		usage
	fi
}


function set_vars()
{
	CUSTOMER="SUSE"
	ISO_PREF=autoyast-$(tr A-Z a-z <<<$CUSTOMER)
	ISO_NAME=$ISO_PREF.iso
	WORK_DIR=/data/boot_cd_build
	DEF_ISO_DIR=/srv/www/htdocs/isos
	ISO_DIR=$DEF_ISO_DIR
	MY_DATE=$(date +%Y-%m-%d_%H%M)
	ISO_NAME_COPIED=$ISO_PREF.iso.$MY_DATE
	ISO_LABEL="AUTOYAST-$CUSTOMER"
}


function make_iso()
{
	test -f "$ISO_DIR/$ISO_NAME" && cp -p "$ISO_DIR/$ISO_NAME" $DEF_ISO_DIR/$ISO_NAME_COPIED
	
	mkisofs -f -rV "$ISO_LABEL" -b boot/grub/iso9660_stage1_5 -no-emul-boot -boot-load-size \
        4 -boot-info-table -D -o $ISO_DIR/$ISO_NAME $WORK_DIR
}	

function make_info()
{
	cat <<HERE


You will find the IMAGE here: $ISO_DIR/$ISO_NAME

HERE
}

function main()
{
	set_vars
	getopt  $ARGV
	make_iso
	make_info
}

main
