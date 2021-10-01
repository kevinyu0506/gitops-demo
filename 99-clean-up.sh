#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi

# Delete all environments
for phase in development alpha beta
do
    echo "Deleting [$phase] phase resources..."
    KUSTOMIZE_PATH="overlays/$phase"
    kubectl delete -k ${MANIFESTS_REPO_PATH}/${KUSTOMIZE_PATH}
done


# Delete external-dns resources
echo "Delete external-dns resources..."
kubectl delete -k "${MANIFESTS_REPO_PATH}/bases/cluster-resources/external-dns"


# Delete nginx-ingress-controller resources
echo "Delete nginx-ingress-controller resources..."
kubectl delete -k "${MANIFESTS_REPO_PATH}/bases/cluster-resources/nginx-ingress-controller"


# Delete cert-manager resources
echo "Delete cert-manager resources..."
kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.yaml


# Install argo-cd resources
echo "Delete argo-cd resources..."
kubectl delete -k ${MANIFESTS_REPO_PATH}/bases/cluster-resources/argo-cd
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.1.0/manifests/install.yaml


rm -rf gitops-demo-backend
rm -rf gitops-demo-frontend
rm -rf gitops-demo-manifests

rm -rf resources
rm env-variables.sh
