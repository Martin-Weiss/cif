#!/bin/bash
set -x
. export.sh
terraform init
terraform plan
terraform apply -auto-approve
ssh-keygen -R caasp-admin.esx.local -f /root/.ssh/known_hosts
scp -o "StrictHostKeyChecking no" /root/.ssh/id_rsa caaspadm@caasp-admin.esx.local:~/.ssh/
ssh -o "StrictHostKeyChecking no" caaspadm@caasp-admin.esx.local 'bash -s' < cluster.sh
