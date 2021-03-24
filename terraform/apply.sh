#!/bin/bash
. ./export.sh
eval $(ssh-agent)
ssh-add
terraform apply
kill $SSH_AGENT_PID
