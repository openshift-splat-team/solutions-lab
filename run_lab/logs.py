import logging
from rich.logging import RichHandler

FORMAT = "%(message)s"
logging.basicConfig(
    level="INFO", 
    format=FORMAT, 
    datefmt="[%X]", 
    handlers=[RichHandler()]
)

logs = logging.getLogger("rich")

def info(msg, *args, **kwargs):
    # log with python logging
    # if message ends with newline remove it
    if msg.endswith("\n"):
        msg = msg[:-1]
    kwargs.setdefault("stacklevel", 2)
    logs.info(msg, *args, **kwargs)

def debug(msg, *args, **kwargs):
    # log with python logging
    # if message ends with newline remove it
    if msg.endswith("\n"):
        msg = msg[:-1]
    kwargs.setdefault("stacklevel", 2)
    logs.debug(msg, *args, **kwargs)

def warn(msg, *args, **kwargs):
    # log with python logging
    # if message ends with newline remove it
    if msg.endswith("\n"):
        msg = msg[:-1]
    kwargs.setdefault("stacklevel", 2)
    logs.warning(msg, *args, **kwargs)