#!/bin/bash
WORKDIR=$(pwd)

# 1. Connect to your gcp project and name the cluster you would like to create

PROJECT_ID="kalschi-logging"
PROJECT_NAME="kalschi-logging"
USER_EMAIL="kevinctyu@google.com"
CLUSTER_NAME="kevinctyu-gitops-demo-cluster"
COMPUTE_REGION="asia-east1"
COMPUTE_ZONE="asia-east1-a"

##########################################################################

# 2. Modidy domain name to the one you would like to register

DOMAIN_NAME="gitops-demo-app.com"
CLOUD_DNS_ZONE_NAME="gitops-demo-app"

ALPHA_FRONTEND_URL="my-alpha.${DOMAIN_NAME}"
ALPHA_BACKEND_URL="api-alpha.${DOMAIN_NAME}"

BETA_FRONTEND_URL="my-beta.${DOMAIN_NAME}"
BETA_BACKEND_URL="api-beta.${DOMAIN_NAME}"

RELEASE_FRONTEND_URL="my.${DOMAIN_NAME}"
RELEASE_BACKEND_URL="api.${DOMAIN_NAME}"

ARGOCD_URL="argocd.${DOMAIN_NAME}"

##########################################################

# 3. Service account info that would be used by cert-manager

EXTERNALDNS_SERVICEACCOUNT_NAME="dns-admin"
CERT_SERVICEACCOUNT_NAME="cert-admin"

############################################################

# 4. DO NOT modify the following repos' url

FRONTEND_REPO="https://github.com/kevinyu0506/gitops-demo-frontend.git"
FRONTEND_REPO_NAME="gitops-demo-frontend"

BACKEND_REPO="https://github.com/kevinyu0506/gitops-demo-backend.git"
BACKEND_REPO_NAME="gitops-demo-backend"

MANIFESTS_REPO="https://github.com/kevinyu0506/gitops-demo-manifests.git"
MANIFESTS_REPO_NAME="gitops-demo-manifests"

###########################################


echo "Creating ./env-variables.sh ..."
cat <<EOT > ${WORKDIR}/env-variables.sh
export WORKDIR="${WORKDIR}"

export PROJECT_ID="${PROJECT_ID}"
export PROJECT_NAME="${PROJECT_NAME}"
export USER_EMAIL="${USER_EMAIL}"
export CLUSTER_NAME="${CLUSTER_NAME}"
export COMPUTE_REGION="${COMPUTE_REGION}"
export COMPUTE_ZONE="${COMPUTE_ZONE}"

export DOMAIN_NAME="${DOMAIN_NAME}"
export CLOUD_DNS_ZONE_NAME="${CLOUD_DNS_ZONE_NAME}"

export ALPHA_FRONTEND_URL="${ALPHA_FRONTEND_URL}"
export ALPHA_BACKEND_URL="${ALPHA_BACKEND_URL}"

export BETA_FRONTEND_URL="${BETA_FRONTEND_URL}"
export BETA_BACKEND_URL="${BETA_BACKEND_URL}"

export ARGOCD_URL="${ARGOCD_URL}"

export EXTERNALDNS_SERVICEACCOUNT_NAME="${EXTERNALDNS_SERVICEACCOUNT_NAME}"
export CERT_SERVICEACCOUNT_NAME="${CERT_SERVICEACCOUNT_NAME}"
export CERT_EMAIL="${USER_EMAIL}"

export FRONTEND_REPO="${FRONTEND_REPO}"
export FRONTEND_REPO_NAME="${FRONTEND_REPO_NAME}"
export FRONTEND_REPO_PATH="${WORKDIR}/${FRONTEND_REPO_NAME}"

export BACKEND_REPO="${BACKEND_REPO}"
export BACKEND_REPO_NAME="${BACKEND_REPO_NAME}"
export BACKEND_REPO_PATH="${WORKDIR}/${BACKEND_REPO_NAME}"

export RELEASE_FRONTEND_URL="${RELEASE_FRONTEND_URL}"
export RELEASE_BACKEND_URL="${RELEASE_BACKEND_URL}"

export MANIFESTS_REPO="${MANIFESTS_REPO}"
export MANIFESTS_REPO_NAME="${MANIFESTS_REPO_NAME}"
export MANIFESTS_REPO_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}"
EOT
