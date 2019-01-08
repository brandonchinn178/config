# Sublime Text

## Packages

After installing Package Control, I use the following packages:

- GitGutter
- Maybs Quit
- TrailingSpaces

## Preferences

Since Sublime Text configurations are configurable through the app, it's weird to version control, since saving from `Sublime Text > Preferences > Settings` would change the git repository elsewhere.

The following is simply a reference for Sublime settings that I use, that should go under `~/Library/Application Support/Sublime Text 3/Packages/User/`.

### Preferences.sublime-settings

Some basic exclusion patterns. Also enables Vintage, which exposes Vim key bindings in Sublime.

```
{
    "binary_file_patterns":
    [
        "*.eot",
        "*.ttf",
        "*.png",
        "*.jpg",
        "*.mp3",
        "*.mp4",
        "*.woff",
        "*.svg",
        "*.otf",
        ".DS_Store",
        "*.pyc",
        "*.o",
        "*.hi",
        "*.dyn_hi",
        "*.dyn_o",
        "*.dylib",
        "*.a",
        "*.min.*",
        "*.so",
        "*.dll",
        "*.class"
    ],
    "default_line_ending": "unix",
    "file_exclude_patterns":
    [
        "*.map"
    ],
    "folder_exclude_patterns":
    [
        "node_modules",
        ".sass-cache",
        ".git",
        ".stack-work",
        "venv",
        "*.egg",
        "*.egg-info"
    ],
    "ignored_packages": [],
    "font_size": 12,
    "scroll_past_end": true,
    "show_definitions": false,
    "translate_tabs_to_spaces": true,
    "vintage_start_in_command_mode": true
}
```

### Haskell-SublimeHaskell.sublime-settings

These are syntax settings for Haskell files using the `SublimeHaskell` package.

```
{
    "color_scheme": "Packages/SublimeHaskell/Themes/Hasky (Dark).tmTheme",
    "extensions": ["*.hs"],
    "tab_size": 2,
    "rulers": [100]
}
```

### SublimeHaskell.sublime-settings

These are settings for the `SublimeHaskell` package.

```
{
    "add_word_completions": true,
    "add_default_completions": true,
    "backends": {
        "No backend": {
            "default": true,
            "backend": "none"
        }
    }
}
```

### Default (OSX).sublime-keymap

Disables key bindings for changing font size and makes Ctrl+Tab change tabs sanely.

```
[
    { "keys": ["ctrl+tab"], "command": "next_view" },
    { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
    { "keys": ["super+equals"], "command": "unbound" },
    { "keys": ["super+plus"], "command": "unbound" },
    { "keys": ["super+minus"], "command": "unbound" },
    { "keys": ["super+shift+w"], "command": "close_all" },
    { "keys": ["super+shift+s"], "command": "save_all" },
    { "keys": ["ctrl+super+s"], "command": "prompt_save_as" }
]
```


