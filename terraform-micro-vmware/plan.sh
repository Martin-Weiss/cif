#!/bin/bash
. ./export.sh
eval $(ssh-agent)
ssh-add
terraform plan
kill $SSH_AGENT_PID
