from pathlib import Path
import re
import subprocess
import webbrowser

import sublime
from sublime_plugin import WindowCommand

class OpenAllModifiedCommand(WindowCommand):
    """
    Defines a command that opens all modified files in the directory.
    """

    def run(self, staged=False):
        folders = self.window.folders()
        if len(folders) == 0:
            fail('ERROR: No folders open.')
        folder = Path(folders[0])

        diff_args = ['--staged'] if staged else []

        proc = subprocess.run(
            ['git', 'diff', '--diff-filter=dxb', '--name-only', '--relative'] + diff_args,
            cwd=folder,
            capture_output=True,
            encoding='utf-8',
        )

        modified_files = proc.stdout.split('\n')
        for file in modified_files:
            if file:
                self.window.open_file((folder / file).as_posix())


class OpenInGithubCommand(WindowCommand):
    """Defines a command that opens the current file in GitHub."""

    def run(self):
        sheet = self.window.active_sheet()
        if not sheet:
            fail('ERROR: no tab open.')

        file = sheet.file_name()
        if not file:
            fail('ERROR: no file open.')
        file = Path(file)

        repodir = self._get_output(
            ['git', 'rev-parse', '--show-toplevel'],
            cwd=file.parent,
            error='Could not get repo directory',
        )
        repodir = Path(repodir.strip())
        file = file.relative_to(repodir)

        remote_name = "origin"
        remote_url = self._get_output(
            ['git', 'remote', 'get-url', remote_name],
            cwd=repodir,
            error='Could not get remotes',
        ).strip()

        repo = re.match(r"git@github.com:([\w_/-]+)(\.git)?", remote_url).group(1)
        default_branch = self._get_default_branch(repodir, "origin")
        url = f'https://github.com/{repo}/blob/{default_branch}/{file.as_posix()}'
        webbrowser.open_new_tab(url)

    def _get_default_branch(self, repodir, remote_name):
        # this file only exists if we git cloned this repo originally
        head_ref_file = self._get_output(
            ["git", "rev-parse", "--git-path", f"refs/remotes/{remote_name}/HEAD"],
            cwd=repodir,
            error='Could not get git directory',
        ).strip()
        head_ref_file = Path(head_ref_file)
        if not head_ref_file.exists():
            out = self._get_output(
                ['git', 'ls-remote', '--symref', remote_name],
                cwd=repodir,
                error=f"Could not fetch refs for {remote_name}",
            )
            head_ref = next(
                line.rsplit(maxsplit=1)[0]
                for line in out.splitlines()
                if line.endswith("HEAD") and line.startswith('ref:')
            )
            head_ref_file.parent.mkdir(exist_ok=True, parents=True)
            head_ref_file.write_text(head_ref)

        return self._get_output(
            ['git', 'rev-parse', '--abbrev-ref', 'origin/HEAD'],
            cwd=repodir,
            error='Could not get default branch',
        ).split("/")[1].strip()

    def _get_output(self, args, *, error, **kwargs):
        kwargs = {
            "capture_output": True,
            "encoding": "utf-8",
            **kwargs,
        }
        proc = subprocess.run(args, **kwargs)
        if proc.returncode != 0:
            fail(f'ERROR: {error}\n{proc.stdout}\n{proc.stderr}')

        return proc.stdout

def fail(msg):
    sublime.error_message(msg)
    raise Exception
