import os
import subprocess
from . import *

def exec_hook(cluster_dir, cluster_name, hook_script):
    # Set up the logging configuration
    log_dir = f"{cluster_dir}/logs"
    os.makedirs(log_dir, exist_ok=True)
    log_file = f"{log_dir}/{os.path.basename(hook_script)}.log"
    info(f"Executing {hook_script}...")
    try:
        with open(log_file, "w") as f:
            # Start the subprocess using cluster_dir as the working directory
            env = os.environ.copy()
            env["CLUSTER_DIR"] = "."
            env["CLUSTER_NAME"] = cluster_name
            process = subprocess.Popen(
                ["bash", hook_script],
                cwd=cluster_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                env=env
            )

            new_env = {}
            for line in process.stdout:
                info(line)
                f.write(line)
                if (line.startswith("#|")):
                    # remove the leading "#|" and split, adding key and value to kew_env
                    key, value = line[2:].split("=")
                    new_env[key] = value
            # update the environment with the new values
            info(f"Updating environment with {len(new_env)} variables")
            env.update(new_env)

            # Wait for the process to complete and get the return code
            process.wait()        
            return (process.returncode, new_env)
        
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to execute {hook_script}. Error: {e}")
        with open(log_file, "a") as f:
             f.write(e.stderr)


def run_hook(cluster_dir, cluster_name, hook):
    # check if there is a {hook.sh} and execute it if so
    # return the exit code from the process
    # log the output to {cluster_dir}/logs/{hook}.log
    hook_script = f"{hook}.sh"
    hook_path = f"{cluster_dir}/{hook_script}"
    if os.path.exists(hook_path):
        result = exec_hook(cluster_dir, cluster_name, hook_script)
        returncode = result[0]
        if returncode != 0:
            info(f"Failed to execute {hook_script}")
            sys.exit(returncode)
        else:
            captures = result[1]
            captures_len = len(captures)
            info(f"{hook_script} executed successfully with {captures_len} captures")
            return result

