#!/usr/bin/env python

import sys
import datetime
import os
import errno
import logging
import subprocess

from .hooks import *
from .tools import *
from .logs import *
from .templates import *
from .openshift import *
from .settings import *

def run_tests(cluster_dir, env):
    # Run test-case.sh if exists
    test_script = f"{cluster_dir}/test-case.sh"
    if os.path.exists(test_script):
        exec_cmd(
            cmd="./"+test_script, 
            cluster_dir=cluster_dir,
            log_name="test-case",
            env=env,
            shell=True)

def run_case(case_dir):
    info(f"Running [{case_dir}]")
    settings = init_settings(case_dir)
    info("Settings loaded")
    info(pprint.pformat(settings.to_dict()))
    cluster_prefix = case_dir.split("/")[-1]
    now = datetime.datetime.now()
    timestamp_fmt = settings.get("LAB_TIMESTAMP_FORMAT", "%m%d%H%M") 
    stamp = now.strftime(timestamp_fmt)
    cluster_name = f"{cluster_prefix}-{stamp}"
    debug(f"Cluster name: {cluster_name}")
    cluster_dir = f".run/{cluster_name}"
    mkdir(cluster_dir)
    copy(case_dir, cluster_dir)
    info("Cluster dir populated [%s]", cluster_dir)
    env = os.environ.copy()
    env["CLUSTER_DIR"] = cluster_dir
    verify_clients(cluster_dir)
    load_extra_env(env)
    before_create = run_hook(cluster_dir, cluster_name, "before-create", env)
    captures = {}
    if before_create:
        captures = before_create[1]
    render_etc(cluster_dir, captures)
    print_version(cluster_dir)
    backup_install_config(cluster_dir)
    create_cluster(cluster_dir, cluster_name, env)
    run_tests(cluster_dir, env)
    retain_cluster = settings.get("LAB_CLUSTER_RETAIN", True)
    info("Retain cluster: %s", retain_cluster)
    if not retain_cluster:
        destroy_cluster(cluster_dir, env)
        info("Cluster destroyed, trying after-destroy hook")
        after_destroy = run_hook(cluster_dir, cluster_name, "after-destroy", captures)
        info("Cluster disposal completed")
    info(f"Test case [{cluster_name}] completed")


def main():
    case_dir = sys.argv[1]
    run_case(case_dir)
    
if __name__ == "__main__":
    main()
