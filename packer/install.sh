#!/bin/bash
wget -N https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_linux_amd64.zip
unzip -o packer_1.7.2_linux_amd64.zip
echo "packer" > .gitignore
echo "packer_1.7.2_linux_amd64.zip" >> .gitignore
