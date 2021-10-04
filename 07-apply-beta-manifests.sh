#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


CURRENT_PHASE="beta" #development, alpha, beta, release
KUSTOMIZE_PATH="overlays/${CURRENT_PHASE}"


# Create issuer
BETA_CERTS_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/beta/demo-apps/certs"

mkdir -p ${BETA_CERTS_PATH}

BETA_ISSUER_NAME="beta-issuer"

echo "Creating beta issuer ..."
cat <<EOT > "${BETA_CERTS_PATH}/issuer.yaml"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
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
    - dns01:
        cloudDNS:
          # The ID of the GCP project
          project: ${PROJECT_ID}
EOT


# Create certificate
BETA_CERT_NAME="beta-cert"
BETA_CERT_SECRET_NAME="beta-tls"

echo "Creating beta certificate ..."
cat <<EOT > "${BETA_CERTS_PATH}/certificate.yaml"
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${BETA_CERT_NAME}
spec:
  secretName: ${BETA_CERT_SECRET_NAME}
  issuerRef:
    name: ${BETA_ISSUER_NAME}
    kind: ClusterIssuer
  dnsNames:
  - ${BETA_FRONTEND_URL}
  - ${BETA_BACKEND_URL}
EOT


# Create ingress
BETA_INGRESS_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/beta/demo-apps/resources/ingress.yaml"

echo "Creating [${CURRENT_PHASE}] ingress resources..."
cat <<EOT > ${BETA_INGRESS_PATH}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/service-upstream: "true"
    cert-manager.io/cluster-issuer: ${BETA_ISSUER_NAME}
spec:
  rules:
  - host: ${BETA_FRONTEND_URL}
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
    - ${BETA_FRONTEND_URL}
    secretName: ${BETA_CERT_SECRET_NAME}

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
  - host: ${BETA_BACKEND_URL}
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
    - ${BETA_BACKEND_URL}
    secretName: ${BETA_CERT_SECRET_NAME}
EOT


# Apply beta resources
echo "Applying [${CURRENT_PHASE}] phase resources..."
kubectl apply -k ${MANIFESTS_REPO_PATH}/${KUSTOMIZE_PATH}
