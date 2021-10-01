# GitOps Demo
> The following scripts creates a sample three-tier web application on GCP


|     status       |         script         | outcome |
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
| work in progress |`09-configure-argo-cd.sh`| |
|                  |`10-setup-cloud-build.sh`| |
|                  |`11-setup-argo-rollouts.sh`| |