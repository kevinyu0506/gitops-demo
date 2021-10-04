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


# Create cert-manager account workload identity
CERT_SERVICEACCOUNT="${CERT_SERVICEACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KUBERNETES_SERVICEACCOUNT="${PROJECT_ID}.svc.id.goog[cert-manager/cert-manager]"

echo "Creating cert-manager service account [${CERT_SERVICEACCOUNT_NAME}]..."
gcloud iam service-accounts create ${CERT_SERVICEACCOUNT_NAME} --display-name ${CERT_SERVICEACCOUNT_NAME}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${CERT_SERVICEACCOUNT}" --role roles/dns.admin

echo "Linking KSA and GSA..."
gcloud iam service-accounts add-iam-policy-binding --role roles/iam.workloadIdentityUser --member "serviceAccount:${KUBERNETES_SERVICEACCOUNT}" ${CERT_SERVICEACCOUNT}
kubectl annotate serviceaccount --namespace=cert-manager cert-manager "iam.gke.io/gcp-service-account=${CERT_SERVICEACCOUNT}"

