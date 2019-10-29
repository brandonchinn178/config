import os
import subprocess

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
        folder = folders[0]

        diff_args = ['--staged'] if staged else []

        proc = subprocess.Popen(
            ['git', 'diff', '--name-only'] + diff_args,
            cwd=folder,
            stdout=subprocess.PIPE,
        )
        (stdout, _) = proc.communicate()

        modified_files = stdout.decode('utf-8').split()
        for file in modified_files:
            self.window.open_file(os.path.join(folder, file))
