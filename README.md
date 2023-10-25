# Configuration files

Highlights:

* I have a whole `git-bb` system that tracks dependencies for my branches (`bb` stands for "base branch")
    * For example, `git bb-rebase` will automatically rebase on top of any required branches
* After each bash command, I print out an emoji representing the error code + the amount of time passed
* Ctrl+B opens a list of branches with fzf. If nothing is typed on the command line, the selected branch is checked out. If there's input on the command line already, the selected branches are copied in

## Installation

1. Install [Homebrew](https://brew.sh)
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
1. Install [Sublime Text](https://www.sublimetext.com/)
    1. See `sublime/README.md`
1. `./install`
1. Open Rectangle and Maccy
1. Add Maccy and noTunes to Login Items

## Miscellaneous Mac setup

* Keyboard shortcuts
    * Change "Mission Control" shortcut to ctrl+alt+shift+up
    * Disable "Application windows" shortcut
    * Change "Missiong Control > Move left a space" to ctrl+alt+shift+left
    * Change "Missiong Control > Move right a space" to ctrl+alt+shift+right
