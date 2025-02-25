#!/bin/bash

set -e
set -x

REGION="us-east-1"
CLUSTER_NAME="eks-fiapeats-cluster"

terraform init
terraform plan
terraform apply -auto-approve

EKS_ENDPOINT=$(terraform output -raw eks_cluster_endpoint)
EKS_CA_CERT=$(terraform output -raw eks_cluster_ca_certificate)

echo "Configurando o acesso ao cluster EKS..."
aws --profile fiapeats eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

echo "Validando a conexão com o cluster EKS..."
kubectl get nodes || { echo "Erro: Não foi possível conectar ao cluster EKS."; exit 1; }

echo "Aplicando manifestos Kubernetes..."
kubectl apply -f ./kubernetes --recursive|| { echo "Erro ao aplicar os manifestos Kubernetes."; exit 1; }

echo "Exibindo os Pods no cluster..."
kubectl get pods --all-namespaces

echo "Configuração concluída com sucesso: Cluster EKS e manifestos Kubernetes aplicados!"
