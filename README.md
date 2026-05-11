# Personal Vim Setup

This project is a personal Vim configuration with the goal of using only custom themes and plugins. All scripts, plugins, and configurations are written using the new **vim9script**.

### Themes

* `darkula` : Dark colorscheme inspired by IntelliJ IDEA's Darcula theme.
* `plan9`   : Colorscheme inspired by the Plan 9 operating system.

### Custom Plugins

The plugins are located in `pack/plugins/`.

* `arrowkeys`       : Toggles arrow keys for navigation in normal and insert modes.
* `autoclosechars`  : Automatically closes character pairs like brackets and parentheses.
* `autoendstructs`  : Automatically inserts closing keywords for structures like `if` and `for`.
* `autowrite`       : Automatically saves modified buffers after a period of inactivity.
* `bufferonly`      : Command to close all buffers except the current one.
* `calculator`      : Evaluates mathematical expressions directly within the buffer.
* `checker`         : Asynchronous syntax checking and linting for various programming languages.
* `cmplwild`        : Automatically triggers wildmenu completion for commands and search patterns.
* `commentarium`    : Commands and mappings to comment and uncomment code blocks.
* `complementum`    : Customizable auto-popup completion engine with support for multiple sources.
* `cyclebuffers`    : Navigation tool to quickly list and switch between buffers.
* `documentare`     : Displays documentation for the word under the cursor using external tools.
* `echords`         : Provides Emacs-like keybindings in insert mode.
* `esckey`          : Maps a custom key to perform the escape function.
* `format`          : Integration with external tools to format code.
* `git`             : Git integration for managing repositories.
* `habit`           : Disables basic movement keys to encourage better editing habits.
* `lsp`             : Language Server Protocol client for enhanced coding features.
* `menu`            : Popup menus for spell checking and miscellaneous tasks.
* `pyvenv`          : Manage and activate Python virtual environments.
* `runprg`          : Executes the current buffer script.
* `scratch`         : Create and manage temporary scratch buffers and terminals.
* `se`              : A lightweight and simple file explorer.
* `searcher`        : Unified interface for fuzzy searching files, grep, and more.
* `session`         : Save, load, and manage sessions.
* `statusline`      : Custom statusline showing git branch and other useful information.
* `tabline`         : Custom tabline showing shortened file paths and modified status.
* `viewmode`        : Reader read-only mode while viewing code.
* `xkb`             : Manages and switches keyboard layouts.

### Installation

#### 1. Clone

    $ git clone https://github.com/gonzaru/vim-setup.git

#### 2. Copy

    # copy the full directory to your $HOME
    $ cp -r vim-setup ~/.vim

#### 3. Usage

* Needs a Vim version compiled with **+vim9script** support.

```
$ vim
```
