#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


ARGOCD_CERTS_PATH="${MANIFESTS_REPO_PATH}/bases/cluster-resources/argo-cd/certs"
ARGOCD_SECRETS_PATH="${MANIFESTS_REPO_PATH}/bases/cluster-resources/argo-cd/secrets"
ARGOCD_RESOURCES_PATH="${MANIFESTS_REPO_PATH}/bases/cluster-resources/argo-cd/resources"

mkdir -p ${ARGOCD_CERTS_PATH}
mkdir -p ${ARGOCD_SECRETS_PATH}
mkdir -p ${ARGOCD_RESOURCES_PATH}


# Copy service account key
RESOURCES_PATH="${WORKDIR}/resources"
CERT_KEY_PATH="${RESOURCES_PATH}/cert-admin-key.json"

echo "Copying service account key secrets..."
cp ${CERT_KEY_PATH} ${ARGOCD_SECRETS_PATH}


# Create issuer
ARGOCD_ISSUER_NAME="argocd-issuer"

echo "Creating argo-cd issuer..."

cat <<EOT > "${ARGOCD_CERTS_PATH}/issuer.yaml"
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${ARGOCD_ISSUER_NAME}
spec:
  acme:
    #server: https://acme-v02.api.letsencrypt.org/directory
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${CERT_EMAIL}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      # Secret resource used to store the account's private key
      name: ${ARGOCD_ISSUER_NAME}
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
            key: cert-admin-key.json
EOT


# Create certificate
ARGOCD_ISSUER_NAME="argocd-issuer"
ARGOCD_CERT_NAME="argocd-cert"
ARGOCD_CERT_SECRET_NAME="argocd-tls"

echo "Creating argocd certificate ..."

cat <<EOT > "${ARGOCD_CERTS_PATH}/certificate.yaml"
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${ARGOCD_CERT_NAME}
spec:
  secretName: ${ARGOCD_CERT_SECRET_NAME}
  issuerRef:
    name: ${ARGOCD_ISSUER_NAME}
    kind: Issuer
  dnsNames:
  - ${ARGOCD_URL}
EOT


# Create argocd ingress
echo "Creating argocd ingress resources..."

cat <<EOT > ${ARGOCD_RESOURCES_PATH}/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/service-upstream: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    cert-manager.io/issuer: ${ARGOCD_ISSUER_NAME}
spec:
  rules:
  - host: ${ARGOCD_URL}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
  tls:
  - hosts:
    - ${ARGOCD_URL}
    secretName: ${ARGOCD_CERT_SECRET_NAME}
EOT


# Install argo-cd resources
echo "Applying argo-cd resources..."
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.1.0/manifests/install.yaml
kubectl apply -k ${MANIFESTS_REPO_PATH}/bases/cluster-resources/argo-cd

