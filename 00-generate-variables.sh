#!/bin/bash
WORKDIR=$(pwd)

PROJECT_ID="kalschi-logging"
CLUSTER_NAME="kevinctyu-gitops-demo-cluster"
COMPUTE_REGION="asia-east1"
COMPUTE_ZONE="asia-east1-a"

DOMAIN_NAME="gitops-demo-app.com"
CLOUD_DNS_ZONE_NAME="gitops-demo-app"

CERT_SERVICEACCOUNT_NAME="cert-admin"
CERT_EMAIL="kevinctyu@google.com"

FRONTEND_REPO="https://github.com/kevinyu0506/gitops-demo-frontend.git"
FRONTEND_REPO_NAME="gitops-demo-frontend"

BACKEND_REPO="https://github.com/kevinyu0506/gitops-demo-backend.git"
BACKEND_REPO_NAME="gitops-demo-backend"

MANIFESTS_REPO="https://github.com/kevinyu0506/gitops-demo-manifests.git"
MANIFESTS_REPO_NAME="gitops-demo-manifests"

ALPHA_FRONTEND_URL="my-alpha.gitops-demo-app.com"
ALPHA_BACKEND_URL="api-alpha.gitops-demo-app.com"

BETA_FRONTEND_URL="my-beta.gitops-demo-app.com"
BETA_BACKEND_URL="api-beta.gitops-demo-app.com"

ARGOCD_URL="argocd.gitops-demo-app.com"


echo "Creating ./env-variables.sh ..."
cat <<EOT > ${WORKDIR}/env-variables.sh
export WORKDIR="${WORKDIR}"

export PROJECT_ID="${PROJECT_ID}"
export CLUSTER_NAME="${CLUSTER_NAME}"
export COMPUTE_REGION="${COMPUTE_REGION}"
export COMPUTE_ZONE="${COMPUTE_ZONE}"

export DOMAIN_NAME="${DOMAIN_NAME}"
export CLOUD_DNS_ZONE_NAME="${CLOUD_DNS_ZONE_NAME}"

export CERT_SERVICEACCOUNT_NAME="${CERT_SERVICEACCOUNT_NAME}"
export CERT_EMAIL="${CERT_EMAIL}"

export FRONTEND_REPO="${FRONTEND_REPO}"
export FRONTEND_REPO_NAME="${FRONTEND_REPO_NAME}"
export FRONTEND_REPO_PATH="${WORKDIR}/${FRONTEND_REPO_NAME}"

export BACKEND_REPO="${BACKEND_REPO}"
export BACKEND_REPO_NAME="${BACKEND_REPO_NAME}"
export BACKEND_REPO_PATH="${WORKDIR}/${BACKEND_REPO_NAME}"

export MANIFESTS_REPO="${MANIFESTS_REPO}"
export MANIFESTS_REPO_NAME="${MANIFESTS_REPO_NAME}"
export MANIFESTS_REPO_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}"

export ALPHA_FRONTEND_URL="${ALPHA_FRONTEND_URL}"
export ALPHA_BACKEND_URL="${ALPHA_BACKEND_URL}"

export BETA_FRONTEND_URL="${BETA_FRONTEND_URL}"
export BETA_BACKEND_URL="${BETA_BACKEND_URL}"

export ARGOCD_URL="${ARGOCD_URL}"
EOT
