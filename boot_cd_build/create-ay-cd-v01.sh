#!/bin/bash
#
# Author: Jochen Schäfer <jschaef@novell.com>, 2001-2013
# 
# copyright (c) Novell Deutschland GmbH, 2013. All rights reserved.
# GNU Public License
#
# create-ay-cd-v01.sh 					27 Apr 2013
# change copy to move for backup			25 Feb 2019
# add efi boot via grub2				13 May 2019
# last modified (Customer Name)				13 May 2019


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
	ISO_LABEL="AUTOYAST_$CUSTOMER"
	TEMP_DIR="/tmp"
}

function prepare_efi()
{
	grub2-mkstandalone --format=x86_64-efi --output=$TEMP_DIR/bootx64.efi --locales="" --fonts="" "boot/grub/grub.cfg=$WORK_DIR/grub2.cfg" --modules="efi_gop efi_uga all_video gzio gettext gfxterm gfxmenu png"
	dd if=/dev/zero of=$TEMP_DIR/efiboot.img bs=1M count=10 && mkfs.vfat $TEMP_DIR/efiboot.img && mmd -i $TEMP_DIR/efiboot.img efi efi/boot && mcopy -i $TEMP_DIR/efiboot.img $TEMP_DIR/bootx64.efi ::efi/boot/
}

function make_iso()
{
	test -f "$ISO_DIR/$ISO_NAME" && mv "$ISO_DIR/$ISO_NAME" $DEF_ISO_DIR/$ISO_NAME_COPIED
	
	xorriso -as mkisofs \
	-volid "$ISO_LABEL" \
	-full-iso9660-filenames \
	-J -joliet-long -l -R -rock \
	-no-emul-boot -boot-load-size 4 \
	-boot-info-table \
	-iso-level 4 \
	-b boot/grub/iso9660_stage1_5 -no-emul-boot -boot-load-size 4 -boot-info-table \
	-eltorito-alt-boot -e EFI/efiboot.img -no-emul-boot -append_partition 2 0xef $TEMP_DIR/efiboot.img \
	-output $ISO_DIR/$ISO_NAME \
 	--graft-points "$WORK_DIR" "/EFI/efiboot.img=$TEMP_DIR/efiboot.img"
}	

function make_info()
{
	cat <<HERE


You will find the IMAGE here: $ISO_DIR/$ISO_NAME

HERE
}

function clean_up()
{
	rm /tmp/efiboot.img /tmp/bootx64.efi
}

function main()
{
	set_vars
	getopt  $ARGV
	prepare_efi
	make_iso
	make_info
	clean_up
}

main

