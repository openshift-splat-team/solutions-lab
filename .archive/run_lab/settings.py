import os
from dynaconf import Dynaconf

from .logs import *

def init_settings(cluster_dir):
    settings_files = ['settings.toml']
    cluster_settings_file = f'{cluster_dir}/settings.toml'
    cluster_settings_file_exists = os.path.exists(cluster_settings_file)
    if cluster_settings_file_exists:
        settings_files.append(cluster_settings_file)
    settings = Dynaconf(
        envvar_prefix="LAB",
        settings_files=settings_files
    )
    return settings
