#!/bin/bash
set -x
## make sure skuba is installed before starting

while true
do
  ps -ef | grep zypper | grep -v grep
  [[ $? -gt 0 ]] && break
done


eval $(ssh-agent -t 3600)
ssh-add /home/caaspadm/.ssh/id_rsa
#pass=system
#expect << EOF
#  spawn ssh-add
#  expect "Enter passphrase"
#  send "$pass\r"
#  expect eof
#EOF

cd
skuba cluster init my-cluster --control-plane caasp-admin.esx.local
cd  my-cluster
sed -i 's#podSubnet:.*#podSubnet: 10.100.0.0/16#g' kubeadm-init.conf
sed -i 's#serviceSubnet:.*#serviceSubnet: 10.200.0.0/16#g' kubeadm-init.conf
#SERVER=caasp-master-1; skuba node bootstrap $SERVER --sudo --target $SERVER.esx.local --user caaspadm -v5 2>&1|tee $SERVER.log
SERVER=caasp-admin; skuba node bootstrap $SERVER --sudo --target $SERVER.esx.local --user caaspadm -v5 2>&1|tee $SERVER.log

mkdir ~/.kube
ln -s ~/my-cluster/admin.conf ~/.kube/config

#for MASTER in caasp-master-2 caasp-master-3; do \
#skuba node join $MASTER --role master --sudo --target $MASTER.esx.local --user caaspadm -v5 2>&1 |tee $MASTER.log; \
#done

#for WORKER in caasp-worker-1 caasp-worker-2 caasp-worker-3; do \
#skuba node join $WORKER --role worker --sudo --target $WORKER.esx.local --user caaspadm -v5 2>&1 |tee $WORKER.log; \
#done

for WORKER in caasp-worker-1 caasp-worker-2; do \
skuba node join $WORKER --role worker --sudo --target $WORKER.esx.local --user caaspadm -v5 2>&1 |tee $WORKER.log; \
done

skuba cluster status
kubectl get nodes -o wide
kubectl get pods --all-namespaces
