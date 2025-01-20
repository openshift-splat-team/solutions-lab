from .logs import *
from .utils import *

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


