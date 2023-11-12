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
            sublime.error_message('ERROR: No folders open.')
            return
        folder = Path(folders[0])

        diff_args = ['--staged'] if staged else []

        proc = subprocess.run(
            ['git', 'diff', '--diff-filter=dxb', '--name-only'] + diff_args,
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
            sublime.error_message('ERROR: no tab open.')
            return

        file = sheet.file_name()
        if not file:
            sublime.error_message('ERROR: no file open.')
            return
        file = Path(file)

        proc = subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'],
            cwd=file.parent,
            capture_output=True,
            encoding='utf-8',
        )
        gitdir = Path(proc.stdout.strip())
        file = file.relative_to(gitdir)

        proc = subprocess.run(
            ['git', 'remote', '-v'],
            cwd=gitdir,
            capture_output=True,
            encoding='utf-8',
        )
        repo = re.search(r'git@github\.com:(\w+/[^\s]+)', proc.stdout)[1]
        url = f'https://github.com/{repo}/blob/main/{file.as_posix()}'
        webbrowser.open_new_tab(url)
