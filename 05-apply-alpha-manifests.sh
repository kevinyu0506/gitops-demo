#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


CURRENT_PHASE="alpha" #development, alpha, beta, release
KUSTOMIZE_PATH="overlays/${CURRENT_PHASE}"


# Create ingress
ALPHA_INGRESS_PATH="${WORKDIR}/${MANIFESTS_REPO_NAME}/overlays/alpha/demo-apps/resources/ingress.yaml"

echo "Creating [${CURRENT_PHASE}] ingress resources..."
cat <<EOT > ${ALPHA_INGRESS_PATH}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/service-upstream: "true"
spec:
  rules:
  - host: ${ALPHA_FRONTEND_URL}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80

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
  - host: ${ALPHA_BACKEND_URL}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 5000
EOT


# Apply development resources
echo "Applying [${CURRENT_PHASE}] phase resources..."
kubectl apply -k ${MANIFESTS_REPO_PATH}/${KUSTOMIZE_PATH}
