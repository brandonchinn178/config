from __future__ import annotations

import dataclasses
import itertools
import re
import subprocess
from typing import List, Optional

from .git import branch_exists, git, is_ancestor
from .store import BranchData, BranchInfo

@dataclasses.dataclass(frozen=True)
class Branch:
    name: str
    is_head: bool
    is_worktree: bool
    deps: list[str]
    tags: set[str]
    group: str | None

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "is_head": self.is_head,
            "is_worktree": self.is_worktree,
            "deps": self.deps,
            "tags": list(self.tags),
            "group": self.group,
        }

def get_branches(data: BranchData) -> list[Branch]:
    # read branches from git
    sep = "\t"
    branch_format = sep.join([
        "%(HEAD)",
        "%(worktreepath)",
        "%(refname:short)",
    ])
    out = subprocess.run(
        ["git", "branch", f"--format={branch_format}"],
        check=True,
        capture_output=True,
        encoding="utf-8",
    ).stdout

    # parse branch information
    branches = []
    for line in out.splitlines():
        head_str, worktree_path, name = line.split(sep)
        info = get_branch_info(data, name)
        branch = Branch(
            name=name,
            is_head=head_str == "*",
            is_worktree=len(worktree_path) > 0,
            deps=(
                [
                    *([info.base] if info.base is not None else []),
                    *info.deps,
                ]
                if info
                else []
            ),
            tags=info.tags if info else set(),
            group=info.group if info else None,
        )
        branches.append(branch)

    # prune deps, such that
    #     {"a": ["main"], "b": ["main", "a"]}
    # becomes
    #     {"a": ["main"], "b": ["a"]}
    pruned_branches = []
    for branch in branches:
        pruned_deps = set(branch.deps)
        for dep, other_dep in itertools.product(branch.deps, repeat=2):
            if (
                dep != other_dep
                and dep in pruned_deps
                and other_dep in pruned_deps
                and is_reachable(from_=dep, to=other_dep, branches=branches)
            ):
                pruned_deps.remove(other_dep)
        pruned_branches.append(dataclasses.replace(branch, deps=list(pruned_deps)))

    return pruned_branches

def is_reachable(*, from_: str, to: str, branches: list[Branch]) -> bool:
    branch_map = {branch.name: branch.deps for branch in branches}

    def _is_reachable_from(node: str) -> bool:
        if node == to:
            return True
        for dep in branch_map.get(node, []):  # might not exist if tags
            if _is_reachable_from(dep):
                return True
        return False

    return _is_reachable_from(from_)

def get_all_registered_branches(data: BranchData) -> List[str]:
    return list(data.branches.keys())

def get_branch_info(
    data: BranchData,
    branch: str,
    *,
    missing_ok: bool = True,
) -> Optional[BranchInfo]:
    info = data.branches.get(branch)

    if info is None and not missing_ok:
        raise APIError(f'Branch `{branch}` is not registered')

    return info

def display_branch_info(data: BranchData, branch: str) -> str:
    info = get_branch_info(data, branch)

    branch_display = ''

    if info and info.base:
        branch_display += info.base

        if len(info.deps) > 0:
            num_deps = len(info.deps)
            branch_display += f' + {num_deps} '
            branch_display += 'other' if num_deps == 1 else 'others'

        base = get_base_ref(info)
        commits_after_base = int(git('rev-list', '--count', '--first-parent', f'{base}..HEAD'))
        if commits_after_base > 0:
            branch_display += f' > [+{commits_after_base}]'

        branch_display += ' > '

    branch_display += branch

    return branch_display

