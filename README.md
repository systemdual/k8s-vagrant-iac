## Descripción:
Este laboratorio automatiza y hace flexible la generación/configuración de un cluster kubernetes por medio de Vagrant y un set de scripts bash

## Requisitos:

Procesador: 4 núcleos
RAM: 8-16 GB
SO Ubuntu 18.04/20.04/22.04:
```
azureuser@darkrai:~$ cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.4 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
azureuser@darkrai:~$
```

Virtualbox y Vagrant:
```
apt install virtualbox vagrant -y
```
Plugin de vagrant (para la imagen vagrant "focal64" de ubuntu, que no monta bien las carpetas compartidas)
```
vagrant plugin install vagrant-vbguest
```
## Uso:

Nos situamos en el directorio del Vagrantfile y ejecutamos:
```
chmod +x init.sh
```
```
./init.sh
```

## Resultado:

Un cluster kubernetes sobre virtualbox aprovisionado con Vagrant con X nodos master y Z nodos worker (por defecto x=1,z=3).

## Comandos útiles:

Ver nodos del cluster:
```
vagrant ssh kubemaster -- kubectl get nodes -o wide
```
Ver todos los objetos del cluster:
```
vagrant ssh kubemaster -- kubectl get all --all-namespaces
```
Acceder a los nodos para ejecutar los comandos de kubernetes directamente:
```
vagrant ssh kubemaster
```
```
vagrant ssh kubenode01
```

## Datos del dashboard

Crear y configurar:
```
vagrant ssh kubemaster -- resources/init-cluster/06-dashboard.sh
```

URL:
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

Obtener token root para acceder al dashboard:
```
vagrant ssh kubemaster -- cat dashboard-token.log
```

