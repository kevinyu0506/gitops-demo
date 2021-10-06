#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


echo "Set default project to [${PROJECT_ID}], region to [${COMPUTE_REGION}], zone to [${COMPUTE_ZONE}]..."
gcloud config set project ${PROJECT_ID}
gcloud config set compute/region ${COMPUTE_REGION}
gcloud config set compute/zone ${COMPUTE_ZONE}

gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable domains.googleapis.com
gcloud services enable dns.googleapis.com


echo "Creating cluster [${CLUSTER_NAME}]..."
gcloud container clusters create ${CLUSTER_NAME} \
    --num-nodes=1 \
    --workload-pool=${PROJECT_ID}.svc.id.goog

gcloud container clusters get-credentials ${CLUSTER_NAME}
