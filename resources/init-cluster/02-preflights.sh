# preflight.sh
#mkdir -p $HOME/.kube
mkdir -p /home/vagrant/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
