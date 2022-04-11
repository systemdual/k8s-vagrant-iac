## Descripción:
Este laboratorio automatiza y hace flexible la generación/configuración de un cluster kubernetes por medio de Vagrant y un set de scripts bash

## Requisitos:
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
chmod +x init-cluster.sh
```
```
./init-cluster.sh
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

