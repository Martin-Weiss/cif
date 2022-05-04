#!/bin/bash

# need ovf tool for ova build!
# From https://developer.vmware.com/web/tool/4.4.0/ovf
#if [ ! -d ovftool ]; then
#	wget -N https://vdc-download.vmware.com/vmwb-repository/dcr-public/2ee5a010-babf-450b-ab53-fb2fa4de79af/2a136212-2f83-4f5d-a419-232f34dc08cf/VMware-ovftool-4.4.3-18663434-lin.aarm64.zip
#	unzip -q -o VMware-ovftool-4.4.3-18663434-lin.aarm64.zip
#	echo VMware-ovftool-4.4.3-18663434-lin.aarm64.zip >.gitignore
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
kiwi-ng --profile RaspberryPi system build --target-dir $TARGET_DIR/image --description $TARGET_DIR \
--add-repo http://susemanager.suse/pub/isos/sles15sp3a64/,repo-md,sles15sp3a64iso,1,true,false \
--add-repo http://susemanager.suse/ks/dist/sles15sp3a64/,repo-md,SLE-Product-SLES15-SP3-Pool,1,true,false \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-product-sles15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Product-SLES15-SP3-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-basesystem15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SLE-Module-Basesystem15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-basesystem15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Module-Basesystem15-SP3-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-devtools15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SLE-Module-DevTools15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-devtools15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Module-DevTools15-SP3-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-server-applications15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SLE-Module-Server-Applications15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-server-applications15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Module-Server-Applications15-SP3-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-desktop-applications15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SLE-Module-Desktop-Applications15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-desktop-applications15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Module-Desktop-Applications15-SP3-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-containers15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SLE-Module-Containers15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-containers15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Module-Containers15-SP3-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-packagehub-subpackages15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SLE-Module-Packagehub-Subpackages15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-packagehub-subpackages15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Module-Packagehub-Subpackages15-SP3-Update \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-public-cloud15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SLE-Module-Public-Cloud15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sle-module-public-cloud15-sp3-updates-aarch64/sles15sp3a64/,repo-md,SLE-Module-Public-Cloud15-SP3-Updates \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-suse-packagehub-15-sp3-backports-pool-aarch64/sles15sp3a64/,repo-md,SUSE-PackageHub-15-SP3-Backports-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-suse-packagehub-15-sp3-pool-aarch64/sles15sp3a64/,repo-md,SUSE-PackageHub-15-SP3-Pool \
--add-repo http://susemanager.suse/ks/dist/child/staging-sles15sp3a64-test-sles15sp3a64-ptfs/sles15sp3a64/,repo-md,sles15sp3a64-ptfs \

# create bundle
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
kiwi-ng result bundle --target-dir $TARGET_DIR/image --bundle-dir=$TARGET_DIR/image-bundle --id=0
