[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# Requires the npm-no-sudo script be run first. Assumes default directories.
export NPM_PACKAGES="$HOME/.npm-packages"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules${NODE_PATH:+:$NODE_PATH}"
export PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"


export JAVA_HOME=/Library/Java/Home
export PATH=$PATH:$JAVA_HOME

export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"

export PS1='\u@\h | \W: $ '


export ANDROID_HOME=/usr/local/Caskroom/android-sdk/platform-tools


source $HOME/projects/dotfiles/shell/export.sh
source $HOME/projects/dotfiles/shell/function.sh
source $HOME/projects/dotfiles/shell/source.sh
source $HOME/projects/dotfiles/shell/alias.sh
