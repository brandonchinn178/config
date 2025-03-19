import sys
from typing import Optional

class ANSI:
    RESET = "\x1b[0m"
    DEFAULT = "\x1b[39m"
    GREEN = "\x1b[32m"
    CYAN = "\x1b[36m"
    BLUE = "\x1b[94m"
    YELLOW = "\x1b[33m"

def abort(s: str, *, prefix: Optional[str] = None):
    message = f'ERROR: {s}'

    if prefix:
        message = f'({prefix}) {message}'

    print(message, file=sys.stderr)
    sys.exit(1)
