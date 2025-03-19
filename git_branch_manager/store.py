from __future__ import annotations

import dataclasses
import json
from pathlib import Path

from .git import git

@dataclasses.dataclass
class BranchInfo:
    name: str
    base: str | None
    deps: list[str]
    tags: set[str]
    group: str | None

    @classmethod
    def new(cls, name: str) -> BranchInfo:
        return cls(
            name=name,
            base=None,
            deps=[],
            tags=set(),
            group=None,
        )

    @classmethod
    def from_json(cls, name: str, data: dict):
        data["tags"] = data.get("tags", [])  # migration
        data["group"] = data.get("group")  # migration
        return cls(
            name=name,
            base=data["base"],
            deps=data["deps"],
            tags=set(data["tags"]),
            group=data["group"],
        )

    def to_json(self):
        return {
            "name": self.name,
            "base": self.base,
            "deps": self.deps,
            "tags": list(self.tags),
            "group": self.group,
        }

@dataclasses.dataclass
class BranchData:
    default_base: str | None
    branches: dict[str, BranchInfo]

    @classmethod
    def from_json(cls, o):
        default_base = o.get('default_base')
        branches = {
            branch: BranchInfo.from_json(branch, branch_info)
            for branch, branch_info in o['branches'].items()
        }
        return cls(default_base=default_base, branches=branches)

    def to_json(self):
        branches = {}
        for branch, branch_info in self.branches.items():
            branch_data = branch_info.to_json()
            del branch_data["name"]
            branches[branch] = branch_data

        return {
            'default_base': self.default_base,
            'branches': branches,
        }

def get_data_path() -> Path:
    git_dir = git('rev-parse', '--git-common-dir')
    return Path(git_dir) / 'branch-manager.json'

def load_data() -> BranchData:
    data_path = get_data_path()

    if not data_path.exists():
        return BranchData(default_base=None, branches={})

    data_text = data_path.read_text()
    return BranchData.from_json(json.loads(data_text))

def save_data(data: BranchData) -> None:
    data_path = get_data_path()

    data_text = json.dumps(data.to_json(), indent=2)
    data_path.write_text(data_text)
