# Aliases are resolved at parse time and
# can't be wrapped in `if`, so each tool's setup is written to its own vendor
# autoload script, which nushell loads after config.nu.

const AUTOLOAD_DIR = ($nu.data-dir | path join "vendor/autoload")
mkdir $AUTOLOAD_DIR

# Write the output of `gen` to an autoload script when `bin` is installed,
# otherwise remove any stale script so it can't reference a missing binary
def autoload-external [bin: string, gen: closure] {
  let file = $AUTOLOAD_DIR | path join $"($bin).nu"
  if (which $bin | is-not-empty) { do $gen | save -f $file } else { rm -f $file }
}

#### fzf related Configs ####
$env.FZF_DEFAULT_OPTS = '--style full'

# Use fd for completions if it's present on the system
if (which fd | is-not-empty) {
  $env.FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git'
  $env.FZF_CTRL_T_COMMAND = $env.FZF_DEFAULT_COMMAND
}
# Override default completions for 'cd foo**<tab>' to include hidden dirs.
# fzf's nushell integration uses its builtin walker (which skips .git) rather
# than a _fzf_compgen_dir hook.
$env.FZF_COMPLETION_DIR_OPTS = '--walker=dir,follow,hidden'

# Must come after the FZF_* vars since they're read when the script loads
autoload-external fzf { fzf --nushell }

#### Bat Configs ####
autoload-external bat { 'alias cat = bat --paging=never' }

#### Zoxide Configs ####
autoload-external zoxide {
  [(zoxide init nushell) 'alias cd = z' 'alias cdi = zi'] | str join "\n"
}

#### Neovim Configs ####
autoload-external nvim { 'alias vim = nvim' }

#### Claude Configs ####
# Force claude to use bash as the shell. Aliases can't set env vars, so wrap it.
autoload-external claude {
  r#'def --wrapped claude [...args] {
  with-env { SHELL: '/bin/bash' } { ^claude --permission-mode plan ...$args }
}'#
}

#### Lazygit Configs ####
if (which lazygit | is-not-empty) {
  # Set lazygit config path
  $env.LG_CONFIG_FILE = ($nu.home-dir | path join ".dotfiles/lazygit/config.yaml")
}
autoload-external lazygit { 'alias lg = lazygit' }
