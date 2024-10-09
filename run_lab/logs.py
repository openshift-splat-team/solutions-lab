import logging

# Configure the logging settings
logging.basicConfig(
    level=logging.DEBUG,                  # Set the logging level
    format='%(asctime)s - %(levelname)s - %(message)s',  # Specify the log message format
    datefmt='%Y-%m-%d %H:%M:%S'           # Specify the date format
)

def info(msg, *args, **kwargs):
    # log with python logging
    # if message ends with newline remove it
    if msg.endswith("\n"):
        msg = msg[:-1]
    logging.info(msg, *args, **kwargs)

def debug(msg, *args, **kwargs):
    # log with python logging
    # if message ends with newline remove it
    if msg.endswith("\n"):
        msg = msg[:-1]
    logging.info(msg, *args, **kwargs)
