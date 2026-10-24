# shellcheck shell=bash disable=SC1090,SC1091,SC1094
[[ ${__LILY_BASH_LOADED:-0} == 1 ]] && return
__LILY_BASH_LOADED=1

_lily_env=${XDG_CONFIG_HOME:-$HOME/.config}/lily-terminal/env.sh
[[ -r $_lily_env ]] || _lily_env=$(cd "$(dirname "${BASH_SOURCE[0]}")/../terminal-shell" 2>/dev/null && pwd)/env.sh
[[ -r $_lily_env ]] && . "$_lily_env"
unset _lily_env

[[ $- == *i* ]] || return

command -v fastfetch >/dev/null 2>&1 && fastfetch
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd cd)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"

[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
if [[ -r /usr/share/blesh/ble.sh ]]; then
  . /usr/share/blesh/ble.sh --noattach
  ble-face -s syntax_default fg=#F1F3E4 2>/dev/null || true
  ble-face -s syntax_command fg=#e2342a 2>/dev/null || true
  ble-face -s syntax_function_name fg=#e2342a 2>/dev/null || true
  ble-face -s command_builtin fg=#e2342a 2>/dev/null || true
  ble-face -s command_alias fg=#e2342a 2>/dev/null || true
  ble-face -s command_function fg=#e2342a 2>/dev/null || true
  ble-face -s command_file fg=#e2342a 2>/dev/null || true
  ble-face -s command_jobs fg=#e2342a 2>/dev/null || true
  ble-face -s command_keyword fg=#e83b30 2>/dev/null || true
  ble-face -s syntax_varname fg=#93D4E0 2>/dev/null || true
  ble-face -s syntax_param_expansion fg=#93D4E0 2>/dev/null || true
  ble-face -s syntax_history_expansion fg=#93D4E0 2>/dev/null || true
  ble-face -s syntax_glob fg=#93D4E0 2>/dev/null || true
  ble-face -s syntax_brace fg=#93D4E0 2>/dev/null || true
  ble-face -s syntax_delimiter fg=#93D4E0 2>/dev/null || true
  ble-face -s syntax_quoted fg=#A3C293 2>/dev/null || true
  ble-face -s syntax_quotation fg=#A3C293 2>/dev/null || true
  ble-face -s syntax_error fg=#FF6B6B 2>/dev/null || true
  ble-face -s syntax_comment fg=#949699 2>/dev/null || true
  ble-face -s auto_complete fg=#949699 2>/dev/null || true
fi
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

_lily_cfg=${XDG_CONFIG_HOME:-$HOME/.config}
[[ -r $_lily_cfg/bash/rashin.bash ]] && . "$_lily_cfg/bash/rashin.bash"
[[ -r $_lily_cfg/bash/user.bash ]] && . "$_lily_cfg/bash/user.bash"
unset _lily_cfg

if declare -F ble-attach >/dev/null; then
  ble-attach || true
fi
