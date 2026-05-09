# vim:et sts=2 sw=2 ft=zsh

_prompt_zircon_main() {
  # This runs in a subshell
  RETVAL=${?}
  CURRENT_BG=
  case ${KEYMAP} in
    vicmd)
      SEGMENT_SEPARATOR='%S%s'
      STANDOUT_SEGMENT_SEPARATOR='%s%S'
      ;;
    *)
      SEGMENT_SEPARATOR=''
      STANDOUT_SEGMENT_SEPARATOR=${SEGMENT_SEPARATOR}
      ;;
  esac

  _prompt_zircon_execution
  _prompt_zircon_status
  _prompt_zircon_pwd
  _prompt_zircon_git
  _prompt_zircon_end
}

### Segment drawing
# Utility functions to make it easy and re-usable to draw segmented prompts.

# Begin a segment. Takes two arguments, background color and contents of the
# new segment.
_prompt_zircon_segment() {
  print -n "%K{${1}}"
  if [[ -n ${CURRENT_BG} ]] print -n "%F{${CURRENT_BG}}${SEGMENT_SEPARATOR}"
  print -n ${2}
  CURRENT_BG=${1}
}

_prompt_zircon_standout_segment() {
  print -n "%S%F{${1}}"
  if [[ -n ${CURRENT_BG} ]] print -n "%K{${CURRENT_BG}}${STANDOUT_SEGMENT_SEPARATOR}%k"
  print -n "${2}%s"
  CURRENT_BG=${1}
}

# End the prompt, closing last segment.
_prompt_zircon_end() {
  print -n "%k%F{${CURRENT_BG}}${SEGMENT_SEPARATOR}%f "
}

### Prompt components
# Each component will draw itself, or hide itself if no information needs to
# be shown.

# Execution: start time, duration and return value of the last command.
_prompt_zircon_execution() {
  local segment=
  if [[ -n ${execution_start_info} ]] segment+=${execution_start_info}
  if [[ -n ${execution_duration_info} ]] segment+=${execution_duration_info}
  if [[ -n ${execution_start_info} ]]; then
    if (( RETVAL )) segment+=", returned ${RETVAL}"
  fi
  if [[ -n ${segment} ]]; then
    segment="--------
${segment}."
    print "%{\033[90m%}${segment}%{\033[0m%}"
  fi
}

# Status: Who and where am I (user@hostname)?
_prompt_zircon_status() {
  local segment=
  if [[ -n ${SSH_TTY} ]] segment+=' %F{%(!.yellow.green)}%n@%m'
  if [[ -n ${segment} ]]; then
    _prompt_zircon_segment ${STATUS_COLOR} ${segment}' '
  fi
}

# Pwd: current working directory.
_prompt_zircon_pwd() {
  local pwd_bg_color=${PWD_COLOR}
  if (( RETVAL )) pwd_bg_color=${ERR_COLOR}
  local current_dir
  prompt-pwd current_dir
  _prompt_zircon_standout_segment ${pwd_bg_color} ' '${current_dir}' '
}

# Git: branch/detached head, dirty status.
_prompt_zircon_git() {
  if [[ -n ${git_info} ]]; then
    local git_color
    if [[ -n ${(e)git_info[clean]} ]]; then
      git_color=${CLEAN_COLOR}
    else
      git_color=${DIRTY_COLOR}
    fi
    local git_prompt=${(e)git_info[ref]}
    local git_status=${(e)git_info[unindexed]}${(e)git_info[indexed]}
    if [[ -n ${git_status} ]] git_prompt+=' '${git_status}
    git_prompt+=${(e)git_info[action]}
    _prompt_zircon_standout_segment ${git_color} ' '${git_prompt}' '
  fi
}

_prompt_zircon_is_clear_command() {
  local -a command_words
  command_words=("${(z)1}")
  (( ${#command_words} )) || return 1

  if [[ ${command_words[1]} == command ]]; then
    shift command_words
  fi

  [[ ${command_words[1]} == clear || ${command_words[1]} == \\clear ]] || return 1
  (( ${#command_words} == 1 ))
}

_prompt_zircon_preexec() {
  if _prompt_zircon_is_clear_command "${1}"; then
    _prompt_zircon_suppress_execution_info=1
  else
    _prompt_zircon_suppress_execution_info=0
  fi
}

_prompt_zircon_precmd() {
  if (( _prompt_zircon_suppress_execution_info )); then
    unset execution_start_info execution_duration_info
    _prompt_zircon_suppress_execution_info=0
  fi
}

if (( ! ${+functions[_prompt_zircon_keymap_select]} )); then
  functions[_prompt_zircon_keymap_select]=${widgets[zle-keymap-select]#user:}'
zle reset-prompt
zle -R'
  zle -N zle-keymap-select _prompt_zircon_keymap_select
fi

if (( ! ${+STATUS_COLOR} )) typeset -g STATUS_COLOR=black
if (( ! ${+PWD_COLOR} )) typeset -g PWD_COLOR=blue
if (( ! ${+ERR_COLOR} )) typeset -g ERR_COLOR=red
if (( ! ${+CLEAN_COLOR} )) typeset -g CLEAN_COLOR=green
if (( ! ${+DIRTY_COLOR} )) typeset -g DIRTY_COLOR=yellow
typeset -g _prompt_zircon_suppress_execution_info=0

setopt nopromptbang prompt{cr,percent,sp,subst}

zstyle ':zim:execution-info' duration-threshold 0
zstyle ':zim:execution-info' start-format 'Executed at %Y-%m-%d %H:%M:%S'
zstyle ':zim:execution-info' duration-format ', took %d'

autoload -Uz add-zsh-hook
add-zsh-hook preexec _prompt_zircon_preexec
add-zsh-hook preexec execution-info-preexec
add-zsh-hook precmd execution-info-precmd
add-zsh-hook precmd _prompt_zircon_precmd

typeset -gA git_info
if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info' verbose yes
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '➦ %c'
  zstyle ':zim:git-info:action' format ' (%s)'
  zstyle ':zim:git-info:indexed' format '✚'
  zstyle ':zim:git-info:unindexed' format '●'
  zstyle ':zim:git-info:clean' format '1'
  zstyle ':zim:git-info:keys' format \
      'ref' '%b%c' \
      'action' '%s' \
      'indexed' '%i' \
      'unindexed' '%I' \
      'clean' '%C'

  autoload -Uz add-zsh-hook && add-zsh-hook precmd git-info
fi

PS1='$(_prompt_zircon_main)'
unset RPS1