def get_base_ref(info: BranchInfo) -> str:
    """Return the ref that marks the last commit before this branch starts."""
    if info.base is None:
        raise ValueError("get_base_ref called with no base branch")

    if len(info.deps) == 0:
        return info.base

    # if we've done a merge of the branch deps, find that merge commit
    dep_merge = git('log', '--merges', '-n1', '--pretty=format:%H', f'{info.base}..HEAD')
    if dep_merge:
        return dep_merge

    # if we've manually rebased on any deps, return the latest one
    ancestor_deps = [dep for dep in info.deps if is_ancestor(dep, 'HEAD')]
    if ancestor_deps:
        latest = ancestor_deps[0]
        for dep in ancestor_deps[1:]:
            if is_ancestor(latest, dep):
                latest = dep
        return latest

    # if all else fails, just return the base branch
    return info.base

def rename_branch(data: BranchData, old_branch: str, new_branch: str) -> None:
    new_branch_data = {}

    for branch, info in data.branches.items():
        if branch == old_branch:
            branch = new_branch
        else:
            info = dataclasses.replace(
                info,
                base=new_branch if info.base == old_branch else info.base,
                deps = [
                    new_branch if dep == old_branch else dep
                    for dep in info.deps
                ],
            )

        new_branch_data[branch] = info

    data.branches = new_branch_data

def set_base_branch(data: BranchData, branch: str, *, base_branch: str) -> None:
    info = get_branch_info(data, branch)
    if info is None:
        info = BranchInfo.new(branch)
        data.branches[branch] = info

    info.base = base_branch

def unset_base_branch(data: BranchData, branch: str) -> None:
    info = get_branch_info(data, branch, missing_ok=False)
    info.base = None

def add_dep_branches(data: BranchData, branch: str, dep_branches: List[str]) -> None:
    info = get_branch_info(data, branch, missing_ok=False)
    if info.base is None:
        raise APIError(f'Could not add branch dependency: `{branch}` does not have a base branch')
    for dep_branch in dep_branches:
        if dep_branch in info.deps:
            raise APIError(f'Could not add branch dependency: `{dep_branch}` is already a dependency')
        if dep_branch == info.base:
            raise APIError(f'Could not add branch dependency: `{dep_branch}` is the base branch')
        info.deps.append(dep_branch)

def rm_dep_branches(data: BranchData, branch: str, dep_branches: List[str]) -> None:
    info = get_branch_info(data, branch)
    for dep_branch in dep_branches:
        if info and dep_branch in info.deps:
            info.deps.remove(dep_branch)

def set_default_base_branch(data: BranchData, base_branch: str | None) -> None:
    data.default_base = base_branch

def get_default_base_branch(data: BranchData) -> str:
    if data.default_base:
        return data.default_base

    if branch_exists('origin/main'):
        return 'main'

    if branch_exists('origin/master'):
        return 'master'

    remote_info = git('remote', 'show', 'origin')
    return re.search('HEAD branch: (.*)$', remote_info, flags=re.M).group(1)

def set_group(data: BranchData, branch: str, group: str) -> None:
    info = get_branch_info(data, branch)
    if info is None:
        info = BranchInfo.new(branch)
        data.branches[branch] = info

    info.group = group

def unset_group(data: BranchData, branch: str) -> None:
    info = get_branch_info(data, branch, missing_ok=False)
    info.group = None

def add_tag(data: BranchData, branch: str, tag: str) -> None:
    info = get_branch_info(data, branch)
    if info is None:
        info = BranchInfo.new(branch)
        data.branches[branch] = info

    info.tags.add(tag)

def rm_tag(data: BranchData, branch: str, tag: str) -> None:
    info = get_branch_info(data, branch, missing_ok=False)
    info.tags.remove(tag)

def delete_branch(data: BranchData, branch: str) -> None:
    data.branches.pop(branch, None)
    for branch_info in data.branches.values():
        if branch == branch_info.base:
            branch_info.base = None
        if branch in branch_info.deps:
            branch_info.deps.remove(branch)

def get_merge_deps_command(deps: List[str]):
    return ['git', 'merge', '--no-ff', '--no-edit', '--quiet', *deps]

### Errors ###

class APIError(Exception):
    pass
