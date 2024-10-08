import os
import errno
import sys
import subprocess
import re

from .logs import *

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

pattern = r'^\s*#\|\s*(\S+)\s*=\s*(\S+.*)$'

def exec_cmd(cmd, cluster_dir, log_name, env, shell=False):
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
            info(f"Captured {len(new_env)} variables {new_env.keys()}")
            env.update(new_env)

            # Wait for the process to complete and get the return code
            process.wait()        
            return (process.returncode, env)   
         
    except subprocess.CalledProcessError as e:
        info(f"Failed to execute {cmd}. Error: {e}")
        with open(log_file, "a") as f:
             f.write(e.stderr)
