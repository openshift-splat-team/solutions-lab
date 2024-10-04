#!/bin/bash

aws sts get-caller-identity
sleep 5

aws cloudformation deploy \
    --stack-name "$CLUSTER_NAME" \
    --template-file "$CLUSTER_DIR/main.cfn.yaml" \
    --capabilities "CAPABILITY_NAMED_IAM"

# Fetch and assign the VPC ID
VPC_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='VPCId'].OutputValue" --output text)
echo "VPC ID: $VPC_ID"
export VPC_ID

# Fetch and assign the Internet Gateway ID
INTERNET_GATEWAY_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='InternetGatewayId'].OutputValue" --output text)
echo "Internet Gateway ID: $INTERNET_GATEWAY_ID"
export INTERNET_GATEWAY_ID

# Fetch and assign the Public Subnet 1 ID
PUBLIC_SUBNET1_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1Id'].OutputValue" --output text)
echo "Public Subnet 1 ID: $PUBLIC_SUBNET1_ID"
export PUBLIC_SUBNET1_ID

# Fetch and assign the Public Subnet 2 ID
PUBLIC_SUBNET2_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2Id'].OutputValue" --output text)
echo "Public Subnet 2 ID: $PUBLIC_SUBNET2_ID"
export PUBLIC_SUBNET2_ID

# Fetch and assign the Public Subnet 3 ID
PUBLIC_SUBNET3_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet3Id'].OutputValue" --output text)
echo "Public Subnet 3 ID: $PUBLIC_SUBNET3_ID"
export PUBLIC_SUBNET3_ID

# Fetch and assign the Isolated Subnet 1 ID
ISOLATED_SUBNET1_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='IsolatedSubnet1Id'].OutputValue" --output text)
echo "Isolated Subnet 1 ID: $ISOLATED_SUBNET1_ID"
export ISOLATED_SUBNET1_ID

# Fetch and assign the Isolated Subnet 2 ID
ISOLATED_SUBNET2_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='IsolatedSubnet2Id'].OutputValue" --output text)
echo "Isolated Subnet 2 ID: $ISOLATED_SUBNET2_ID"
export ISOLATED_SUBNET2_ID

# Fetch and assign the Isolated Subnet 3 ID
ISOLATED_SUBNET3_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='IsolatedSubnet3Id'].OutputValue" --output text)
echo "Isolated Subnet 3 ID: $ISOLATED_SUBNET3_ID"
export ISOLATED_SUBNET3_ID

# Fetch and assign the Public Route Table ID
PUBLIC_ROUTE_TABLE_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME --query "Stacks[0].Outputs[?OutputKey=='PublicRouteTableId'].OutputValue" --output text)
echo "Public Route Table ID: $PUBLIC_ROUTE_TABLE_ID"
export PUBLIC_ROUTE_TABLE_ID

echo "Hook [before-create] completed."
