export AWS_REGION="us-east-1"
aws sts get-caller-identity
sleep 5

echo "Hook [before-create] completed."
