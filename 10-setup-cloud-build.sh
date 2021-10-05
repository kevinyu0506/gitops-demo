#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


# Create cloud source repo
gcloud source repos create ${BACKEND_REPO_NAME}
cd ${BACKEND_REPO_PATH}

echo "Creating backend cloudbuild.yaml..."

cat <<EOT > "${BACKEND_REPO_PATH}/cloudbuild.yaml"
steps:
# This step builds and tags the image
- name: 'gcr.io/cloud-builders/docker'
  entrypoint: 'bash'
  args: ['-c', 'docker build --build-arg BUILD_VERSION=\${_IMAGE_TAG} --build-arg ENV_PHASE=\${_BUILD_PHASE} -t gcr.io/${PROJECT_ID}/\${_IMAGE}:\${_IMAGE_TAG} .']
# This step pushes the image to the container registry
- name: 'gcr.io/cloud-builders/docker'
  entrypoint: 'bash'
  args: ['-c', 'docker push gcr.io/${PROJECT_ID}/\${_IMAGE}:\${_IMAGE_TAG}']
# This step updates the image tag in the manifests repository
#- name: 'gcr.io/cloud-builders/docker'
#  entrypoint: 'bash'
#  args: ['-c', 'docker run -e BUILD_PHASE=${_BUILD_PHASE} -e REPO_ACCESS_TOKEN=$$K8S_MANIFESTS_ACCESS_TOKEN -e REPO_URL=${_REPO_URL} -e KUSTOMIZE_PATH=${_KUSTOMIZE_PATH} -e GITHUB_USER=$$USERNAME -e GITHUB_USER_EMAIL=${_GITHUB_USER_EMAIL} -e IMAGE=${_IMAGE} -e IMAGE_TAG=${_IMAGE_TAG} kevinyu0506/update-kustomize-image:v1.5']
#  secretEnv: ['K8S_MANIFESTS_ACCESS_TOKEN', 'USERNAME']
substitutions:
  _BUILD_PHASE: alpha
#  _REPO_URL: https://github.com/billsgates/k8s-manifests.git
#  _KUSTOMIZE_PATH: overlays/\${_BUILD_PHASE}/billsgate-apps
#  _GITHUB_USER_EMAIL: kevinyu05062006@gmail.com
  _IMAGE: gitops-demo-backend
  _IMAGE_TAG: \${_BUILD_PHASE}-\${SHORT_SHA}
EOT

git add .
git commit -m "Init commit"
git remote add google https://source.developers.google.com/p/${PROJECT_NAME}/r/${BACKEND_REPO_NAME}
git push --all google

#gcloud source repos create ${FRONTEND_REPO_NAME}
#cd ${FRONTEND_REPO_PATH}
#git add .
#git commit -m "Init commit"
#git remote add google https://source.developers.google.com/p/${PROJECT_NAME}/r/${FRONTEND_REPO_NAME}


#gcloud source repos create ${MANIFESTS_REPO_NAME}
#cd ${MANIFESTS_REPO_PATH}
#git add .
#git commit -m "Init commit"
#git remote add google https://source.developers.google.com/p/${PROJECT_NAME}/r/${MANIFESTS_REPO_NAME}


