from __future__ import annotations

import dataclasses
from collections import defaultdict

from .api import Branch
from .store import BranchData
from .utils import ANSI

def show_branches(branches: list[Branch]) -> None:
    """
    Print all branches to stdout, formatted with branch manager info.
    """
    # build tree of branch dependencies
    branch_tree = BranchTree.init(branches)

    # print branches in groups
    groups = {branch.group for branch in branches}
    for group in sorted(groups, key=lambda s: "" if s is None else s):
        if group:
            print(f"\n{ANSI.YELLOW}[{group}]{ANSI.RESET}")
        print(branch_tree.filter(group=group).render())

@dataclasses.dataclass(frozen=True)
class BranchTree:
    branch_map: dict[str, Branch]
    children_map: dict[str, list[str]]

    @classmethod
    def init(cls, branches: list[Branch]) -> None:
        branch_map = {branch.name: branch for branch in branches}

        # include any deps that aren't in the branch map (e.g. branches based off a git tag)
        for branch in branches:
            for dep in branch.deps:
                if dep not in branch_map:
                    branch_map[dep] = Branch(
                        name=dep,
                        is_head=False,
                        is_worktree=False,
                        deps=[],
                        tags=set(),
                        group=None,
                    )

        children_map = defaultdict(list)
        for branch in branches:
            children_map.setdefault(branch.name, [])
            for dep in branch.deps:
                children_map[dep].append(branch.name)

        return cls(
            branch_map=branch_map,
            children_map=children_map,
        )

    @property
    def roots(self) -> list[str]:
        # roots = all branches - branches mentioned in deps
        roots = set(self.children_map.keys())
        for deps in self.children_map.values():
            roots -= set(deps)

        return roots

    def filter(self, *, group: str | None) -> BranchTree:
        # first pass - add branches in group + their ancestors
        branches = set()
        for branch in self.branch_map.values():
            if (group is None and branch.group is None) or (branch.group == group):
                branches.add(branch.name)
                queue = list(branch.deps)
                while len(queue) > 0:
                    curr = queue.pop()
                    branches.add(curr)
                    queue += self.branch_map[curr].deps

        # second pass - filter children_map
        children_map = {
            parent: [child for child in children if child in branches]
            for parent, children in self.children_map.items()
            if parent in branches
        }

        return dataclasses.replace(self, children_map=children_map)

    def render(self) -> str:
        def _sorted_branches(branches: list[str]) -> list[Branch]:
            return [self.branch_map[branch] for branch in sorted(branches)]

        def _render(branch: Branch, *, indent: int) -> str:
            return "\n".join([
                _render_branch(branch, indent=indent),
                *[
                    _render(dep, indent=indent + 1)
                    for dep in _sorted_branches(self.children_map[branch.name])
                ],
            ])

        def _render_branch(branch, *, indent: int = 0) -> str:
            indent_str = " " * (2 * indent)

            if branch.is_head:
                icon, color = "*", ANSI.GREEN
            elif branch.is_worktree:
                icon, color = "+", ANSI.CYAN
            else:
                icon, color = " ", ANSI.DEFAULT

            tags = ""
            if len(branch.tags) > 0:
                tags = "".join(f" {ANSI.BLUE}[{tag}]{ANSI.DEFAULT}" for tag in branch.tags)

            return f"{icon} {indent_str}{color}{branch.name}{ANSI.RESET}{tags}"

        return "\n".join(
            _render(root, indent=0)
            for root in _sorted_branches(self.roots)
        )
