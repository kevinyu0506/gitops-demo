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


# Create dns solver secrets
if [ ! -f ${CERT_KEY_PATH} ]
then
    echo "Cert-manager key not exist, creating..."
    gcloud iam service-accounts create ${CERT_SERVICEACCOUNT_NAME} --display-name ${CERT_SERVICEACCOUNT_NAME}
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member ${CERT_SERVICEACCOUNT} --role roles/dns.admin
    gcloud iam service-accounts keys create ${CERT_KEY_PATH} --iam-account ${CERT_SERVICEACCOUNT}
    echo "Cert-manager already exist, skipping this step..."
fi

echo "Copying secrets to manifests..."
cp ${CERT_KEY_PATH} ${BETA_CERT_SECRET_PATH}


# Create issuer
echo "Creating ${BETA_ISSUER_PATH} ..."
cat <<EOT > ${BETA_ISSUER_PATH}
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${BETA_ISSUER_NAME}
spec:
  acme:
    #server: https://acme-v02.api.letsencrypt.org/directory
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${CERT_EMAIL}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      # Secret resource used to store the account's private key
      name: ${BETA_ISSUER_NAME}
    solvers:
    # ACME DNS-01 provider configurations
    - selector: {}
      dns01:
        cloudDNS:
          # The ID of the GCP project
          project: ${PROJECT_ID}
          # This is the secret used to access the service account
          serviceAccountSecretRef:
            name: clouddns-dns01-solver-svc-acct
            key: ${CERT_SECRET_NAME}
EOT


# Create certificate
echo "Creating ${BETA_CERT_PATH} ..."
cat <<EOT > ${BETA_CERT_PATH}
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${BETA_CERT_NAME}
spec:
  secretName: ${BETA_CERT_SECRET_NAME}
  issuerRef:
    name: ${BETA_ISSUER_NAME}
    kind: Issuer
  dnsNames:
  - ${BETA_FRONTEND_URL}
  - ${BETA_BACKEND_URL}
EOT
