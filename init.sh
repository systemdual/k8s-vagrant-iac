# Variables
vagrantLogfile="vagrant-up.log" # Fichero de log para la ejecución de vagrant
initClusterlogFile="init-cluster.log" # Fichero de log para la ejecución de los pasos de este script
masterNodes=$(cat Vagrantfile | grep "NUM_MASTER_NODE =" | cut -d " " -f 3)
workerNodes=$(cat Vagrantfile | grep "NUM_WORKER_NODE =" | cut -d " " -f 3)
# Mostrar datos y enviar info a logs
echo -e "\nLog aprovisionamiento infra: $vagrantLogfile"
echo -e "\nLog detallado config cluster: $initClusterlogFile"
echo -e "\nNodos master: $masterNodes"
echo -e "\nNodos worker: $workerNodes"
echo -e "\nLevantando infraestructura definida en el fichero Vagrantfile..."
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Levantando infraestructura definida en el fichero Vagrantfile... Detalles en $vagrantLogfile" >> $initClusterlogFile
# Damos orden de aprovisionar infra definida en Vagrantfile
vagrant up >> $vagrantLogfile
echo -e "\nSe ha terminado de levantar la infraestructura."
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Se ha terminado de levantar la infraestructura." >> $initClusterlogFile
# Configurar el cluster kubernetes en la infra aprovisionada
echo -e "\nConfigurando cluster kubernetes..."
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Configurando cluster kubernetes..." >> $initClusterlogFile
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Damos formato y permisos a los scripts que inicializan el cluster..." >> $initClusterlogFile
vagrant ssh kubemaster -- dos2unix ./resources/init-cluster/*  >> /dev/null 2>&1
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Hecho" >> $initClusterlogFile
vagrant ssh kubemaster -- chmod +x ./resources/init-cluster/* >> /dev/null 2>&1
echo -e "\nAnunciando cluster y obteniendo comando para unir los nodos..."
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Promocionar cluster..." >> $initClusterlogFile
vagrant ssh kubemaster -- resources/init-cluster/01-advertise.sh >> /dev/null 2>&1
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Hecho" >> $initClusterlogFile
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Establecer kubeconfig..." >> $initClusterlogFile
vagrant ssh kubemaster -- resources/init-cluster/02-preflights.sh > /dev/null 2>&1
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Obtener e instalar CNI..." >> $initClusterlogFile
vagrant ssh kubemaster -- resources/init-cluster/03-network.sh > /dev/null 2>&1
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Hecho" >> $initClusterlogFile
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Obtener comando para unir nodos..." >> $initClusterlogFile
joinCommand=$(vagrant ssh kubemaster -- cat kubeadm-init.log | grep "kubeadm join" -C 1 | tail -2 | tr -d '\\')
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Hecho" >> $initClusterlogFile
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Unimos nodos al cluster..." >> $initClusterlogFile
echo -e "\nUniendo nodos al cluster..."
# Unimos nodos worker al cluster
for ((worker=1; worker<=$workerNodes; worker++))
do
    vagrant ssh kubenode0$worker -- sudo $joinCommand > /dev/null 2>&1
    echo -e "\n`date +%y/%m/%d_%H:%M:%S` Unido nodo worker kubenode0$worker al cluster" >> $initClusterlogFile
    echo -e "\n`date +%y/%m/%d_%H:%M:%S` Unido nodo worker kubenode0$worker al cluster" >> $vagrantLogfile
    echo -e "\nNodo kubenode0$worker unido al cluster"
done
echo -e "\nLos nodos se han unido al cluster correctamente"
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Hecho" >> $initClusterlogFile
# Damos rol worker a los nodos workers
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Damos roles a los nodos worker... " >> $initClusterlogFile
for ((worker=1; worker<=$workerNodes; worker++))
do
    vagrant ssh kubemaster -- kubectl label node kubenode0$worker node-role.kubernetes.io/worker=worker >> $vagrantLogfile
    echo -e "\nRol worker asignado a kubenode0$worker."
done
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Hecho" >> $initClusterlogFile
# Configuramos servidor de métricas y dashboard
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Montar servidor de métricas... " >> $initClusterlogFile
vagrant ssh kubemaster -- resources/init-cluster/05-metrics-server.sh > /dev/null 2>&1
echo -e "\n`date +%y/%m/%d_%H:%M:%S` Hecho" >> $initClusterlogFile

echo -e "\nTodo listo! :)\n"
#echo -e "\nAlgunos comandos que puedes ejecutar para empezar son:\n\nvagrant ssh kubemaster -- kubectl get nodes -o wide\nvagrant ssh kubemaster -- kubectl get all --all-namespaces\n"
#echo -e "\n`date +%y/%m/%d_%H:%M:%S` Iniciamos dashboard y capturamos sus datos..." >> $initClusterlogFile
#echo -e "\n`date +%y/%m/%d_%H:%M:%S` El dashboard se guarda en el fichero dashboard-token.log. Para obtenerlo, ejecutar: vagrant ssh kubemaster -- cat dashboard-token.log "  >> $initClusterlogFile
#echo -e "\n`date +%y/%m/%d_%H:%M:%S` La URL para acceder al dashboard es: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/" >> $initClusterlogFile
echo -e "\n`date +%y/%m/%d_%H:%M:%S` El comando para unir nuevos nodos al cluster es: $joinCommand" >> $initClusterlogFile
#vagrant ssh kubemaster -- resources/init-cluster/06-dashboard.sh > /dev/null 2>&1
