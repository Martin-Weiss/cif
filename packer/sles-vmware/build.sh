#!/bin/bash
#../packer validate -var-file=vars.json sles.json
../packer build -var-file=vars.json sles.json
#../packer build -debug -var-file=vars.json sles.json
