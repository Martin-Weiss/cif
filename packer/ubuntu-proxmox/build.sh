../packer validate ubuntu.json
../packer build -var-file="config.json" ubuntu.json
