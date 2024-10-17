#!/bin/bash
set -e

# https://github.com/mtulio/mtulio.labs/blob/6c0088fdcfbc84eee45d703c6d50bf4a427ddc16/labs/ocp-aws-scaling/setup-karpenter.md?plain=1

# VERSION="4.17.0"
# PULL_SECRET_FILE="${HOME}/.openshift/pull-secret-latest.json"
# RELEASE_IMAGE=quay.io/openshift-release-dev/ocp-release:${VERSION}-x86_64
# CLUSTER_NAME=lab-karpenter
# INSTALL_DIR=${HOME}/openshift-labs/karpenter-round2/$CLUSTER_NAME
# CLUSTER_BASE_DOMAIN=lab-scaling.devcluster.openshift.com
# SSH_PUB_KEY_FILE=$HOME/.ssh/id_rsa.pub
# REGION=us-east-1
# AWS_REGION=$REGION

echo "Hook [before-create] completed."
