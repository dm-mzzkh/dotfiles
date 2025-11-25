#
# ~/.bashrc
#

[[ $- != *i* ]] && return

export PATH="$HOME/bin:$PATH"
export MANPAGER="nvim +Man!"
export EDITOR="nvim" 
export TERM="kitty" 
export TERMINAL="kitty" 
export BRONSER="firefox" 
export READER="zathura"
export PREFIX="~/.local"

export HISTFILE=$HOME/.bash_history
export TERM=xterm-256color

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups
shopt -s histappend


if [ -d "$HOME/.cargo/bin" ] ; then
    export PATH=$HOME/.cargo/bin:$PATH
fi
if [ -d "$HOME/.local/bin/scripts" ] ; then
    export PATH=$HOME/.local/bin/scripts:$PATH
fi
if [ -d "$HOME/.local/bin/system" ] ; then
    export PATH=$HOME/.local/bin/system:$PATH
fi
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

alias yaourt='paru'
alias yay='paru'
alias paru-find='paru -Slq | fzf --multi --preview "paru -Si {1}"'

alias rm='rm -i'

alias cat='bat -p --style=grid'
alias grep='rg'
alias cp='xcp'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ip='ip -c'


alias vim='nvim'
alias vi='nvim'
alias nano='nvim'
alias notes='nvim ~/Documents/vimwiki/notes/'

alias hrg='history | rg'

alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias lg='lazygit'


#PS1='[\u@\h \W]\$ ' old one

parse_git_branch() {
    git branch 2>/dev/null | grep '*' | sed 's/* /🌿/'
}

export PS1="\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$(parse_git_branch)$ "

echo -e "              Howdy, \033[35m$(whoami)\033[37m! from \033[35m$(hostnamectl hostname)\033[37m <3"
echo "   /ᐠ-˕-マ  ノ"
echo "乀(  J し)"

if type when >/dev/null 2>&1; then
    when cm
fi
if type show_tasks >/dev/null 2>&1; then
    show_tasks
fi

# zoxide
eval "$(zoxide init bash)"

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi
