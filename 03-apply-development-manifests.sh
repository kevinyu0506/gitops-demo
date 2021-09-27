#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


CURRENT_PHASE="development" #development, alpha, beta, release
KUSTOMIZE_PATH="overlays/${CURRENT_PHASE}"


# Apply development resources
echo "Applying [${CURRENT_PHASE}] phase resources..."
kubectl apply -k ${MANIFESTS_REPO_PATH}/${KUSTOMIZE_PATH}
