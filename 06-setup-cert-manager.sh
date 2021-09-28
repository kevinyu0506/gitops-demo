#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


# Install cert-manager resources
echo "Applying cert-manager resources..."
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.yaml
kubectl wait -n cert-manager pods -l app=cert-manager --for=condition=ready
kubectl wait -n cert-manager pods -l app=webhook --for=condition=ready

DOMAIN_NAME_CONTACTS_PATH="${RESOURCES_PATH}/domain-contacts.yaml"


# Create cert-manager dns solver service account key
RESOURCES_PATH="${WORKDIR}/resources"
CERT_KEY_PATH="${RESOURCES_PATH}/cert-admin-key.json"

CERT_SERVICEACCOUNT="${CERT_SERVICEACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

mkdir -p ${RESOURCES_PATH}

if [ ! -f ${CERT_KEY_PATH} ]
then
    echo "Cert-manager service account [${CERT_SERVICEACCOUNT_NAME}] key not exist, creating..."
    gcloud iam service-accounts create ${CERT_SERVICEACCOUNT_NAME} --display-name ${CERT_SERVICEACCOUNT_NAME}
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${CERT_SERVICEACCOUNT}" --role roles/dns.admin
    gcloud iam service-accounts keys create ${CERT_KEY_PATH} --iam-account ${CERT_SERVICEACCOUNT}
else
    echo "Cert-manager service account [${CERT_SERVICEACCOUNT_NAME}] key already exist, skipping this step..."
fi
