#!/bin/bash

aws cloudformation deploy \
    --stack-name "$CLUSTER_NAME" 
