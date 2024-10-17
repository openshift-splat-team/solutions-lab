#!/bin/bash

aws cloudformation delete-stack --stack-name "$CLUSTER_NAME" 

echo "Cloudformation stack [$CLUSTER_NAME] destroyed."
