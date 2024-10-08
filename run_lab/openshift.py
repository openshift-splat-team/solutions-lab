import os
import shutil

from .logs import *
from .utils import *

def print_version(cluster_dir):
    exec_cmd(
        cmd="bin/openshift-install version", 
        cluster_dir=cluster_dir,
        log_name="openshift-version",
        shell=True)

def create_cluster(cluster_dir, env):
    exec_cmd(
        cmd="bin/openshift-install create cluster", 
        cluster_dir=cluster_dir,
        log_name="create-cluster",
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

    # Create the backup directory if it doesn't exist
    os.makedirs(backup_dir, exist_ok=True)

    # Copy the install-config.yaml to the backup directory
    try:
        shutil.copy(install_config, backup_file)
        info(f"Backed up install-config to {backup_file}")
    except Exception as e:
        info(f"Failed to back up install-config: {e}")
        return None
    info(f"Backed up install-config")
