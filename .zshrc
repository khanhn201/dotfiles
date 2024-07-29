autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' *'
zstyle ':vcs_info:*' stagedstr ' +'
zstyle ':vcs_info:git:*' formats       '(%b%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)'
precmd () { vcs_info }
setopt PROMPT_SUBST

autoload -U colors && colors
PS1='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$fg[cyan]%}${vcs_info_msg_0_}%{$reset_color%}$%b '

# The following lines were added by compinstall
zstyle :compinstall filename '/home/nekoconn/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias vim=nvim

# nnn
nnn ()
{
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    command nnn "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f -- "$NNN_TMPFILE" > /dev/null
    }
}

venv()
{
  source ~/python_venv/$1/bin/activate
}
_venv_complete() {
  if (( CURRENT == 2 )); then
    local -a environments
    environments=(~/python_venv/*(/:t))
    _describe "environments" environments
  fi
}
compdef _venv_complete venv



# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt extendedglob
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install



# Created by `pipx` on 2024-06-19 16:50:39
export PATH="$PATH:/home/nekoconn/.local/bin"
