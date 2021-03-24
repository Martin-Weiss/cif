#!/bin/bash
. ./export.sh
eval $(ssh-agent)
ssh-add
terraform destroy

for SERVER in $(cat server.txt|grep -v servername|cut -f1 -d ","); do
        echo deleting $SERVER
	DOMAIN=$(grep $SERVER server.txt|cut -f6 -s ",")
        /usr/bin/spacecmd -y -- system_delete -c NO_CLEANUP $SERVER.$DOMAIN
        sed -i "/$SERVER/d" /root/.ssh/known_hosts
done
kill $SSH_AGENT_PID
