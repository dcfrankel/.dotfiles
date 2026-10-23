# config.nu
#
# Installed by:
# version = "0.116.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

const DOTFILES = ($nu.home-dir | path join ".dotfiles")

#### PATH ####
# macOS system paths, only when nu wasn't started from a login shell
# (path_helper normally adds these via /etc/zprofile)
if ($env.PATH? | default [] | is-empty) and ('/etc/paths' | path exists) {
  $env.PATH = (open /etc/paths | lines) ++ (glob /etc/paths.d/* | each { open | lines } | flatten)
}

# Share sh/path.sh with zsh/bash: apply it to the current PATH in sh and read the result back
const PATH_FILE = ($DOTFILES | path join "sh/path.sh")
if ($PATH_FILE | path exists) {
  $env.PATH = (
    with-env { PATH_FILE: $PATH_FILE } { ^/bin/sh -c '. "$PATH_FILE" && printf "%s" "$PATH"' }
    | split row (char esep) | uniq
  )
}

#### Env vars ####
# Set the default configuration file location used by many programs
$env.XDG_CONFIG_HOME = ($nu.home-dir | path join ".config")

# Set starship config path
$env.STARSHIP_CONFIG = ($DOTFILES | path join "starship/starship.toml")

# Set neovim as the default editor
$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'
$env.config.buffer_editor = 'nvim'

# Colors for ls, tree, and other tools (see sh/colors.sh)
$env.CLICOLOR = '1'
$env.LSCOLORS = 'ExGxxxxxCxxxxxxxxxxxxx'
$env.LS_COLORS = 'di=1;34:ln=1;36:ex=1;32:*.tar=31:*.gz=31:*.tgz=31:*.zip=31:*.bz2=31:*.xz=31:*.7z=31'

#### Nushell Configs ####
# Disable the startup banner
$env.config.show_banner = false

#### Aliases ####
# Launch emacs in headless mode (no window) and spawn a daemon if one doesn't exist
alias e = emacsclient --tty --alternate-editor=""

#### Source external binary configurations ####
source ($DOTFILES | path join "nushell/externals.nu")

#### Work Specific Configs ####
const WORK_CONFIGS_FILE = ($nu.home-dir | path join ".config/nushell/work.nu")
source (if ($WORK_CONFIGS_FILE | path exists) { $WORK_CONFIGS_FILE } else { null })

# Add starship support
autoload-external starship { starship init nu }
