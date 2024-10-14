import logging
from rich.logging import RichHandler

CONSOLE_FORMAT = "%(message)s"  # Rich format for console
FILE_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"  # Regular format for file

LOG_FILE = "run_lab.log.txt"


# Configure logging for both console and file
logging.basicConfig(
    level="DEBUG",  # Set the logging level
    format=FILE_FORMAT,  # Use file format for the root logger
    datefmt="[%X]",
    handlers=[
        logging.FileHandler(LOG_FILE),  # File logging with regular format
    ]
)

# Create RichHandler for console logging
console_handler = RichHandler()
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(logging.Formatter(CONSOLE_FORMAT, datefmt="[%X]"))

# Get the root logger
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
