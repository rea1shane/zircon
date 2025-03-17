# vim:et sts=2 sw=2 ft=zsh

_prompt_zircon_main() {
  # This runs in a subshell
  RETVAL=${?}
  BG_COLOR=

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
  if [[ -n ${BG_COLOR} ]] print -n "%F{${BG_COLOR}}"
  print -n ${2}
  BG_COLOR=${1}
}

_prompt_zircon_standout_segment() {
  print -n "%S%F{${1}}"
  if [[ -n ${BG_COLOR} ]] print -n "%K{${BG_COLOR}}%k"
  print -n "${2}%s"
  BG_COLOR=${1}
}

# End the prompt, closing last segment.
_prompt_zircon_end() {
  print -n "%k%F{${BG_COLOR}}%f "
}

### Prompt components
# Each component will draw itself, or hide itself if no information needs to
# be shown.

# Execution: start/stop time and duration of the last command.
_prompt_zircon_execution() {
  local segment=
  if [[ -n ${execution_start_info} ]] segment+=${execution_start_info}
  if [[ -n ${execution_duration_info} ]] segment+=${execution_duration_info}
  if [[ -n ${execution_start_info} ]]; then
    if (( RETVAL )) segment+=", returned ${RETVAL}"
  fi
  if [[ -n ${segment} ]]; then
    segment="--------
${segment}.
"
    print -n "%F{white}${segment}%f"
  fi
}

# Status: Was there an error? Am I root? Are there background jobs? Ranger
# spawned shell? Python venv activated? Who and where am I (user@hostname)?
_prompt_zircon_status() {
  local segment=
  if (( EUID == 0 )) segment+=' %F{yellow}⚡'
  if (( ${#jobstates} )) segment+=' %F{cyan}⚙'
  if [[ -n ${VIRTUAL_ENV} ]] segment+=" %F{cyan}${VIRTUAL_ENV:t}"
  if [[ -n ${SSH_TTY} ]] segment+=" %F{%(!.yellow.default)}%n@%m"
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
    if [[ -n ${(e)git_info[dirty]} ]]; then
      git_color=${DIRTY_COLOR}
    else
      git_color=${CLEAN_COLOR}
    fi
    _prompt_zircon_standout_segment ${git_color} ' '${(e)git_info[prompt]}' '
  fi
}

if (( ! ${+STATUS_COLOR} )) typeset -g STATUS_COLOR=black
if (( ! ${+PWD_COLOR} )) typeset -g PWD_COLOR=blue
if (( ! ${+ERR_COLOR} )) typeset -g ERR_COLOR=red
if (( ! ${+CLEAN_COLOR} )) typeset -g CLEAN_COLOR=green
if (( ! ${+DIRTY_COLOR} )) typeset -g DIRTY_COLOR=yellow
typeset -g VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

# Execution
zstyle ':zim:execution-info' duration-threshold 0
zstyle ':zim:execution-info' start-format       'Executed at %Y-%m-%d %H:%M:%S'
zstyle ':zim:execution-info' duration-format    ', took %d'

autoload -Uz add-zsh-hook
add-zsh-hook preexec execution-info-preexec
add-zsh-hook precmd  execution-info-precmd

# Git
typeset -gA git_info
if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info:branch' format ' %b'
  zstyle ':zim:git-info:commit' format '➦ %c'
  zstyle ':zim:git-info:action' format ' (%s)'
  zstyle ':zim:git-info:dirty' format ' ●'
  zstyle ':zim:git-info:keys' format \
      'prompt' '%b%c%s%D' \
      'dirty' '%D'

  autoload -Uz add-zsh-hook && add-zsh-hook precmd git-info
fi

PS1='$(_prompt_zircon_main)'
unset RPS1
