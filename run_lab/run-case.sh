#!/bin/bash
# set -x

# echo "Executing test case [$CASE_NAME]"

# export CASE_DIR="$1"
# export CASE_NAME="$(basename $CASE_DIR)"

echo "Running case [$CASE_NAME] from [$CASE_DIR]"

export AWS_REGION=${AWS_REGION:-$(aws configure get region)}
export CLUSTER_NAME=${CLUSTER_NAME:-"$CASE_NAME-$(date +%H%M)"}
export CLUSTER_DIR=".run/$CLUSTER_NAME"
export SSH_KEY=$(cat $HOME/.ssh/id_rsa.pub)


# echo "Generating cluster configuration for case [$CASE_NAME] cluster [$CLUSTER_NAME]..."
# mkdir -p "$CLUSTER_DIR/log"

# echo "Copying case files to cluster directory..."
# cp -a $CASE_DIR/* $CLUSTER_DIR/

# Check if dir $CLUSTER_DIR/bin exists, if not copy from release
if [ ! -d "$CLUSTER_DIR/bin" ]; then
    echo "Copying binaries to cluster directory..."
    cp -a ./release-latest/bin $CLUSTER_DIR/bin
fi

if [ ! -d "$CLUSTER_DIR/bin" ]; then
    echo "Binaries not found, Exiting."
    exit 1
fi

# Load case properties
if [ -f "$CLUSTER_DIR/lab.properties" ]; then
    echo "Loading lab properties..."
    source "$CLUSTER_DIR/lab.properties"
fi

echo "Lab properties:"
echo "LAB_CLUSTER_RETAIN=$LAB_CLUSTER_RETAIN"
sleep 15


# if [ -f "$CLUSTER_DIR/before-create.sh" ]; then
#    echo "Executing before-create hook [$CLUSTER_DIR/before-create.sh]"
#     source "$CLUSTER_DIR/before-create.sh" | tee $CLUSTER_DIR/log/before-create.log.txt
#     # if that fails, exit
#     command_exit_status=$?
#     if [ $command_exit_status -ne 0 ]; then
#         echo "Before-create hook failed with exit code $command_exit_status."
#         exit $command_exit_status
# fi

# echo "Generating install-config.yaml..."
# envsubst < $CASE_DIR/install-config.env.yaml > $CLUSTER_DIR/install-config.yaml
# cp $CLUSTER_DIR/install-config.yaml $CLUSTER_DIR/install-config.bak.yaml




echo "Case [$CASE_NAME][$(date)] creating cluster [$CLUSTER_NAME]..."
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

echo "Case [$CASE_NAME][$(date)] cluster created."
echo "Creation time: $execution_time_minutes minutes"

# backup default kube config if exists with a timestamp
if [ -f $HOME/.kube/config ]; then
    cp $HOME/.kube/config $HOME/.kube/config.$(date +%s)
fi

# replace default kube config
# TODO: consider using environment variable instead of config file
cp $CLUSTER_DIR/auth/kubeconfig $KUBECONFIG $HOME/.kube/config

# Check status
$CLUSTER_DIR/bin/oc status | tee $CLUSTER_DIR/log/oc-status.log.txt

echo "Executing test..."
sleep 15

if [ -f "$CLUSTER_DIR/case-main.sh" ]; then
    echo "Executing main case hook [$CLUSTER_DIR/case-main.sh]"
    source "$CLUSTER_DIR/case-main.sh" | tee $CLUSTER_DIR/log/case-main.log.txt
fi

echo "Case [$CASE_NAME] collecting must gather..."
$CLUSTER_DIR/bin/oc adm must-gather | tee $CLUSTER_DIR/log/must-gather.log.txt
mv must-gather* $CLUSTER_DIR/log/

# if LAB_CLUSTER_RETAIN is set to true, retain the cluster
if [ "$LAB_CLUSTER_RETAIN" = "true" ]; then
    echo "Retaining cluster [$CLUSTER_NAME]"
    echo "When ready to dispose, use the following command"
    echo "$CLUSTER_DIR/bin/openshift-install destroy cluster --dir=$CLUSTER_DIR" | tee $CLUSTER_DIR/log/cluster-destroy.sh
else
    echo "Deleting cluster [$CLUSTER_NAME]"
    $CLUSTER_DIR/bin/openshift-install destroy cluster --dir=$CLUSTER_DIR

    if [ -f "$CLUSTER_DIR/after-destroy.sh" ]; then
        echo "Executing after-destroy hook [$CLUSTER_DIR/after-destroy.sh]"
        source "$CLUSTER_DIR/after-destroy.sh" | tee $CLUSTER_DIR/log/after-destroy.log.txt
    fi
fi

echo "Case [$CASE_NAME] considering pruning..."
if [ -f "$CLUSTER_DIR/case-prune.sh" ]; then
    echo "Executing prune case hook [$CLUSTER_DIR/case-prune.sh]"
    source "$CLUSTER_DIR/case-prune.sh" | tee $CLUSTER_DIR/log/case-prune.log.txt
fi


echo "Case [$CASE_NAME] done!"
