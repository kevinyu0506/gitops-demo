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


# Create ingress
echo "Creating [${CURRENT_PHASE}] ingress resources: ${BETA_INGRESS_PATH} ..."
cat <<EOT > ${BETA_INGRESS_PATH}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/service-upstream: "true"
    cert-manager.io/issuer: ${BETA_ISSUER_NAME}
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


# Apply development resources
echo "Applying [${CURRENT_PHASE}] phase resources..."
kubectl apply -k ${MANIFESTS_REPO_PATH}/${KUSTOMIZE_PATH}
