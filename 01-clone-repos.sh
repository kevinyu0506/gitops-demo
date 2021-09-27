#!/bin/bash
if [ ! -f "./env-variables.sh" ]
then
    echo "Please check if the variables ./env-variables.sh exists"
    return 1
else
    . ./env-variables.sh
fi


if [ ! -d ${FRONTEND_REPO_PATH} ]
then
    echo "Frontend repo does not exist, cloning repo..."
    git clone ${FRONTEND_REPO}
else
    echo "Frontend repo already exist, skipping this step..."
fi


if [ ! -d ${BACKEND_REPO_PATH} ]
then
    echo "Backend repo does not exist, cloning repo..."
    git clone ${BACKEND_REPO}
else
    echo "Backend repo already exist, skipping this step..."
fi


if [ ! -d ${MANIFESTS_REPO_PATH} ]
then
    echo "Manifests repo does not exist, cloning repo..."
    git clone ${MANIFESTS_REPO}
else
    echo "Manifests repo already exist, skipping this step..."
fi
