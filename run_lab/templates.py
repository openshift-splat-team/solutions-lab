import os
import fnmatch

from .utils import *
from .logs import *

def find_files(cluster_dir, pattern):
    matched_files = []
    # Walk through each directory and subdirectory
    for root, dirs, files in os.walk(cluster_dir):
        # Filter files based on pattern
        for filename in fnmatch.filter(files, pattern):
            matched_files.append(os.path.join(root, filename))
    return matched_files

def render_envsubst(file, env):
    # render envsubst file with env
    # env is a dictionary of key value pairs
    # target file is the same as file wihtout .env extension
    file_name = os.path.basename(file)
    file_dir = os.path.dirname(file)
    target_file = file_name.replace(".env.", ".")
    cmd = f"envsubst < {file_name} > {target_file}"
    info(f"Running command: {cmd} at [{file_dir}]")
    exec_cmd(cmd, file_dir, file_name, env, True)


def render_etc(cluster_dir, env):
    # traverse cluster_dir recursivell and find all files with pattern *.env.*
    # for each file, render_envsubst(file)
    files = find_files(cluster_dir, "*.env.*")
    info(f"Processing {len(files)} extra text configuration files...")
    for file in files:
        render_envsubst(file, env)

