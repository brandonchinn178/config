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

def is_ancestor(old: str, new: str) -> bool:
    try:
        git('merge-base', '--is-ancestor', old, new)
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
