[[ ${__LILY_ZSH_LOADED:-0} == 1 ]] && return
__LILY_ZSH_LOADED=1

_lily_env=${XDG_CONFIG_HOME:-$HOME/.config}/lily-terminal/env.sh
[[ -r $_lily_env ]] || _lily_env=${${(%):-%N}:A:h}/../terminal-shell/env.sh
[[ -r $_lily_env ]] && source "$_lily_env"
unset _lily_env

[[ -o interactive ]] || return

command -v fastfetch >/dev/null 2>&1 && fastfetch

_lily_prompt=${RYOKU_ZSH_PROMPT:-starship}
_lily_omz=0
if [[ -r ${ZSH:-/usr/share/oh-my-zsh}/oh-my-zsh.sh ]]; then
  export ZSH=${ZSH:-/usr/share/oh-my-zsh}
  export ZSH_CUSTOM=${ZSH_CUSTOM:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh/oh-my-zsh}
  DISABLE_AUTO_UPDATE=true
  ZSH_COMPDUMP=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump
  (( ${+plugins} )) || plugins=(git)
  if [[ $_lily_prompt == oh-my-zsh ]]; then
    : ${ZSH_THEME:=robbyrussell}
  else
    ZSH_THEME=""
  fi
  source "$ZSH/oh-my-zsh.sh"
  _lily_omz=1
fi

if [[ $_lily_prompt != oh-my-zsh || $_lily_omz != 1 ]]; then
  command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
fi
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"

if (( ! _lily_omz )); then
  autoload -Uz compinit
  _cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
  mkdir -p "$_cache"
  compinit -d "$_cache/zcompdump"
  unset _cache
fi

[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#949699'
ZSH_HIGHLIGHT_STYLES[default]='fg=#F1F3E4'
ZSH_HIGHLIGHT_STYLES[command]='fg=#e2342a'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#e2342a'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#e2342a'
ZSH_HIGHLIGHT_STYLES[function]='fg=#e2342a'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#e2342a'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#e2342a'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#e2342a'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#e83b30'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#e83b30'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#e83b30'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#CCD0CF'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#CCD0CF'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#A3C293'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#A3C293'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#A3C293'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#8AA9CC'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#8AA9CC'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#8AA9CC'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#93D4E0'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#93D4E0'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#949699'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF6B6B'

if (( $+functions[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

_lily_cfg=${XDG_CONFIG_HOME:-$HOME/.config}
[[ -r $_lily_cfg/zsh/rashin.zsh ]] && source "$_lily_cfg/zsh/rashin.zsh"
[[ -r $_lily_cfg/zsh/user.zsh ]] && source "$_lily_cfg/zsh/user.zsh"

unset _lily_prompt _lily_omz
unset _lily_cfg
