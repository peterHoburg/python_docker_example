import logging
import os
import sys

log = logging.getLogger(__name__)
root_logger = logging.getLogger()

for handler in root_logger.handlers:
    root_logger.removeHandler(handler)

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

for handler in log.handlers:
    log.removeHandler(handler)

stream_handler = logging.StreamHandler(sys.stdout)
stream_handler.setFormatter(logging.Formatter("%(asctime)s - %(threadName)s - %(levelname)s - %(message)s"))
log.addHandler(stream_handler)

# if not os.environ.get("RACK_ENVIRON") == "debug":
#     logging.disable(logging.DEBUG)
