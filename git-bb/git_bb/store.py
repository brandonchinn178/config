import dataclasses
import json
from pathlib import Path
from typing import Dict, List

from .git import git

@dataclasses.dataclass
class BranchInfo:
    name: str
    base: str
    deps: List[str]

    @classmethod
    def from_json(cls, name, o):
        return cls(name=name, **o)

    def to_json(self):
        o = dataclasses.asdict(self)
        del o['name']
        return o

@dataclasses.dataclass
class BaseBranchData:
    branches: Dict[str, BranchInfo]

    @classmethod
    def from_json(cls, o):
        branches = {
            branch: BranchInfo.from_json(branch, branch_info)
            for branch, branch_info in o['branches'].items()
        }
        return cls(branches=branches)

    def to_json(self):
        return {
            'branches': {
                branch: branch_info.to_json()
                for branch, branch_info in self.branches.items()
            },
        }

def get_data_path() -> Path:
    git_dir = git('rev-parse', '--git-common-dir')
    return Path(git_dir) / 'base-branch-info'

def load_data() -> BaseBranchData:
    data_path = get_data_path()

    if not data_path.exists():
        return BaseBranchData(branches={})

    data_text = data_path.read_text()
    return BaseBranchData.from_json(json.loads(data_text))

def save_data(data: BaseBranchData) -> None:
    data_path = get_data_path()

    data_text = json.dumps(data.to_json(), indent=2)
    data_path.write_text(data_text)
