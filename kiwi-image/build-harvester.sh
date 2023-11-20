#!/bin/bash

# set variables
TARGET_DIR=.

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

# build the image
kiwi-ng --profile harvester system build --target-dir $TARGET_DIR/image --description $TARGET_DIR \
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
