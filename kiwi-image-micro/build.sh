#!/bin/bash

# need ovf tool for ova build!
# From https://developer.vmware.com/web/tool/4.4.0/ovf
if [ ! -d ovftool ]; then
	wget -N https://vdc-download.vmware.com/vmwb-repository/dcr-public/2ee5a010-babf-450b-ab53-fb2fa4de79af/2a136212-2f83-4f5d-a419-232f34dc08cf/VMware-ovftool-4.4.3-18663434-lin.x86_64.zip
	unzip -q -o VMware-ovftool-4.4.3-18663434-lin.x86_64.zip
	echo VMware-ovftool-4.4.3-18663434-lin.x86_64.zip >.gitignore
	echo "ovftool" >>.gitignore
	echo "image" >>.gitignore
	echo "image-bundle" >>.gitignore
fi

# need to set the path to ovftool for kiwi build
export PATH=$PATH:/data/git/kiwi-image/ovftool

# set variables
TARGET_DIR=.

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

# build the image
kiwi-ng --profile vmware system build --target-dir $TARGET_DIR/image --description $TARGET_DIR \
--add-repo http://smt.suse/repo/SUSE/Products/SUSE-MicroOS/5.2/x86_64/product/,repo-md,SUSE-MicroOS-5.2-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SUSE-MicroOS/5.2/x86_64/update/,repo-md,SUSE-MicroOS-5.2-Updates

# create bundle
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
kiwi-ng result bundle --target-dir $TARGET_DIR/image --bundle-dir=$TARGET_DIR/image-bundle --id=0
