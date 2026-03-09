# vim:et sts=2 sw=2 ft=zsh

_prompt_asciiship_vimode() {
  case ${KEYMAP} in
    vicmd) print -n '%S%#%s' ;;
    *) print -n '%#' ;;
  esac
}

if (( ! ${+functions[_prompt_asciiship_keymap_select]} )); then
  functions[_prompt_asciiship_keymap_select]=${widgets[zle-keymap-select]#user:}'
zle reset-prompt
zle -R'
  zle -N zle-keymap-select _prompt_asciiship_keymap_select
fi

typeset -g VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

autoload -Uz add-zsh-hook
# Depends on git-info module to show git information
typeset -gA git_info
if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format 'HEAD %F{green}(%c)'
  zstyle ':zim:git-info:action' format ' %F{yellow}(${(U):-%s})'
  zstyle ':zim:git-info:stashed' format '\$'
  zstyle ':zim:git-info:unindexed' format '!'
  zstyle ':zim:git-info:indexed' format '+'
  zstyle ':zim:git-info:ahead' format '>'
  zstyle ':zim:git-info:behind' format '<'
  zstyle ':zim:git-info:keys' format \
      'status' '%S%I%i%A%B' \
      'prompt' ' %%B%F{magenta}git:%b%c%s${git_info[status]:+"%f[${(e)git_info[status]}]"}%%b'
  add-zsh-hook precmd git-info
fi

# Compute which color to use for the username prompt fragment
if [[ $(id -u) -eq 0 ]]; then
  # current user is root
  _user_color='red'
else
  _user_color='yellow'
fi

# Compute which color to use for the hostname prompt fragment
if (( ${+SSH_TTY} )); then
  # we are currently on a remote machine via SSH
  _host_color='cyan'
else
  _host_color='green'
fi
_prompt_hostname='%B%F{${_host_color}}%m%f'

PS1='
%B%F{${_user_color}}%n%f%b@%B%F{${_host_color}}%m%f %F{blue}%~%f%b${(e)git_info[prompt]}${VIRTUAL_ENV:+" %B%F{yellow}venv:${VIRTUAL_ENV:t}%f%b"}
%B%(1j.%F{blue}*%f .)%(?..%F{red}%? )%F{green}$(_prompt_asciiship_vimode)%f%b '
unset RPS1
