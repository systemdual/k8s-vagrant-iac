# network.sh
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(sudo kubectl version | base64 | tr -d '\n')"
kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
