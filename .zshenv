# .zshenv is sourced on all invocations of the shell, unless the -f option is set.
# It should contain commands to set the command search path, plus other important environment variables.
# .zshenv' should not contain commands that produce output or assume the shell is attached to a tty.
#
# Start configuration added by Zim install {{{
#
# User configuration sourced by all invocations of the shell
#
# contains exported variables that should be available to other programs

# Define Zim location
: ${ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim}
# }}} End configuration added by Zim install
#

export DOTFILES="$(dirname "$(dirname "$(readlink "${(%):-%N}")")")"
export CACHEDIR="$HOME/.local/share"
export VIM_TMP="$HOME/.vim-tmp"

[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR"
[[ -d "$VIM_TMP" ]] || mkdir -p "$VIM_TMP"

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

fpath=(
    $DOTFILES/zsh/functions
    /usr/local/share/zsh/site-functions
    $fpath
)

typeset -aU path

export EDITOR='nvim'
export GIT_EDITOR='nvim'
