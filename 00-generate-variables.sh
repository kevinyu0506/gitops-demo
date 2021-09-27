#!/bin/bash
WORKDIR=$(pwd)

PROJECT_ID="kalschi-logging"
CLUSTER_NAME="kevinctyu-gitops-demo-cluster"
COMPUTE_REGION="asia-east1"
COMPUTE_ZONE="asia-east1-a"

DOMAIN_NAME="gitops-demo-app.com"
DOMAIN_NAME_CONTACTS_PATH="${WORKDIR}/resources/domain-contacts.yaml"
CLOUD_DNS_ZONE_NAME="gitops-demo-app"
CLOUD_DNS_ZONE_DESCRIPTION="Automatically managed zone by external dns"

CERT_SERVICEACCOUNT_NAME="cert-admin"
CERT_SERVICEACCOUNT="${CERT_SERVICEACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
CERT_EMAIL="kevinctyu@google.com"
CERT_SECRET_NAME="cert-admin-key.json"
CERT_KEY_PATH="${WORKDIR}/resources/${CERT_SECRET_NAME}"

FRONTEND_REPO="https://github.com/kevinyu0506/gitops-demo-frontend.git"
FRONTEND_REPO_NAME="gitops-demo-frontend"
FRONTEND_REPO_PATH="${WORKDIR}/${FRONTEND_REPO_NAME}"

BACKEND_REPO="https://github.com/kevinyu0506/gitops-demo-backend.git"
BACKEND_REPO_NAME="gitops-demo-backend"
BACKEND_REPO_PATH="${WORKDIR}/${BACKEND_REPO_NAME}"

MANIFESTS_REPO="https://github.com/kevinyu0506/gitops-demo-manifests.git"
MANIFESTS_REPO_NAME="gitops-demo-manifests"
MANIFESTS_REPO_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}"

EXTERNAL_DNS_DEPLOYMENT_PATH="${MANIFESTS_REPO_PATH}/bases/cluster-resources/external-dns/resources/deployment.yaml"

ALPHA_INGRESS_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/alpha/demo-apps/resources/ingress.yaml"

ALPHA_FRONTEND_URL="my-alpha.gitops-demo-app.com"
ALPHA_BACKEND_URL="api-alpha.gitops-demo-app.com"

BETA_INGRESS_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/beta/demo-apps/resources/ingress.yaml"
BETA_CERT_SECRET_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/beta/demo-apps/secrets/${CERT_SECRET_NAME}"
BETA_ISSUER_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/beta/demo-apps/certs/issuer.yaml"
BETA_CERT_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/beta/demo-apps/certs/certificate.yaml"

BETA_ISSUER_NAME="beta-issuer"
BETA_CERT_NAME="beta-cert"
BETA_CERT_SECRET_NAME="beta-tls"

BETA_FRONTEND_URL="my-beta.gitops-demo-app.com"
BETA_BACKEND_URL="api-beta.gitops-demo-app.com"


echo "Creating ./env-variables.sh ..."
cat <<EOT > ${WORKDIR}/env-variables.sh
export WORKDIR="${WORKDIR}"

export PROJECT_ID="${PROJECT_ID}"
export CLUSTER_NAME="${CLUSTER_NAME}"
export COMPUTE_REGION="${COMPUTE_REGION}"
export COMPUTE_ZONE="${COMPUTE_ZONE}"

export DOMAIN_NAME="${DOMAIN_NAME}"
export DOMAIN_NAME_CONTACTS_PATH="${DOMAIN_NAME_CONTACTS_PATH}"
export CLOUD_DNS_ZONE_NAME="${CLOUD_DNS_ZONE_NAME}"
export CLOUD_DNS_ZONE_DESCRIPTION="${CLOUD_DNS_ZONE_DESCRIPTION}"

export CERT_SERVICEACCOUNT_NAME="${CERT_SERVICEACCOUNT_NAME}"
export CERT_SERVICEACCOUNT="${CERT_SERVICEACCOUNT}"
export CERT_EMAIL="${CERT_EMAIL}"
export CERT_SECRET_NAME="${CERT_SECRET_NAME}"
export CERT_KEY_PATH="${CERT_KEY_PATH}"

export FRONTEND_REPO="${FRONTEND_REPO}"
export FRONTEND_REPO_NAME="${FRONTEND_REPO_NAME}"
export FRONTEND_REPO_PATH="${FRONTEND_REPO_PATH}"

export BACKEND_REPO="${BACKEND_REPO}"
export BACKEND_REPO_NAME="${BACKEND_REPO_NAME}"
export BACKEND_REPO_PATH="${BACKEND_REPO_PATH}"

export MANIFESTS_REPO="${MANIFESTS_REPO}"
export MANIFESTS_REPO_NAME="${MANIFESTS_REPO_NAME}"
export MANIFESTS_REPO_PATH="${MANIFESTS_REPO_PATH}"

export EXTERNAL_DNS_DEPLOYMENT_PATH="${EXTERNAL_DNS_DEPLOYMENT_PATH}"

export ALPHA_INGRESS_PATH="${ALPHA_INGRESS_PATH}"

export ALPHA_FRONTEND_URL="${ALPHA_FRONTEND_URL}"
export ALPHA_BACKEND_URL="${ALPHA_BACKEND_URL}"

export BETA_INGRESS_PATH="${BETA_INGRESS_PATH}"
export BETA_CERT_SECRET_PATH="${BETA_CERT_SECRET_PATH}"
export BETA_ISSUER_PATH="${BETA_ISSUER_PATH}"
export BETA_CERT_PATH="${BETA_CERT_PATH}"

export BETA_ISSUER_NAME="${BETA_ISSUER_NAME}"
export BETA_CERT_NAME="${BETA_CERT_NAME}"
export BETA_CERT_SECRET_NAME="${BETA_CERT_SECRET_NAME}"

export BETA_FRONTEND_URL="${BETA_FRONTEND_URL}"
export BETA_BACKEND_URL="${BETA_BACKEND_URL}"
EOT


echo "Creating ${DOMAIN_NAME_CONTACTS_PATH} ..."
cat <<EOT > ${DOMAIN_NAME_CONTACTS_PATH}
allContacts:
  email: 'example@example.com'
  phoneNumber: '+1.8005550123'
  postalAddress:
    regionCode: 'US'
    postalCode: '94043'
    administrativeArea: 'CA'
    locality: 'Mountain View'
    addressLines: ['1600 Amphitheatre Pkwy']
    recipients: ['Jane Doe']
EOT
