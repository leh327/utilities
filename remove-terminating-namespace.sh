#!/bin/sh
kubectl get ns
echo Enter name of namespace
read namespacename
#https://craignewtondev.medium.com/how-to-fix-kubernetes-namespace-deleting-stuck-in-terminating-state-5ed75792647e
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
