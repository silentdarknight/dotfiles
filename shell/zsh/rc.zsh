autoload -Uz compinit promptinit
zstyle ':completion:*' menu select

# Autocompletion of command line switches for aliases.
setopt COMPLETE_ALIASES

# pkgfile includes a "command not found" hook that will automatically search the official repositories, when entering an unrecognized command.
source /usr/share/doc/pkgfile/command-not-found.zsh
