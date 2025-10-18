# Configuration files

Highlights:

* I created [graphite-shim](https://github.com/brandonchinn178/graphite-shim) that uses Graphite for managing stacked branches, but provides a reimplementation that works on non-Graphite managed repos
* After each bash command, I print out an emoji representing the error code + the amount of time passed
* Ctrl+B opens a list of branches with fzf. If nothing is typed on the command line, the selected branch is checked out. If there's input on the command line already, the selected branches are copied in

## Installation

1. Install [Homebrew](https://brew.sh)
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

1. Install [Sublime Text](https://www.sublimetext.com/)
    1. See `sublime/README.md`

1. Install [Jetbrains Mono](https://www.jetbrains.com/lp/mono/)

1. `./install`

1. Settings:
    * Login Items: Maccy, noTunes, Aerospace
    * Displays have separate Spaces = enabled
    * Group windows by application = enabled
    * Keyboard shortcuts
        * Change "Mission Control" shortcut to ctrl+alt+shift+up
        * Disable "Application windows" shortcut
        * Change "Missiong Control > Move left a space" to ctrl+alt+shift+left
        * Change "Missiong Control > Move right a space" to ctrl+alt+shift+right

1. To use touch ID for sudo, copy the template at `/etc/pam.d/sudo_local.template` and uncomment the pam_tid.so line
