export TF_VAR_client_id=<service-principal-appid>
export TF_VAR_client_secret=<service-principal-password>

terraform init
terraform plan
terraform apply

echo "$(terraform output kube_config)" > ./azurek8s

export KUBECONFIG=./azurek8s

kubectl get nodes

Monitor health and logs
When the AKS cluster was created, monitoring was enabled to capture health metrics for both the cluster nodes and pods. These health metrics are available in the Azure portal.