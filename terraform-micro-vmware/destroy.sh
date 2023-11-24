#!/bin/bash
. ./export.sh
eval $(ssh-agent)
ssh-add
terraform destroy

for SERVER in $(cat server.txt|grep -v servername|cut -f1 -d ","); do
        echo deleting $SERVER
	DOMAIN=$(grep $SERVER server.txt|cut -f6 -d ",")
        /usr/bin/spacecmd -y -- system_delete -c NO_CLEANUP $SERVER.$DOMAIN
        sed -i "/$SERVER/d" /root/.ssh/known_hosts
	ssh-keygen -f ~/.ssh/known_hosts -R "$SERVER"
	#ssh-keygen -f ~/.ssh/known_hosts -R "$(host $SERVER|sed 's/.*address //g')"
	ssh-keygen -f ~/.ssh/known_hosts -R "$(grep "^$SERVER," server.txt|cut -f2 -d ","|cut -f1 -d "/")"
done
kill $SSH_AGENT_PID
