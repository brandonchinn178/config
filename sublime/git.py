import os
import subprocess

import sublime
from sublime_plugin import WindowCommand

class OpenAllModifiedCommand(WindowCommand):
    """
    Defines a command that opens all modified files in the directory.
    """

    def run(self):
        folders = self.window.folders()
        if len(folders) == 0:
            sublime.error_message('ERROR: No folders open.')
            return
        folder = folders[0]

        proc = subprocess.Popen(
            ['git', 'ls-files', '-m'],
            cwd=folder,
            stdout=subprocess.PIPE,
        )
        (stdout, _) = proc.communicate()

        modified_files = stdout.decode('utf-8').split()
        for file in modified_files:
            self.window.open_file(os.path.join(folder, file))
