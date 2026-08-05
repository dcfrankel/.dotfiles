#!/usr/bin/env bash
#
# Claude Code statusline renderer.
#
# Reads a single JSON object on stdin (provided by Claude Code) and prints a
# colorized, single-line status summary: working directory, git state, cloud
# context (Terraform / AWS / Kubernetes), context-window usage, session cost,
# session metadata, model name, and the current time.
#
# Requires: jq.

set -o pipefail

# ANSI SGR escape sequences. Using $'...' embeds a literal ESC so segments can
# be concatenated directly instead of interpolated through printf.
readonly C_RESET=$'\033[0m'
readonly C_CYAN=$'\033[36m'        # directory / kubernetes
readonly C_GREEN=$'\033[32m'       # clean git worktree
readonly C_YELLOW=$'\033[33m'      # dirty git / aws / mid context / output style
readonly C_RED=$'\033[31m'         # unpushed commits / high context usage
readonly C_MAGENTA=$'\033[35m'     # terraform / model / low context usage
readonly C_DIM_BLUE=$'\033[2;34m'  # session id
readonly C_WHITE=$'\033[37m'       # current time

# Extract a value from the JSON on stdin, returning "" when absent/null.
# Usage: json_get '<jq filter>'
json_get() {
  printf '%s' "${input}" | jq -r "$1 // empty"
}

# Run git quietly with a timeout, disabling the builtin FS monitor for speed
# and suppressing stderr so missing upstreams/repos degrade gracefully.
git_q() {
  timeout 3 git -c core.useBuiltinFSMonitor=false "$@" 2>/dev/null
}

