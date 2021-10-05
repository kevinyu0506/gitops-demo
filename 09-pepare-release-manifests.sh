#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


CURRENT_PHASE="release" #development, alpha, beta, release
KUSTOMIZE_PATH="overlays/${CURRENT_PHASE}"


# Create issuer
RELEASE_CERTS_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/release/demo-apps/certs"

mkdir -p ${RELEASE_CERTS_PATH}

RELEASE_ISSUER_NAME="release-issuer"

echo "Creating release issuer ..."
cat <<EOT > "${RELEASE_CERTS_PATH}/issuer.yaml"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${RELEASE_ISSUER_NAME}
spec:
  acme:
    #server: https://acme-v02.api.letsencrypt.org/directory
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${CERT_EMAIL}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      # Secret resource used to store the account's private key
      name: ${RELEASE_ISSUER_NAME}
    solvers:
    # ACME DNS-01 provider configurations
    - dns01:
        cloudDNS:
          # The ID of the GCP project
          project: ${PROJECT_ID}
EOT


# Create certificate
RELEASE_CERT_NAME="release-cert"
RELEASE_CERT_SECRET_NAME="release-tls"

echo "Creating release certificate ..."
cat <<EOT > "${RELEASE_CERTS_PATH}/certificate.yaml"
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${RELEASE_CERT_NAME}
spec:
  secretName: ${RELEASE_CERT_SECRET_NAME}
  issuerRef:
    name: ${RELEASE_ISSUER_NAME}
    kind: ClusterIssuer
  dnsNames:
  - ${RELEASE_FRONTEND_URL}
  - ${RELEASE_BACKEND_URL}
EOT


# Create ingress
RELEASE_INGRESS_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/release/demo-apps/resources/ingress.yaml"

echo "Creating [${CURRENT_PHASE}] ingress resources..."
cat <<EOT > ${RELEASE_INGRESS_PATH}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/service-upstream: "true"
    cert-manager.io/cluster-issuer: ${RELEASE_ISSUER_NAME}
spec:
  rules:
  - host: ${RELEASE_FRONTEND_URL}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
  tls:
  - hosts:
    - ${RELEASE_FRONTEND_URL}
    secretName: ${RELEASE_CERT_SECRET_NAME}

---

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/service-upstream: "true"
spec:
  rules:
  - host: ${RELEASE_BACKEND_URL}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 5000
  tls:
  - hosts:
    - ${RELEASE_BACKEND_URL}
    secretName: ${RELEASE_CERT_SECRET_NAME}
EOT

