#!/bin/bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


# Download argocd cli
#sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
#sudo chmod +x /usr/local/bin/argocd

# Connect to github repo

