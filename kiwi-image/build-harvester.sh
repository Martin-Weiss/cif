#!/bin/bash

# need ovf tool for ova build!
# From https://developer.vmware.com/web/tool/4.4.0/ovf
#if [ ! -d ovftool ]; then
#	wget -N https://vdc-download.vmware.com/vmwb-repository/dcr-public/2ee5a010-babf-450b-ab53-fb2fa4de79af/2a136212-2f83-4f5d-a419-232f34dc08cf/VMware-ovftool-4.4.3-18663434-lin.x86_64.zip
#	unzip -q -o VMware-ovftool-4.4.3-18663434-lin.x86_64.zip
#	echo VMware-ovftool-4.4.3-18663434-lin.x86_64.zip >.gitignore
#	echo "ovftool" >>.gitignore
#	echo "image" >>.gitignore
#	echo "image-bundle" >>.gitignore
#fi

# need to set the path to ovftool for kiwi build
#export PATH=$PATH:/data/git/kiwi-image/ovftool

# set variables
TARGET_DIR=.

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

# build the image
kiwi-ng --profile harvester system build --target-dir $TARGET_DIR/image --description $TARGET_DIR \
--add-repo http://weiss-2.weiss.ddnss.de/sles15sp4/,repo-md,sles15sp4,1,true,false \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Product-SLES/15-SP4/x86_64/product/,repo-md,SLE-Product-SLES15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Product-SLES/15-SP4/x86_64/update/,repo-md,SLE-Product-SLES15-SP4-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Basesystem/15-SP4/x86_64/product/,repo-md,SLE-Module-Basesystem15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Basesystem/15-SP4/x86_64/update/,repo-md,SLE-Module-Basesystem15-SP4-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Server-Applications/15-SP4/x86_64/product/,repo-md,SLE-Module-Server-Applications15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Server-Applications/15-SP4/x86_64/update/,repo-md,SLE-Module-Server-Applications15-SP4-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Containers/15-SP4/x86_64/product/,repo-md,SLE-Module-Containers15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Containers/15-SP4/x86_64/update/,repo-md,SLE-Module-Containers15-SP4-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Packagehub-Subpackages/15-SP4/x86_64/product/,repo-md,SLE-Module-Packagehub-Subpackages15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Packagehub-Subpackages/15-SP4/x86_64/update/,repo-md,SLE-Module-Packagehub-Subpackages15-SP4-Update \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Public-Cloud/15-SP4/x86_64/product/,repo-md,SLE-Module-Public-Cloud15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Public-Cloud/15-SP4/x86_64/update/,repo-md,SLE-Module-Public-Cloud15-SP4-Updates \
--add-repo http://smt.suse/repo/SUSE/Backports/SLE-15-SP4_x86_64/standard/,repo-md,SUSE-PackageHub-15-SP4-Backports-Pool \
--add-repo http://smt.suse/repo/SUSE/Backports/SLE-15-SP4_x86_64/product/,repo-md,SUSE-PackageHub-15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Development-Tools/15-SP4/x86_64/product/,repo-md,SLE-Module-DevTools15-SP4-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Development-Tools/15-SP4/x86_64/update/,repo-md,SLE-Module-DevTools15-SP4-Updates

# create bundle
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
kiwi-ng result bundle --target-dir $TARGET_DIR/image --bundle-dir=$TARGET_DIR/image-bundle --id=0
