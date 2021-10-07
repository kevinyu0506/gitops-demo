# GitOps in Google Cloud Platform
The following scripts create a sample three-tier web application on GCP, integrating services such as **Cloud DNS**, **Cloud Build**, **Google Kubernetes Engine** and other open source projects into an automated **GitOps solution**.


## Requirements
* kubectl version 1.22.1
```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.22.1/bin/linux/amd64/kubectl
```
* Cloud SDK
```
$ curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-360.0.0-linux-x86_64.tar.gz
```

## Progress
|     status       |         script         | verify |
|------------------|------------------------|--|
|    complete      |`00-generate-variables.sh`| |
|                  |`01-clone-repos.sh`| |
|                  |`02-create-cluster.sh`| |
|                  |`03-apply-development-manifests.sh`| |
|                  |`04-setup-clouddns-externaldns.sh`| |
|                  |`05-apply-alpha-manifests.sh`| visit http://my-alpha.gitops-demo-app.com (replace with your domain name)|
|                  |`06-setup-cert-manager.sh`| |
|                  |`07-apply-beta-manifets.sh`| visit http://my-beta.gitops-demo-app.com (replace with your domain name)|
|                  |`08-setup-argo-cd.sh`| visit http://argocd.gitops-demo-app.com (replace with your domain name)|
|                  |`09-prepare-release-manifests.sh`| |
