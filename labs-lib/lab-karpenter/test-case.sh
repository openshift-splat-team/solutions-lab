#!/bin/bash

$CLUSTER_DIR/bin/oc adm must-gather | tee $CLUSTER_DIR/log/must-gather.log.txt

oc get machinesets -n openshift-machine-api

# oc get machinesets -n openshift-machine-api

# oc scale machineset -n openshift-machine-api --replicas=0 $(oc get machineset -n openshift-machine-api -o jsonpath='{.items[2].metadata.name}')

export CLUSTER_ID=$(oc get infrastructures cluster -o jsonpath='{.status.infrastructureName}')
echo "CLUSTER_ID: $CLUSTER_ID"

export MACHINESET_NAME=$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].metadata.name}')
echo "MACHINESET_NAME: $MACHINESET_NAME"

echo "Scale down third machine set"
oc scale machineset -n openshift-machine-api --replicas=0 $(oc get machineset -n openshift-machine-api -o jsonpath='{.items[2].metadata.name}')

export MACHINESET_SUBNET_NAME=$(oc get machineset -n openshift-machine-api $MACHINESET_NAME -o json | jq -r '.spec.template.spec.providerSpec.value.subnet.filters[0].values[0]')
echo "MACHINESET_SUBNET_NAME: $MACHINESET_SUBNET_NAME"

VPC_ID=$(aws ec2 describe-subnets --region $AWS_REGION --filters Name=tag:Name,Values=$MACHINESET_SUBNET_NAME --query 'Subnets[].VpcId' --output text)
echo "VPC_ID: $VPC_ID"

PRIVATE_SUBNET_IDS=$(aws ec2 describe-subnets \
    --region $AWS_REGION \
    --filters Name=vpc-id,Values=$VPC_ID \
    | jq -r '.Subnets[] | [{"Id": .SubnetId, "Name": (.Tags[] | select(.Key=="Name").Value) }]' \
    | jq -r '.[] | select(.Name | contains("private")).Id'  | tr '\n' ' ')
echo "PRIVATE_SUBNETS: $PRIVATE_SUBNET_IDS"

for i in $PRIVATE_SUBNET_IDS; do
    echo "Tagging subnet $i"
    aws ec2 create-tags --region $AWS_REGION --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
  --resources $i
done

echo "Start Kerpenter Setup"

oc apply -f deploy-karpenter/setup/base.yaml

echo "Deploying CSR Approver"

oc apply -f deploy-karpenter/setup/csr-approver.yaml

echo "Configuring Karpenter variables"

oc version

export KARPENTER_NAMESPACE=karpenter
export KARPENTER_VERSION=v1.0.0
export WORKER_PROFILE=$(oc get machineset -n openshift-machine-api $(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].metadata.name}') -o json | jq -r '.spec.template.spec.providerSpec.value.iamInstanceProfile.id')
export KUBE_ENDPOINT=$(oc get infrastructures cluster -o jsonpath='{.status.apiServerInternalURI}')

cat <<EOF
KARPENTER_NAMESPACE=$KARPENTER_NAMESPACE
KARPENTER_VERSION=$KARPENTER_VERSION
CLUSTER_NAME=$CLUSTER_NAME
WORKER_PROFILE=$WORKER_PROFILE
EOF

echo "Provision the infra required by Karpenter"
aws cloudformation create-stack \
    --stack-name karpenter-${CLUSTER_NAME} \
    --template-body file://./deploy-karpenter/setup/cloudformation.yaml \
    --parameters \
        ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME}

aws cloudformation wait stack-create-complete \
    --stack-name karpenter-${CLUSTER_NAME}


aws cloudformation describe-stacks \
    --stack-name karpenter-${CLUSTER_NAME}


echo "Karpenter resources completed"

echo "Installing karpenter with helm"

helm upgrade --install --namespace karpenter \
  karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version "1.0.6" \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "aws.defaultInstanceProfile=$WORKER_PROFILE" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set "settings.cluster-endpoint=$KUBE_ENDPOINT"

echo "Apply patches to fix karpenter default deployment on OpenShift"


echo "1) Remove custom SCC defined by karpenter inheriting from Namespace"
oc patch deployment.apps/karpenter -n karpenter --type=json -p="[{'op': 'remove', 'path': '/spec/template/spec/containers/0/securityContext'}]"

echo "2A) Mount volumes/creds created by CCO (CredentialsRequests)"
oc set volume deployment.apps/karpenter -n karpenter  --add -t secret -m /var/secrets/karpenter --secret-name=karpenter-aws-credentials --read-only=true

echo "2B) Set env vars required to use custom credentials and OpenShift specifics"
oc set env deployment.apps/karpenter -n karpenter  LOG_LEVEL=debug AWS_REGION=$AWS_REGION AWS_SHARED_CREDENTIALS_FILE=/var/secrets/karpenter/credentials CLUSTER_ENDPOINT=$KUBE_ENDPOINT

echo "3) Run karpenter on Control Plane"
oc patch deployment.apps/karpenter -n karpenter --type=json -p '[{
    "op": "add",
    "path": "/spec/template/spec/tolerations/-",
    "value": {"key":"node-role.kubernetes.io/master", "operator": "Exists", "effect": "NoSchedule"}
}]'

echo "4) Fix RBAC allowing karpenter to create nodeClaims"
oc patch clusterrole karpenter --type=json -p '[{
    "op": "add",
    "path": "/rules/-",
    "value": {"apiGroups":["karpenter.sh"], "resources": ["nodeclaims","nodeclaims/finalizers", "nodepools","nodepools/finalizers"], "verbs": ["create","update","delete","patch"]}
  }]'

echo "Check if the pods for Karpenter controller are running"

oc get pods -n karpenter

# Troubleshooting
# Getting events:
# oc get events -n karpenter --sort-by='.metadata.creationTimestamp'


echo "TODO"
