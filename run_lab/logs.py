import logging
from rich.logging import RichHandler

CONSOLE_FORMAT = "%(message)s" 
FILE_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
LOG_FILE = "run_lab.log.txt"

logging.basicConfig(
    level="DEBUG",
    format=FILE_FORMAT,
    datefmt="[%X]",
    handlers=[
        logging.FileHandler(LOG_FILE),
    ]
)

console_handler = RichHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter(CONSOLE_FORMAT, datefmt="[%X]"))

logs = logging.getLogger("rich")
logs.addHandler(console_handler)

def info(msg, *args, **kwargs):
    if msg.endswith("\n"):
        msg = msg[:-1]
    kwargs.setdefault("stacklevel", 2)
    logs.info(msg, *args, **kwargs)

def debug(msg, *args, **kwargs):
    if msg.endswith("\n"):
        msg = msg[:-1]
    kwargs.setdefault("stacklevel", 2)
    logs.debug(msg, *args, **kwargs)

def warn(msg, *args, **kwargs):
    if msg.endswith("\n"):
        msg = msg[:-1]
    kwargs.setdefault("stacklevel", 2)
    logs.warning(msg, *args, **kwargs)
