from typing import List, Optional

from .git import git
from .store import BaseBranchData, BranchInfo

def get_all_registered_branches(data: BaseBranchData) -> List[str]:
    return list(data.branches.keys())

def get_branch_info(
    data: BaseBranchData,
    branch: str,
    *,
    missing_ok: bool = True,
) -> Optional[BranchInfo]:
    info = data.branches.get(branch)

    if info is None and not missing_ok:
        raise APIError(f'Branch `{branch}` is not registered')

    return info

def display_branch_info(data: BaseBranchData, branch: str) -> str:
    info = get_branch_info(data, branch)

    branch_display = ''

    if info:
        branch_display += info.base

        if len(info.deps) > 0:
            num_deps = len(info.deps)
            branch_display += f' + {num_deps} '
            branch_display += 'other' if num_deps == 1 else 'others'

        base = info.base
        if len(info.deps) > 0:
            # if a branch has dependencies, the first commit will be a merge commit
            last_merge = git('log', '--merges', '-n1', '--pretty=format:%H')
            if last_merge:
                base = last_merge

        commits_after_base = int(git('rev-list', '--count', '--first-parent', f'{base}..HEAD'))
        if commits_after_base > 0:
            branch_display += f' > [+{commits_after_base}]'

        branch_display += ' > '

    branch_display += branch

    return branch_display

def rename_branch(data: BaseBranchData, old_branch: str, new_branch: str) -> None:
    new_branch_data = {}

    for branch, info in data.branches.items():
        if branch == old_branch:
            branch = new_branch
        else:
            info = BranchInfo(
                name=branch,
                base=info.base if info.base != old_branch else new_branch,
                deps=[
                    dep if dep != old_branch else new_branch
                    for dep in info.deps
                ],
            )

        new_branch_data[branch] = info

    data.branches = new_branch_data

def set_base_branch(data: BaseBranchData, branch: str, *, base_branch: str) -> None:
    info = get_branch_info(data, branch)
    if info is None:
        info = BranchInfo(name=branch, base=base_branch, deps=[])
    else:
        info.base = base_branch

    data.branches[branch] = info

def add_dep_branches(data: BaseBranchData, branch: str, dep_branches: List[str]) -> None:
    info = get_branch_info(data, branch, missing_ok=False)
    for dep_branch in dep_branches:
        if dep_branch in info.deps:
            raise APIError(f'Could not add branch dependency: `{dep_branch}` is already a dependency')
        if dep_branch == info.base:
            raise APIError(f'Could not add branch dependency: `{dep_branch}` is the base branch')
        info.deps.append(dep_branch)

def rm_dep_branches(data: BaseBranchData, branch: str, dep_branches: List[str]) -> None:
    info = get_branch_info(data, branch)
    for dep_branch in dep_branches:
        if info and dep_branch in info.deps:
            info.deps.remove(dep_branch)

def delete_branch(data: BaseBranchData, branch: str) -> None:
    data.branches.pop(branch, None)
    for branch_info in data.branches.values():
        if branch in branch_info.deps:
            branch_info.deps.remove(branch)

def get_merge_deps_command(deps: List[str]):
    return ['git', 'merge', '--no-ff', '--no-edit', '--quiet', *deps]

### Errors ###

class APIError(Exception):
    pass
