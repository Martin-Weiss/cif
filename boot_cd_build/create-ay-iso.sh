#!/bin/bash
#
# Author: Jochen Schaefer <jochen.schaefer@suse.com>
#         Frieder Schmidt <frieder.schmidt@microfocus.com>
#         Martin Weiss    <martin.weiss@suse.com>
#
# copyright (c) Novell Deutschland GmbH, 2001-2020. All rights reserved.
# GNU Public License
#
# create-ay-cd-v01.sh 					27 Apr 2013
# change copy to move for backup			25 Feb 2019
# add efi boot via grub2				13 May 2019
# last modified (Customer Name command line parameter)	 6 May 2020

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
	clear
	cat <<HERE

usage $0
	--customer	# customer name; will be part of the name of the ISO file that is created
			# default: $CUSTOMER
	--name		# complete name of the ISO file that is created (should end in ".iso")
			# default: $ISO_NAME
	--workdir	# directory where the directories EFI, boot, grub, grub2-efi, and kernel are located
			# default: $WORK_DIR
	--isodir	# directory where the iso file is created
			# default: $ISO_DIR
	--debug         # optional - increases verbosity
	--help		# this help


        example1: $0
        example2: $0 --customer $CUSTOMER --name $ISO_NAME --workdir $WORK_DIR --isodir $ISO_DIR --debug

HERE
	exit 1
}


function getopt()
{
	while [ $# -gt 0 ];do
		case $1 in --customer) CUSTOMER=$2;shift;;
			   --name) ISO_NAME=$2;shift;;
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
	MY_DATE=$(date +%Y-%m-%d_%H%M)

	CUSTOMER=${CUSTOMER:="CIF"}
	ISO_DIR=${ISO_DIR:="/data/isos"}
	ISO_LABEL="AUTOYAST_$CUSTOMER"
	ISO_PREF=autoyast-$(tr A-Z a-z <<<$CUSTOMER)
	ISO_NAME=${ISO_NAME:="$ISO_PREF.iso"}
	ISO_NAME_COPIED=$ISO_NAME.$MY_DATE
	WORK_DIR=${WORK_DIR:="/data/boot_cd_build_efi"}
	TEMP_DIR="/tmp"
}


function prepare_efi()
{
	grub2-mkstandalone --format=x86_64-efi --output=$TEMP_DIR/bootx64.efi --locales="" --fonts=""\
	       		   "boot/grub/grub.cfg=$WORK_DIR/EFI/grub2.cfg" --modules="efi_gop efi_uga all_video gzio gettext gfxterm gfxmenu png"
	dd if=/dev/zero of=$TEMP_DIR/efiboot.img bs=1M count=10 && mkfs.vfat $TEMP_DIR/efiboot.img\
	       		   && mmd -i $TEMP_DIR/efiboot.img efi efi/boot && mcopy -i $TEMP_DIR/efiboot.img $TEMP_DIR/bootx64.efi ::efi/boot/
}


function make_iso()
{
	test -f "$ISO_DIR/$ISO_NAME" && mv "$ISO_DIR/$ISO_NAME" $ISO_DIR/$ISO_NAME_COPIED
	
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

function print_info()
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
	getopt  $ARGV
	set_vars
	prepare_efi
	make_iso
	print_info
	clean_up
}

main

