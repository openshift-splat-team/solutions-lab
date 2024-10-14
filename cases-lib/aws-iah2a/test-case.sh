#!/bin/bash

$CLUSTER_DIR/bin/oc adm must-gather | tee $CLUSTER_DIR/log/must-gather.log.txt

