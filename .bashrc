#
# ~/.bashrc
#

[[ $- != *i* ]] && return

. "$HOME/.shrc_common"

export PATH="/Users/dm/.gdvm/bin/current_godot:/Users/dm/.gdvm/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

if type show_tasks >/dev/null 2>&1; then
    show_tasks
fi

. "$HOME/.cargo/env"
eval "$(zoxide init bash)"

for _gp in /opt/homebrew/etc/bash_completion.d/git-prompt.sh \
           /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh \
           /usr/share/git-core/git-prompt.sh; do
  [ -r "$_gp" ] && { . "$_gp"; break; }
done
unset _gp
type __git_ps1 >/dev/null 2>&1 || __git_ps1() { :; }
export PS1="\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$(__git_ps1 '🌿%s')$ "
