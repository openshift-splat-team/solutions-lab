#!/bin/bash

echo "Creating cluster [OpenShift+Karpenter]"

openshift-install create cluster --log-level=debug

echo "Cluster created"

