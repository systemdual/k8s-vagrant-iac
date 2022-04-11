#! /bin/bash
#------------
# OS UPGRADES
#------------
# We need to take node01 out for maintenance. Empty the node of all applications and mark it unschedulable.
kubectl drain node01 --ignore-daemonsets
# The maintenance tasks have been completed. Configure the node node01 to be schedulable again.
kubectl uncordon node01
# A forceful drain of the node will delete any pod that is not part of a replicaset.
# hr-app is a critical app and we do not want it to be removed and we do not want to schedule any more pods on node01.
# Mark node01 as unschedulable so that no new pods are scheduled on this node.
kubectl cordon node01
#------------------------
# CLUSTER UPGRADE PROCESS
#------------------------
# What is the current version of the cluster?
kubectl get nodes # Version column
# See taints
kubectl describe node NODE # campo taints
# You are tasked to upgrade the cluster. User's accessing the applications must not be impacted. And you cannot provision new VMs. 
# What strategy would you use to upgrade the cluster?
# -->    In order to ensure minimum downtime, upgrade the cluster one node at a time, while moving the workloads to another node.
# What is the latest stable version available for upgrade?
kubeadm upgrade plan
# We will be upgrading the master node first. Drain the master node of workloads and mark it UnSchedulable
kubectl drain controlplane --ignore-daemonsets
# Upgrade the controlplane components to exact version v1.20.0. Upgrade kubeadm tool (if not already), then the master components, and finally the kubelet. 
# Note: While upgrading kubelet, if you hit dependency issue while running the apt-get upgrade kubelet command, 
# use the apt install kubelet=1.20.0-00 command instead
# On the controlplane node, run the command run the following commands:
apt update # This will update the package lists from the software repository.
apt install kubeadm=1.20.0-00 # This will install the kubeadm version 1.20
kubeadm upgrade apply v1.20.0 # This will upgrade kubernetes controlplane. Note that this can take a few minutes.
apt install kubelet=1.20.0-00 # This will update the kubelet with the version 1.20.
systemctl restart kubelet # You may need to restart kubelet after it has been upgraded.
# Mark the controlplane node as "Schedulable" again
kubectl uncordon controlplane
# Next is the worker node. Drain the worker node of the workloads and mark it UnSchedulable
kubectl drain node01 --ignore-daemonsets
# Upgrade the worker node to the exact version v1.20.0
# On the node01 node, run the command run the following commands:
# If you are on the master node, run ssh node01 to go to node01
apt update #This will update the package lists from the software repository.
apt install kubeadm=1.20.0-00 # This will install the kubeadm version 1.20
kubeadm upgrade node # This will upgrade the node01 configuration.
apt install kubelet=1.20.0-00 # This will update the kubelet with the version 1.20.
systemctl restart kubelet # You may need to restart kubelet after it has been upgraded.
# Remove the restriction and mark the worker node as schedulable again.
kubectl uncordon node01
#---------------------------
# Backup and restore methods
#---------------------------
# What is the version of ETCD running on the cluster?
kubectl describe pod etcd-controlplane -n kube-system # Image: k8s.gcr.io/etcd:3.4.13-0
# At what address can you reach the ETCD cluster from the controlplane node?
kubectl -n kube-system describe pod etcd-controlplane | grep '\--listen-client-urls' 
# Where is the ETCD server certificate file located?
kubectl -n kube-system describe pod etcd-controlplane | grep '\--cert-file'
# Where is the ETCD CA Certificate file located?
kubectl -n kube-system describe pod etcd-controlplane | grep '\--trusted-ca-file' #  --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
# The master nodes in our cluster are planned for a regular maintenance reboot tonight. While we do not anticipate anything to go wrong, 
# we are required to take the necessary backups. Take a snapshot of the ETCD database using the built-in snapshot functionality.
# Store the backup file at location /opt/snapshot-pre-boot.db
ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db # Snapshot saved at /opt/snapshot-pre-boot.db
# Restore
ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup \
snapshot restore /opt/snapshot-pre-boot.db
# edit /etc/kubernetes/manifests/etcd.yaml and change
volumes:
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data
# Se deberá reiniciar el pod aplicando esta config
# En caso de que sea necesario: 
kubectl delete pod -n kube-system etcd-controlplane # eliminar para que se vuelva a recrear con este cambio en el etcd.yaml
