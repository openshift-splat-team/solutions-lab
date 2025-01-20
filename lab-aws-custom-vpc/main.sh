#!/bin/bash
set -x

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIRNAME="$(basename $DIR)"

export CLUSTER_NAME=${CLUSTER_NAME:-"$DIRNAME"}
export CLUSTER_DIR="$DIR/.cluster"
export STACK_NAME=${STACK_NAME:-"$DIRNAME"}
export SSH_KEY=${SSH_KEY:-$(cat $HOME/.ssh/id_rsa.pub)}

TEMPLATE_FILE="main.cfn.yaml"

# Deploy the CloudFormation stack
aws cloudformation deploy \
  --template-file $TEMPLATE_FILE \
  --stack-name $STACK_NAME \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for the stack to reach CREATE_COMPLETE status
aws cloudformation wait stack-create-complete \
  --stack-name $STACK_NAME

# Output the stack details
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query "Stacks[0].Outputs"

# Retrieve the private subnet IDs
PRIVATE_SUBNET_1_ID=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet1Id'].OutputValue" \
  --output text)

PRIVATE_SUBNET_2_ID=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet2Id'].OutputValue" \
  --output text)

PRIVATE_SUBNET_3_ID=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet3Id'].OutputValue" \
  --output text)

echo "Private Subnet 1 ID: $PRIVATE_SUBNET_1_ID"
echo "Private Subnet 2 ID: $PRIVATE_SUBNET_2_ID"
echo "Private Subnet 3 ID: $PRIVATE_SUBNET_3_ID"

mkdir -p $CLUSTER_DIR

envsubst < $DIR/install-config.env.yaml > $CLUSTER_DIR/install-config.yaml
cp $CLUSTER_DIR/install-config.yaml $CLUSTER_DIR/install-config.backup.yaml