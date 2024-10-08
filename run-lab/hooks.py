import os
import subprocess
import sys

from .logs import *
from .utils import *


def exec_hook(cluster_dir, cluster_name, hook_script, env):
    # Set up the logging configuration
    info(f"Executing {cluster_dir}/{hook_script}...")
    # Start the subprocess using cluster_dir as the working directory
    env["CLUSTER_DIR"] = "."
    env["CLUSTER_NAME"] = cluster_name
    result = exec_cmd(["bash",hook_script], cluster_dir, hook_script, env)
    return result

def run_hook(cluster_dir, cluster_name, hook, env):
    # check if there is a {hook.sh} and execute it if so
    # return the exit code from the process
    # log the output to {cluster_dir}/logs/{hook}.log
    hook_script = f"{hook}.sh"
    hook_file = f"{hook_script}"
    hook_path = f"{cluster_dir}/{hook_script}"
    # TODO: validate, check 
    if os.path.exists(hook_path):
        result = exec_hook(cluster_dir, cluster_name, hook_file, env)
        returncode = result[0]
        if returncode != 0:
            info(f"Failed to execute {hook_script}, return code is {returncode}")
            sys.exit(returncode)
        else:
            captures = result[1]
            captures_len = len(captures)
            info(f"{hook_script} executed successfully with {captures_len} captures")
            return result

