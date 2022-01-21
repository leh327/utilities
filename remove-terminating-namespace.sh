#!/bin/sh
# references:
#   https://craignewtondev.medium.com/how-to-fix-kubernetes-namespace-deleting-stuck-in-terminating-state-5ed75792647e
#   https://kubernetesquestions.com/questions/55184779

kubectl get ns
for namespacename in $(kubectl get ns --field-selector=status.phase=Terminating -o name | awk -F/ '{print $2}'); do

kubectl get namespace ${namespacename} -o json > /tmp/${namespacename}.json

cat>replace-finalizer.yml<<EOF
- hosts: localhost
  gather_facts: no
  tasks:
  - replace:
      path: "/tmp/{{namespacename}}.json"
      after: '"finalizers": \['
      regexp: '"kubernetes"'
      replace:  ""
  
EOF
ansible-playbook replace-finalizer.yml -e namespacename=$namespacename

kubectl replace --raw "/api/v1/namespaces/${namespacename}/finalize" -f /tmp/${namespacename}.json

done
kubectl get ns
