import sys
from typing import Optional

def abort(s: str, *, prefix: Optional[str] = None):
    message = f'ERROR: {s}'

    if prefix:
        message = f'({prefix}) {message}'

    print(message, file=sys.stderr)
    sys.exit(1)
