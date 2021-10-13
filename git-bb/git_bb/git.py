import re
import subprocess
from typing import Optional

def get_current_branch() -> str:
    branch = git('branch', '--show-current')
    if len(branch) == 0:
        raise NotOnBranchError()
    return branch

def branch_exists(branch: str) -> bool:
    try:
        git('show-ref', branch)
    except subprocess.CalledProcessError:
        return False
    else:
        return True

def resolve_branch(branch: Optional[str]) -> str:
    if branch is None:
        branch = get_current_branch()

    if not branch_exists(branch):
        raise MissingBranchError(branch)

    return branch

def get_default_base_branch() -> str:
    if branch_exists('main'):
        return 'main'

    if branch_exists('master'):
        return 'master'

    remote_info = git('remote', 'show', 'origin')
    return re.search('HEAD branch: (.*)$', remote_info, flags=re.M).group(1)

### Helpers ###

def git(*args) -> str:
    return subprocess.check_output(['git'] + list(args)).decode().strip()

def git_exec(*args) -> str:
    return subprocess.check_call(['git'] + list(args))

### Errors ###

class NotOnBranchError(Exception):
    def __str__(self):
        return 'Not currently on a branch'

class MissingBranchError(Exception):
    def __init__(self, branch: str):
        self.branch = branch

    def __str__(self):
        return f'Branch `{self.branch}` does not exist'
