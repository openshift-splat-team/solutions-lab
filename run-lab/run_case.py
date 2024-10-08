#!/usr/bin/env python

import sys
import datetime
import os
import errno
import logging
import subprocess
from .hooks import *

def copy(src, dst):
# coppy all files and directries from src to dest
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            mkdir(d)
            copy(s, d)
        else:
            with open(s, 'rb') as f:
                with open(d, 'wb') as f2:
                    f2.write(f.read())

def mkdir(path):
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

client_urls = {
    "openshift-install" : "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-install-linux.tar.gz",
    "oc" : "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz",
    "ccoctl" : "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/ccoctl-linux.tar.gz"
}

def install_client(cluster_dir, client):
    # download client package to temp dir, extract to cluster_dir/bin and delete package
    info(f"Downloading {client}...")
    client_url = client_urls[client]
    temp_dir = f"{cluster_dir}/temp"
    mkdir(temp_dir)
    client_package = f"{temp_dir}/{client}.tar.gz"
    os.system(f"curl -sL {client_url} -o {client_package}")
    bin_dir = f"{cluster_dir}/bin"
    mkdir(bin_dir)
    os.system(f"tar -C {bin_dir} -xzf {client_package}")
    os.system(f"rm {client_package}")
    del_file = f"{bin_dir}/README.md"
    os.system(f"rm {del_file}")
    info(f"{client} installed")


def verify_clients(cluster_dir):
# check if cluster dies contains a bin subdirectory with the expected executables, or else create the directory and download the binaries package, extract it and download it
    bin_dir = f"{cluster_dir}/bin"
    mkdir(bin_dir)
    clients = ["oc", "openshift-install", "ccoctl"]
    for client in clients:
        client_path = f"{bin_dir}/{client}"
        if not os.path.exists(client_path):
            install_client(cluster_dir, client)
        else:
            info(f"{client} verified")



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
    run_hook(cluster_dir, cluster_name, "before-create")

def main():
    case_dir = sys.argv[1]
    run_case(case_dir)
    
if __name__ == "__main__":
    main()
