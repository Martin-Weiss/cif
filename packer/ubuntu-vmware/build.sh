#!/bin/bash
../packer validate -var-file=vars.json ubuntu.json
../packer build -var-file=vars.json ubuntu.json
