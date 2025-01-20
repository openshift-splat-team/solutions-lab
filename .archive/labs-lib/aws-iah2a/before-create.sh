#!/bin/bash
set -e

echo "Verifying AWS Identity"
aws sts get-caller-identity
sleep 5

echo "Deploying cloudformation stack [$CLUSTER_NAME]"
aws cloudformation deploy \
    --stack-name "$CLUSTER_NAME" \
    --template-file "$CLUSTER_DIR/main.cfn.yaml" \
    --capabilities "CAPABILITY_NAMED_IAM"

echo "Waiting for the stack to be created"
sleep 15 #TODO replace with waiter

echo "Fetching the stack outputs"

# Fetch and assign the VPC ID
VPC_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='VPCId'].OutputValue" --output text)
echo "#| VPC_ID=$VPC_ID"

# Fetch and assign the Internet Gateway ID
INTERNET_GATEWAY_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='InternetGatewayId'].OutputValue" --output text)
echo "#| IGW_ID=$INTERNET_GATEWAY_ID"

# Fetch and assign the Public Subnet 1 ID
PUBLIC_SUBNET1_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1Id'].OutputValue" --output text)
echo "#| PUBLIC_SUBNET1_ID=$PUBLIC_SUBNET1_ID"

# Fetch and assign the Public Subnet 2 ID
PUBLIC_SUBNET2_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2Id'].OutputValue" --output text)
echo "#| PUBLIC_SUBNET2_ID=$PUBLIC_SUBNET2_ID"

# Fetch and assign the Public Subnet 3 ID
PUBLIC_SUBNET3_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet3Id'].OutputValue" --output text)
echo "#| PUBLIC_SUBNET3_ID=$PUBLIC_SUBNET3_ID"

# Fetch and assign the Isolated Subnet 1 ID
ISOLATED_SUBNET1_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='IsolatedSubnet1Id'].OutputValue" --output text)
echo "#| ISOLATED_SUBNET1_ID=$ISOLATED_SUBNET1_ID"

# Fetch and assign the Isolated Subnet 2 ID
ISOLATED_SUBNET2_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='IsolatedSubnet2Id'].OutputValue" --output text)
echo "#| ISOLATED_SUBNET2_ID=$ISOLATED_SUBNET2_ID"

# Fetch and assign the Isolated Subnet 3 ID
ISOLATED_SUBNET3_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='IsolatedSubnet3Id'].OutputValue" --output text)
echo "#| ISOLATED_SUBNET3_ID=$ISOLATED_SUBNET3_ID"

PRIVATE_SUBNET1_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet1Id'].OutputValue" --output text)
echo "#| PRIVATE_SUBNET1_ID=$PRIVATE_SUBNET1_ID"


PRIVATE_SUBNET2_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet2Id'].OutputValue" --output text)
echo "#| PRIVATE_SUBNET2_ID=$PRIVATE_SUBNET2_ID"


PRIVATE_SUBNET3_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet3Id'].OutputValue" --output text)
echo "#| PRIVATE_SUBNET3_ID=$PRIVATE_SUBNET3_ID"

# Fetch and assign the Public Route Table ID
PUBLIC_ROUTE_TABLE_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicRouteTableId'].OutputValue" --output text)
echo "#| PUBLIC_ROUTE_TABLE_ID=$PUBLIC_ROUTE_TABLE_ID"
export PUBLIC_ROUTE_TABLE_ID

echo "Cloudformation stack [$CLUSTER_NAME] created."
echo "Hook [before-create] completed."
