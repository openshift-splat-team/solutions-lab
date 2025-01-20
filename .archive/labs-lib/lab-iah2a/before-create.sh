#!/bin/bash
set -e

echo "Verifying AWS Identity"
aws sts get-caller-identity
sleep 5

echo "Hook [before-create] completed."
