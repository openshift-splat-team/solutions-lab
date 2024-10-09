import os
import errno
import sys
import subprocess
import re

from .logs import *

def copy(src, dst):
# coppy all files and directries from src to dest
    cwd = os.getcwd()
    cmd = "cp -a %s/* %s/" % (src, dst)
    print("RUNNNING CMD: ", cmd) 
    exec_cmd(cmd, cluster_dir=cwd, log_name="case-copy", shell=True)

def mkdir(path):
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

pattern = r'^\s*#\|\s*(\S+)\s*=\s*(\S+.*)$'

def exec_cmd(cmd="/bin/false", cluster_dir=".", log_name="exec_cmd", env={}, shell=False):
    log_dir = f"{cluster_dir}/logs"
    os.makedirs(log_dir, exist_ok=True)
    log_file = f"{log_dir}/{log_name}.log"
    info(f"[{cluster_dir}]$ {cmd} > {log_file}")
    try:
        with open(log_file, "w") as f:
            process = subprocess.Popen(
                cmd,
                cwd=cluster_dir,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                shell=shell
            )
            new_env = {}
            for line in process.stdout:
                info(line)
                f.write(line)
                match = re.match(pattern, line)
                if match:
                    key = match.group(1).strip()
                    value = match.group(2).strip()
                    new_env[key] = value
            # update the environment with the new values
            debug(f"Captured {len(new_env)} variables {new_env.keys()}")
            env.update(new_env)

            # Wait for the process to complete and get the return code
            process.wait()
            info(f"[{cluster_dir}]$ [{cmd}] [{process.returncode}]")  
            return (process.returncode, env)   
         
    except subprocess.CalledProcessError as e:
        info(f"Failed to execute {cmd}. Error: {e}")
        with open(log_file, "a") as f:
             f.write(e.stderr)

def read_ssh_pub_key():
    # Path to the default SSH private key
    ssh_key_path = os.path.expanduser("~/.ssh/id_rsa.pub")

    # Check if the file exists
    if not os.path.exists(ssh_key_path):
        raise FileNotFoundError(f"SSH key not found at {ssh_key_path}")

    # Read the SSH key into a string
    with open(ssh_key_path, 'r') as file:
        ssh_key = file.read()
    
    return ssh_key

def load_extra_env(env):
    env["SSH_KEY"] = read_ssh_pub_key()
