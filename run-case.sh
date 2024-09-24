#!/bin/bash
set -x

echo "Executing test case [$1]"

export CASE_DIR="$1"
export CASE_NAME="$(basename $CASE_DIR)"

echo "Running case [$CASE_NAME] from [$CASE_DIR]"
sleep 15

export AWS_REGION=${AWS_REGION:-$(aws configure get region)}
export CLUSTER_NAME=${CLUSTER_NAME:-"$CASE_NAME-$(date +%H%M)"}
export CLUSTER_DIR=".run/$CLUSTER_NAME"
export SSH_KEY=$(cat $HOME/.ssh/id_rsa.pub)

echo "Generating cluster configuration for case [$1] cluster [$CLUSTER_NAME]..."
mkdir -p $CLUSTER_DIR
envsubst < $CASE_DIR/install-config.env.yaml > $CLUSTER_DIR/install-config.yaml
cp $CLUSTER_DIR/install-config.yaml $CLUSTER_DIR/install-config.bak.yaml

echo "Copying case files to cluster directory..."
cp -a $CASE_DIR/* $CLUSTER_DIR/

mkdir -p "$CLUSTER_DIR/log"

if [ -f "$CLUSTER_DIR/before-create.sh" ]; then
    echo "Executing before-create hook [$CLUSTER_DIR/before-create.sh]"
    source "$CLUSTER_DIR/before-create.sh" | tee $CLUSTER_DIR/log/before-create.log.txt
fi

echo "OpenShift version check"
$CLUSTER_DIR/bin/openshift-install version | tee $CLUSTER_DIR/log/openshift-version.log.txt


echo "Case [$1][$(date)] creating cluster [$CLUSTER_NAME]..."
sleep 15

start_time=$(date +%s)
$CLUSTER_DIR/bin/openshift-install create cluster --dir=$CLUSTER_DIR | tee $CLUSTER_DIR/log/create-cluster.log.txt
end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_time_minutes=$(echo "scale=2; $execution_time / 60" | bc)

command_exit_status=$?

if [ $command_exit_status -ne 0 ]; then
    echo "Command failed with exit code $command_exit_status."
    exit $command_exit_status
fi

if [ $execution_time -lt 300 ]; then
    echo "Execution time too low. Something went wrong."
    exit 1
fi

echo "Case [$1][$(date)] cluster created."
echo "Creation time: $execution_time_minutes minutes"

# backup default kube config if exists with a timestamp
if [ -f $HOME/.kube/config ]; then
    cp $HOME/.kube/config $HOME/.kube/config.$(date +%s)
fi

# replace default kube config
cp $CLUSTER_DIR/auth/kubeconfig $KUBECONFIG $HOME/.kube/config

# Check status
$CLUSTER_DIR/bin/oc status | tee $CLUSTER_DIR/log/oc-status.log.txt

echo "Executing test..."
sleep 15

if [ -f "$CLUSTER_DIR/case-main.sh" ]; then
    echo "Executing main case hook [$CLUSTER_DIR/case-main.sh]"
    source "$CLUSTER_DIR/case-main.sh" | tee $CLUSTER_DIR/log/case-main.log.txt
fi

echo "Case [$1][$(date)] collecting must gather..."
$CLUSTER_DIR/bin/oc adm must-gather | tee $CLUSTER_DIR/log/must-gather.log.txt
mv must-gather* $CLUSTER_DIR/log/

if [ -f "$CLUSTER_DIR/lab.cluster.retain" ]; then
    info "Retaining cluster [$CLUSTER_NAME]"
    info "When ready to dispose, use the following command"
    info "$CLUSTER_DIR/bin/openshift-install destroy cluster --dir=$CLUSTER_DIR"
else
    info "Deleting cluster [$CLUSTER_NAME]"
    $CLUSTER_DIR/bin/openshift-install destroy cluster --dir=$CLUSTER_DIR
fi

echo "Case [$1] considering pruning..."
if [ -f "$CLUSTER_DIR/case-prune.sh" ]; then
    echo "Executing prune case hook [$CLUSTER_DIR/case-prune.sh]"
    source "$CLUSTER_DIR/case-prune.sh" | tee $CLUSTER_DIR/log/case-prune.log.txt
fi


echo "Case [$1] done!"
