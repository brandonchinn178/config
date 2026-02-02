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

1. Install [Zed](https://zed.dev)
    1. In command prompt, run "cli: install cli binary"

1. Install fonts
    * [Jetbrains Mono](https://www.jetbrains.com/lp/mono/)
    * [Symbols Nerd Font](https://www.nerdfonts.com/font-downloads)

1. `./install`

1. Settings:
    * Login Items: Maccy, noTunes, Aerospace
    * Displays have separate Spaces = enabled
        * Necessary to workaround [menu bar issue](https://github.com/nikitabobko/AeroSpace/issues/594#issuecomment-3034609631), but causes [other issues](https://github.com/nikitabobko/AeroSpace/issues/101)
    * Group windows by application = enabled
    * Keyboard shortcuts
        * Change "Mission Control" shortcut to ctrl+alt+shift+up
        * Disable "Application windows" shortcut
        * Deselect "Mission Control > Move {left,right} a space" shortcuts

1. To use touch ID for sudo, copy the template at `/etc/pam.d/sudo_local.template` and uncomment the pam_tid.so line
