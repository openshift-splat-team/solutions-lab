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

def run_case(case_dir):
    info(f"Running test case [{case_dir}]...")
    # get the last path segment as cluster_prefix
    cluster_prefix = case_dir.split("/")[-1]
    # get current hour and minute as a stamp
    now = datetime.datetime.now()
    stamp = now.strftime("%H%M")
    cluster_name = f"{cluster_prefix}-{stamp}"
    info(f"Cluster name: {cluster_name}")
    cluster_dir = f".run/{cluster_name}"
    mkdir(cluster_dir)
    copy(case_dir, cluster_dir)
    verify_clients(cluster_dir)
    env = os.environ.copy()
    load_extra_env(env)
    before_create = run_hook(cluster_dir, cluster_name, "before-create", env)
    captures = {}
    if before_create:
        captures = before_create[1]
    render_etc(cluster_dir, captures)
    print_version(cluster_dir)
    backup_install_config(cluster_dir)
    create_cluster(cluster_dir, env)
    retain_cluster = True
    if not retain_cluster:
        # destroy_cluster(cluster_dir)
        after_destroy = run_hook(cluster_dir, cluster_name, "after-destroy", captures)
    info(f"Test case [{cluster_name}] completed")


def main():
    case_dir = sys.argv[1]
    run_case(case_dir)
    
if __name__ == "__main__":
    main()
