Idea is to build image with kiwi using SUSE Manager
Then upload to vsphere and create a template

Dependencies
- govc (to upload image to vsphere)
- kiwi-ng (to build the image)
- ovftool (in path for kiwi-ng)

Prepare
- Git clone
- Adjust export.sh
- Adjust build.sh (repos)
- Adjust config.sh and config.xml based on your needs

Process (manual)
1. build.sh (create the image based on config.xml and config.sh with ova format for vmware)
2. deploy.sh (upload image to vsphere)

HINT:
- KIWI Sources from https://build.opensuse.org/package/show/SUSE:SLE-15-SP5:Update:Products:Micro55/SLE-Micro
