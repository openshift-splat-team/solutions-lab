import os
import shutil

from .logs import *
from .utils import *
from .hooks import *

# TODO: move to a before-execute hook
def print_version(cluster_dir):
    exec_cmd(
        cmd="bin/openshift-install version", 
        cluster_dir=cluster_dir,
        log_name="openshift-version",
        shell=True)

def create_cluster(cluster_dir, cluster_name, env):
    cluster_bin_dir = f"{cluster_dir}/bin"
    env["PATH"] = f"{cluster_bin_dir}:{env['PATH']}"
    cluster_create = run_hook(cluster_dir, cluster_name, "cluster-create", env)
    
    info("cluster created")
    auth_file=f"{cluster_dir}/auth/kubeconfig"
    if os.path.exists(auth_file):
        auth_file_path = os.path.abspath(auth_file)
        env["KUBECONFIG"] = auth_file_path
        info(f"export KUBECONFIG={auth_file}")

    else:
        warn(f"auth file not found at {auth_file}")
        #TODO: Error, prune and exit?

def destroy_cluster(cluster_dir, env):
    exec_cmd(
        cmd="bin/openshift-install destroy cluster", 
        cluster_dir=cluster_dir,
        log_name="destroy-cluster",
        shell=True,
        env=env)

def backup_install_config(cluster_dir):
    install_config = f"{cluster_dir}/install-config.yaml"
    #copy if exists, warn if not
    if not os.path.exists(install_config):
        info(f"install-config.yaml not found at {install_config}")
        return None
    backup_dir = os.path.join(cluster_dir, 'backup')
    backup_file = os.path.join(backup_dir, 'install-config.yaml')
    os.makedirs(backup_dir, exist_ok=True)
    try:
        shutil.copy(install_config, backup_file)
    except Exception as e:
        warn(f"Failed to back up install-config: {e}")
        return None
    info(f"Copied install-config to {backup_file}")
