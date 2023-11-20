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
--add-repo http://weiss-2.weiss.ddnss.de/sles15sp5/,repo-md,sles15sp5,1,true,false \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Product-SLES/15-SP5/x86_64/product/,repo-md,SLE-Product-SLES15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Product-SLES/15-SP5/x86_64/update/,repo-md,SLE-Product-SLES15-SP5-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Basesystem/15-SP5/x86_64/product/,repo-md,SLE-Module-Basesystem15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Basesystem/15-SP5/x86_64/update/,repo-md,SLE-Module-Basesystem15-SP5-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Server-Applications/15-SP5/x86_64/product/,repo-md,SLE-Module-Server-Applications15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Server-Applications/15-SP5/x86_64/update/,repo-md,SLE-Module-Server-Applications15-SP5-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Containers/15-SP5/x86_64/product/,repo-md,SLE-Module-Containers15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Containers/15-SP5/x86_64/update/,repo-md,SLE-Module-Containers15-SP5-Updates \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Packagehub-Subpackages/15-SP5/x86_64/product/,repo-md,SLE-Module-Packagehub-Subpackages15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Packagehub-Subpackages/15-SP5/x86_64/update/,repo-md,SLE-Module-Packagehub-Subpackages15-SP5-Update \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Public-Cloud/15-SP5/x86_64/product/,repo-md,SLE-Module-Public-Cloud15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Public-Cloud/15-SP5/x86_64/update/,repo-md,SLE-Module-Public-Cloud15-SP5-Updates \
--add-repo http://smt.suse/repo/SUSE/Backports/SLE-15-SP5_x86_64/standard/,repo-md,SUSE-PackageHub-15-SP5-Backports-Pool \
--add-repo http://smt.suse/repo/SUSE/Backports/SLE-15-SP5_x86_64/product/,repo-md,SUSE-PackageHub-15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Products/SLE-Module-Development-Tools/15-SP5/x86_64/product/,repo-md,SLE-Module-DevTools15-SP5-Pool \
--add-repo http://smt.suse/repo/SUSE/Updates/SLE-Module-Development-Tools/15-SP5/x86_64/update/,repo-md,SLE-Module-DevTools15-SP5-Updates

# create bundle
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
kiwi-ng result bundle --target-dir $TARGET_DIR/image --bundle-dir=$TARGET_DIR/image-bundle --id=0
