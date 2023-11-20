#!/bin/bash

# set variables
TARGET_DIR=.

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

# build the image
kiwi-ng --profile RaspberryPi-xfs system build --target-dir $TARGET_DIR/image --description $TARGET_DIR \
--add-repo http://susemanager.suse/pub/isos/sles15sp5a64/,repo-md,sles15sp5a64iso,1,true,false \
--add-repo http://susemanager.suse/ks/dist/sles15sp5a64/,repo-md,SLE-Product-SLES15-SP5-Pool,1,true,false \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-product-sles15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Product-SLES15-SP5-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-basesystem15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SLE-Module-Basesystem15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-basesystem15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Module-Basesystem15-SP5-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-devtools15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SLE-Module-DevTools15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-devtools15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Module-DevTools15-SP5-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-server-applications15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SLE-Module-Server-Applications15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-server-applications15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Module-Server-Applications15-SP5-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-desktop-applications15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SLE-Module-Desktop-Applications15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-desktop-applications15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Module-Desktop-Applications15-SP5-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-containers15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SLE-Module-Containers15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-containers15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Module-Containers15-SP5-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-packagehub-subpackages15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SLE-Module-Packagehub-Subpackages15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-packagehub-subpackages15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Module-Packagehub-Subpackages15-SP5-Update \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-public-cloud15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SLE-Module-Public-Cloud15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sle-module-public-cloud15-sp5-updates-aarch64/sles15sp5a64/,repo-md,SLE-Module-Public-Cloud15-SP5-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-suse-packagehub-15-sp5-backports-pool-aarch64/sles15sp5a64/,repo-md,SUSE-PackageHub-15-SP5-Backports-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-suse-packagehub-15-sp5-pool-aarch64/sles15sp5a64/,repo-md,SUSE-PackageHub-15-SP5-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp5a64-test-sles15sp5a64-ptfs/sles15sp5a64/,repo-md,sles15sp5a64-ptfs \

# create bundle
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
kiwi-ng result bundle --target-dir $TARGET_DIR/image --bundle-dir=$TARGET_DIR/image-bundle --id=0