# Resolve a friendly model name. On Bedrock the model id/display_name is an
# application-inference-profile ARN; reverse-map it via modelOverrides in
# settings.json. Falls back to the raw display name when no mapping applies.
resolve_model_name() {
  local settings_file="${HOME}/.claude/settings.json"
  local model_id model_display model_raw
  model_id=$(json_get '.model.id')
  model_display=$(json_get '.model.display_name')

  # Prefer whichever field actually carries the ARN.
  model_raw="${model_display}"
  case "${model_id}" in
    *application-inference-profile/*) model_raw="${model_id}" ;;
  esac

  local model_name="${model_display}"
  case "${model_raw}" in
    *application-inference-profile/*)
      local profile_id="${model_raw##*/}"
      local key=""
      if [[ -f "${settings_file}" ]]; then
        # Find the modelOverrides key whose value ARN ends in this profile id,
        # skipping "[1m]" long-context aliases; take the first plain match.
        key=$(jq -r --arg pid "${profile_id}" '
          (.modelOverrides // {}) | to_entries
          | map(select((.value | sub(".*/";"")) == $pid) | .key)
          | map(select(test("^claude-[a-z]+-[0-9]") and (contains("[1m]") | not)))
          | first // empty' "${settings_file}")
      fi
      if [[ -n "${key}" ]]; then
        # claude-opus-4-8 -> "Opus 4.8": strip the "claude-" prefix and any
        # trailing date suffix (-20251001), capitalize the family, then join
        # the remaining numeric parts with dots.
        model_name=$(printf '%s' "${key}" \
          | sed -E 's/^claude-//; s/-[0-9]{6,}$//' \
          | awk -F- '{
              fam=toupper(substr($1,1,1)) substr($1,2);
              ver=""; for (i=2; i<=NF; i++) { ver = ver (i==2?"":".") $i }
              printf "%s%s", fam, (ver!=""?" "ver:"")
            }')
      fi
      ;;
  esac

  printf '%s' "${model_name}"
}

# Git segment: "<branch> <shorthash>" with a trailing "*" when dirty, plus an
# unpushed-commit count. Green when clean, yellow when dirty; count in red.
git_segment() {
  git_q rev-parse --is-inside-work-tree >/dev/null || return 0

  local branch short_hash ref
  branch=$(git_q symbolic-ref --short HEAD || git_q rev-parse --short HEAD)
  [[ -z "${branch}" ]] && return 0

  # Combine branch with short hash, avoiding duplication in detached-HEAD state.
  short_hash=$(git_q rev-parse --short HEAD)
  ref="${branch}"
  [[ -n "${short_hash}" && "${short_hash}" != "${branch}" ]] && ref="${branch} ${short_hash}"

  local out
  if ! git_q diff --quiet || ! git_q diff --cached --quiet; then
    out=" ${C_YELLOW} ${ref} *${C_RESET}"
  else
    out=" ${C_GREEN} ${ref}${C_RESET}"
  fi

  # Append unpushed commit count when an upstream exists and is behind.
  local upstream unpushed
  upstream=$(git_q rev-parse --abbrev-ref '@{u}')
  if [[ -n "${upstream}" ]]; then
    unpushed=$(git_q log '@{u}..' --oneline | wc -l | tr -d ' ')
    [[ "${unpushed}" -gt 0 ]] && out+=" ${C_RED}↑ ${unpushed}${C_RESET}"
  fi

  printf '%s' "${out}"
}

# Terraform workspace segment (magenta), shown only in a Terraform project and
# when the workspace is not the implicit "default".
tf_segment() {
  local cwd="$1"
  [[ -n "${cwd}" ]] || return 0
  [[ -d "${cwd}/.terraform" || -f "${cwd}/.terraform.lock.hcl" ]] || return 0
  command -v terraform >/dev/null 2>&1 || return 0

  local ws
  ws=$(cd "${cwd}" && timeout 2 terraform workspace show 2>/dev/null)
  [[ -n "${ws}" && "${ws}" != "default" ]] && printf '  %s[tf:%s]%s' "${C_MAGENTA}" "${ws}" "${C_RESET}"
}

# Kubernetes context segment (cyan).
k8s_segment() {
  command -v kubectl >/dev/null 2>&1 || return 0
  local ctx
  ctx=$(timeout 2 kubectl config current-context 2>/dev/null)
  [[ -n "${ctx}" ]] && printf '  %s[k8s:%s]%s' "${C_CYAN}" "${ctx}" "${C_RESET}"
}

# Context-window usage bar: a 10-cell bar plus percentage. Magenta < 60%,
# yellow 60-79%, red >= 80%.
context_bar() {
  local used="$1"
  [[ -n "${used}" ]] || return 0

  local bar_width=10 filled empty bar="" i
  # Ceiling division of used% over the bar width, clamped to the width.
  filled=$(( (used * bar_width + 99) / 100 ))
  [[ "${filled}" -gt "${bar_width}" ]] && filled=${bar_width}
  empty=$(( bar_width - filled ))
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done

  local color
  if [[ "${used}" -ge 80 ]]; then
    color="${C_RED}"
  elif [[ "${used}" -ge 60 ]]; then
    color="${C_YELLOW}"
  else
    color="${C_MAGENTA}"
  fi
  printf '  %s%s %s%%%s' "${color}" "${bar}" "${used}" "${C_RESET}"
}

main() {
  # Read the JSON payload once into a global consumed by json_get.
  input=$(cat)

  local status_line

  # Directory (home shortened to ~) - cyan.
  local cwd display_dir
  cwd=$(json_get '.workspace.current_dir')
  display_dir="${cwd/#$HOME/~}"
  status_line="${C_CYAN}${display_dir}${C_RESET}"

  # Git branch/hash/dirty + unpushed count.
  status_line+=$(git_segment)

  # Terraform workspace - magenta.
  status_line+=$(tf_segment "${cwd}")

  # AWS profile (from the environment) - yellow.
  local aws_profile="${AWS_PROFILE:-}"
  [[ -n "${aws_profile}" ]] && status_line+="  ${C_YELLOW}[aws:${aws_profile}]${C_RESET}"

  # Kubernetes context - cyan.
  status_line+=$(k8s_segment)

  # Context-window usage bar - magenta/yellow/red.
  local used
  used=$(json_get '.context_window.used_percentage')
  status_line+=$(context_bar "${used}")

  # Session cost in dollars (cumulative) - cyan.
  local total_cost cost
  total_cost=$(json_get '.cost.total_cost_usd')
  if [[ -n "${total_cost}" ]]; then
    cost=$(awk "BEGIN { printf \"%.4f\", ${total_cost} }")
    status_line+="  ${C_CYAN}\$${cost}${C_RESET}"
  fi

  # Model name - magenta.
  local model_name
  model_name=$(resolve_model_name)
  [[ -n "${model_name}" ]] && status_line+="  ${C_MAGENTA}[${model_name}]${C_RESET}"

  # Session id (short prefix) - dim blue.
  local session_id
  session_id=$(json_get '.session_id')
  [[ -n "${session_id}" ]] && status_line+="  ${C_DIM_BLUE}[${session_id:0:8}]${C_RESET}"

  # Output style, when not the default - yellow.
  local output_style
  output_style=$(json_get '.output_style.name')
  [[ -n "${output_style}" && "${output_style}" != "default" ]] && status_line+="  ${C_YELLOW}${output_style}${C_RESET}"

  # Current time (HH:MM:SS) - white.
  status_line+="  ${C_WHITE}$(date +%H:%M:%S)${C_RESET}"

  echo "${status_line}"
}

# Statusline command: requires jq.
if ! command -v jq >/dev/null 2>&1; then
  echo "statusline: jq not installed"
  exit 0
fi

main "$@"
