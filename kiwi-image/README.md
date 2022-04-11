Idea is to build image with kiwi using SUSE Manager
Then upload to vsphere and create a template

Dependencies
- govc (to upload image to vsphere)
- kiwi-ng (to build the image)
- ovftool (in path for kiwi-ng)

Prepare
- Git clone
- Create and adjust export.sh based on export.sh.examlpe
- Adjust build.sh (ensure the right repos are connected)
- Adjust config.sh and config.xml based on your needs

Process (manual)
1. build.sh (create the image based on config.xml and config.sh with ova format for vmware)
2. deploy.sh (upload image to vsphere)
