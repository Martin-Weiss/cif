#!/bin/bash

# need ovf tool for ova build!
# From https://developer.vmware.com/web/tool/ovf-tool/
if [ ! -d ovftool ]; then
	wget -N https://vdc-download.vmware.com/vmwb-repository/dcr-public/8a93ce23-4f88-4ae8-b067-ae174291e98f/c609234d-59f2-4758-a113-0ec5bbe4b120/VMware-ovftool-4.6.2-22220919-lin.x86_64.zip -O VMware-ovftool.zip
	unzip -q -o VMware-ovftool.zip
	echo VMware-ovftool.zip >.gitignore
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
--add-repo http://smt.suse/SUSE/Products/SLE-Micro/5.5/x86_64/product/,repo-md,SLE-Micro-5.5-Pool \
--add-repo http://smt.suse/SUSE/Updates/SLE-Micro/5.5/x86_64/update/,repo-md,SLE-Micro-5.5-Updates \
--add-repo http://susemanager.suse/pub/sles15sp5-ptfs,repo-md,sles15sp5-ptfs

#--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5-prod-sles15sp5-ptfs/sles15sp5/,repo-md,sles15sp5-ptfs

# create bundle
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
kiwi-ng result bundle --target-dir $TARGET_DIR/image --bundle-dir=$TARGET_DIR/image-bundle --id=0
