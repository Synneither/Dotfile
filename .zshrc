# Created by newuser for 5.9
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
alias yay="paru"
eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"
#语法检查和高亮 zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
#插件zinit
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
#开启tab上下左右选择补全
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit && compinit -i
# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"
# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"
# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"
# Use custom `less` colors for `man` pages.
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"
#fzf使用fd
export FZF_DEFAULT_COMMAND='fd --type f --type d --hidden --follow --exclude .git'
# 设置历史记录文件的路径
HISTFILE=~/.zsh_history
# 设置在会话（内存）中和历史文件中保存的条数，建议设置得大一些
HISTSIZE=5000
SAVEHIST=$HISTSIZE
# 忽略重复的命令，连续输入多次的相同命令只记一次
setopt HIST_IGNORE_DUPS
# 在多个终端之间实时共享历史记录 
setopt sharehistory
# 让新的历史记录追加到文件，而不是覆盖
setopt appendhistory
# 在历史记录中记录命令的执行开始时间和持续时间
setopt EXTENDED_HISTORY
#其他
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_find_no_dups
#Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
. "/home/synneither/.deno/env"
