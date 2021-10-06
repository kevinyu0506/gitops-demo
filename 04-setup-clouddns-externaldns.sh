#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


# Create external-dns deployment
EXTERNAL_DNS_DEPLOYMENT_PATH="${MANIFESTS_REPO_PATH}/bases/cluster-resources/external-dns/resources/deployment.yaml"

echo "Creating external-dns deployment file ..."
cat <<EOT > ${EXTERNAL_DNS_DEPLOYMENT_PATH}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.8.0
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=${DOMAIN_NAME} # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
        - --provider=google
        - --registry=txt
        - --txt-owner-id=my-identifier
EOT


# Create external-dns service account workload identity
EXTERNALDNS_SERVICEACCOUNT="${EXTERNALDNS_SERVICEACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KUBERNETES_SERVICEACCOUNT="${PROJECT_ID}.svc.id.goog[external-dns/external-dns]"

echo "Creating external-dns service account [${EXTERNALDNS_SERVICEACCOUNT_NAME}]..."
gcloud iam service-accounts create ${EXTERNALDNS_SERVICEACCOUNT_NAME} --display-name ${EXTERNALDNS_SERVICEACCOUNT_NAME}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${EXTERNALDNS_SERVICEACCOUNT}" --role roles/dns.admin


echo "Linking KSA and GSA..."
gcloud iam service-accounts add-iam-policy-binding --role roles/iam.workloadIdentityUser --member "serviceAccount:${KUBERNETES_SERVICEACCOUNT}" ${EXTERNALDNS_SERVICEACCOUNT}


# Install external-dns resources
echo "Applying external-dns resources..."
kubectl apply -k "${MANIFESTS_REPO_PATH}/bases/cluster-resources/external-dns"


kubectl annotate serviceaccount --namespace=external-dns external-dns "iam.gke.io/gcp-service-account=${EXTERNALDNS_SERVICEACCOUNT}"


# Install nginx-ingress-controller resources
echo "Applying nginx-ingress-controller resources..."
kubectl apply -k "${MANIFESTS_REPO_PATH}/bases/cluster-resources/nginx-ingress-controller"


# Create a DNS zone in Cloud DNS
CLOUD_DNS_ZONE_DESCRIPTION="Automatically managed zone by external dns"

echo "Creating DNS zone [${CLOUD_DNS_ZONE_NAME}] in Cloud DNS..."
gcloud dns managed-zones create ${CLOUD_DNS_ZONE_NAME} \
    --description="${CLOUD_DNS_ZONE_DESCRIPTION}" \
    --dns-name="${DOMAIN_NAME}"


# Create domain name contact info
RESOURCES_PATH="${WORKDIR}/resources"
DOMAIN_NAME_CONTACTS_PATH="${RESOURCES_PATH}/domain-contacts.yaml"

mkdir -p ${RESOURCES_PATH}

echo "Creating domain name contact info..."
cat <<EOT > ${DOMAIN_NAME_CONTACTS_PATH}
allContacts:
  email: '${USER_EMAIL}'
  phoneNumber: '+1.8005550123'
  postalAddress:
    regionCode: 'US'
    postalCode: '94043'
    administrativeArea: 'CA'
    locality: 'Mountain View'
    addressLines: ['1600 Amphitheatre Pkwy']
    recipients: ['Jane Doe']
EOT


# Register a domain
echo "Registering domain [${DOMAIN_NAME}]..."
gcloud beta domains registrations register ${DOMAIN_NAME} \
    --contact-data-from-file="${DOMAIN_NAME_CONTACTS_PATH}" \
    --contact-privacy=private-contact-data \
    --yearly-price="12.00 USD" \
    --cloud-dns-zone="${CLOUD_DNS_ZONE_NAME}" \
    --quiet
