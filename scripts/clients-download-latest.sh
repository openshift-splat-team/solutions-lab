#!/bin/bash
set -x 

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPO_DIR="$(dirname $DIR)"

export TARGET_DIR="$REPO_DIR/.bin"
mkdir -p "$TARGET_DIR"

# OpenShift Installer
mkdir -p "/tmp/openshift-installer"
wget -q  -O "/tmp/openshift-installer/openshift-install-linux.tar.gz" "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-install-linux.tar.gz"
tar zxvf "/tmp/openshift-installer/openshift-install-linux.tar.gz" -C "/tmp/openshift-installer"
mv  "/tmp/openshift-installer/openshift-install" "$TARGET_DIR"
rm "/tmp/openshift-installer/openshift-install-linux.tar.gz"
    
# Credentials Operator CLI
mkdir -p "/tmp/ccoctl"
wget -q  -O "/tmp/ccoctl/ccoctl-linux.tar.gz" "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/ccoctl-linux.tar.gz"
tar zxvf "/tmp/ccoctl/ccoctl-linux.tar.gz" -C "/tmp/ccoctl"
mv "/tmp/ccoctl/ccoctl" "$TARGET_DIR"
rm "/tmp/ccoctl/ccoctl-linux.tar.gz"

# OpenShift CLI
mkdir -p "/tmp/oc"
wget -q  -O "/tmp/oc/openshift-client-linux.tar.gz" "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz"
tar zxvf "/tmp/oc/openshift-client-linux.tar.gz" -C "/tmp/oc"
mv "/tmp/oc/oc" "$TARGET_DIR"
mv "/tmp/oc/kubectl" "$TARGET_DIR"
rm "/tmp/oc/openshift-client-linux.tar.gz"

$TARGET_DIR/openshift-install version

echo "OpenShift Clients Downloaded"
