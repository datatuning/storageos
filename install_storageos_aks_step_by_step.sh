
#create AKS cluster
az aks create --name k8sdemo --resource-group datatuning --generate-ssh-keys --node-vm-size Standard_D2as_v4 --node-count 3 --kubernetes-version 1.20.2
az aks get-credentials --resource-group=CloudLunchandLearnMarathon --name k8sdemo

#create storageos 
kubectl -n kube-system run --image storageos/cli:v2.3.3 --restart=Never --env STORAGEOS_ENDPOINTS=storageos:5705 --env STORAGEOS_USERNAME=storageos --env STORAGEOS_PASSWORD=storageos --command cli -- /bin/sh -c "while true; do sleep 100000; done"

kubectl create namespace storageosetcd
kubectl -n storageosetcd create -f sos_etc_role.yml
kubectl -n storageosetcd create -f sos_etc_role_bind.yml
kubectl -n storageosetcd create -f sos_etcd_op.yml
kubectl -n storageosetcd create -f sos_etc_cluster.yml

#Pegar o CLUSTER-IP do Service do Etcd
kubectl get services -n storageosetcd

kubectl create -f https://github.com/storageos/cluster-operator/releases/download/v2.3.4/storageos-operator.yaml
kubectl create -f sos_secrets.yml
kubectl create -f sos_clusterdef.yml #Colocar o IP do ETCD aqui antes de executar
kubectl -n kube-system port-forward svc/storageos 5705 
# acessar no Browser localhost:5705 - user: storageos, pass: storageos

kubectl create -f v2-storageclass-replicated.yaml
kubectl create -f pvc-replicated.yaml

#Subindo o SQL Server
kubectl create namespace mssqldtc
kubectl -n mssqldtc create -f 00-service-account.yaml
kubectl -n mssqldtc create -f 10-service.yaml
kubectl -n mssqldtc create -f 15-mssql-configmap.yaml
kubectl -n mssqldtc create -f 20-mssql-statefulset.yaml

#Referencias
#Instalacao StorageOS
https://www.youtube.com/watch?v=1b2s9fcKZyU
#Composable Storage and Storage Aware Application Placement for Kubernetes
https://www.youtube.com/watch?v=bTFtDypL6Dw
#The Evolution of Cloud Native Storage with StorageOS
https://www.youtube.com/watch?v=7q5xqodT-Uk
#StorageOS Live Demo: Database As A Service with PostgreSQL
https://www.youtube.com/watch?v=GJdrWB-PHPI