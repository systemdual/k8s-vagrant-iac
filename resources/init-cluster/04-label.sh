# label.sh
kubectl label node kubenode01 node-role.kubernetes.io/worker=worker && kubectl label node kubenode02 node-role.kubernetes.io/worker=worker && kubectl label node kubenode03 node-role.kubernetes.io/worker=worker
