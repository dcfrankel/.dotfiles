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
#
# Coloring is legible by group: every tag's structural literals ("[tag:", "|",
# "]") render in gray, and all information within a group shares one color. No
# two groups share an info color.
readonly C_RESET=$'\033[0m'
readonly C_GRAY=$'\033[90m'           # tag labels / brackets / separators
readonly C_CYAN=$'\033[36m'           # dir
readonly C_GREEN=$'\033[32m'          # git
readonly C_MAGENTA=$'\033[35m'        # terraform
readonly C_YELLOW=$'\033[33m'         # aws
readonly C_BLUE=$'\033[34m'           # kubernetes
readonly C_LIGHT_ORANGE=$'\033[38;5;215m' # claude session (context / cost / model / id)
readonly C_BRIGHT_MAGENTA=$'\033[95m' # output style
readonly C_BRIGHT_WHITE=$'\033[97m'   # time

# Render a "[tag:v1|v2|...]" segment: the "[tag:", "|" separators, and closing
# "]" are gray; each value is wrapped in the group color. Values are taken as
# positional args after the tag and color, so empty fields should be filtered
# out by the caller before invoking. Usage: render_tag <tag> <color> <value>...
render_tag() {
  local tag="$1" color="$2"
  shift 2

  local out="${C_GRAY}[${tag}:${C_RESET}" first=1 value
  for value in "$@"; do
    [[ "${first}" -eq 1 ]] || out+="${C_GRAY}|${C_RESET}"
    out+="${color}${value}${C_RESET}"
    first=0
  done
  out+="${C_GRAY}]${C_RESET}"
  printf '%s' "${out}"
}

# Extract a value from the JSON on stdin, returning "" when absent/null.
# Usage: json_get '<jq filter>'
json_get() {
  printf '%s' "${input}" | jq -r "$1 // empty"
}

# Collapse a path to its last few components so deep paths don't overflow a
# narrow line: paths with more than MAX components keep the trailing MAX and
# gain a leading "…". Any leading "~" or "/" prefix is preserved. Shallow paths
# are returned unchanged. Usage: truncate_path <path>
truncate_path() {
  local path="$1" max=3

  # Detect and strip a leading prefix ("~" or "/") so it isn't counted or lost.
  local prefix=""
  case "${path}" in
    '~'*) prefix="~"; path="${path#\~}" ;;
    /*)   prefix="/" ;;
  esac
  path="${path#/}"

  # Split on "/" into components (empty for a bare prefix like "~" or "/").
  # Use read -ra so a component containing glob chars isn't expanded.
  local -a parts=()
  [[ -n "${path}" ]] && IFS='/' read -ra parts <<< "${path}"
  local count="${#parts[@]}"

  if [[ "${count}" -le "${max}" ]]; then
    # Re-join the prefix to the path with a "/" separator when both are present.
    local sep=""
    [[ -n "${prefix}" && -n "${path}" && "${prefix}" != "/" ]] && sep="/"
    printf '%s%s%s' "${prefix}" "${sep}" "${path}"
    return 0
  fi

  # Join the trailing "max" components back with "/" (IFS's first char).
  local IFS='/'
  local tail="${parts[*]:count-max:max}"
  printf '…/%s' "${tail}"
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

# Git segment: "[git:<branch>|<shorthash>]" with a "*" attached to the hash when
# dirty, plus an optional "|↑N" unpushed-commit field. All values are green; the
# dirty and unpushed states are conveyed structurally (the "*" marker and "↑N"
# field), not by color.
git_segment() {
  git_q rev-parse --is-inside-work-tree >/dev/null || return 0

  local branch short_hash
  branch=$(git_q symbolic-ref --short HEAD || git_q rev-parse --short HEAD)
  [[ -z "${branch}" ]] && return 0
  short_hash=$(git_q rev-parse --short HEAD)

  # Append "*" to the hash field when the worktree is dirty.
  local mark=""
  if ! git_q diff --quiet || ! git_q diff --cached --quiet; then
    mark="*"
  fi

  # Fields: branch first, then hash (skipped when equal to branch in detached
  # HEAD, so a bare hash renders as "[git:<hash>]").
  local fields=()
  if [[ -n "${short_hash}" && "${short_hash}" != "${branch}" ]]; then
    fields=("${branch}" "${short_hash}${mark}")
  else
    fields=("${branch}${mark}")
  fi

  # Append unpushed commit count when an upstream exists and is ahead.
  local upstream unpushed
  upstream=$(git_q rev-parse --abbrev-ref '@{u}')
  if [[ -n "${upstream}" ]]; then
    unpushed=$(git_q log '@{u}..' --oneline | wc -l | tr -d ' ')
    [[ "${unpushed}" -gt 0 ]] && fields+=("↑${unpushed}")
  fi

  printf '  %s' "$(render_tag git "${C_GREEN}" "${fields[@]}")"
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
  [[ -n "${ws}" && "${ws}" != "default" ]] && printf '  %s' "$(render_tag tf "${C_MAGENTA}" "${ws}")"
}

# Kubernetes context segment (blue).
k8s_segment() {
  command -v kubectl >/dev/null 2>&1 || return 0
  local ctx
  ctx=$(timeout 2 kubectl config current-context 2>/dev/null)
  [[ -n "${ctx}" ]] && printf '  %s' "$(render_tag k8s "${C_BLUE}" "${ctx}")"
}

# Context-window usage sub-field: a 10-cell bar plus percentage, e.g.
# "█████░░░░░ 45%". Bar and percent are separated by a space (not "|") so the
# claude segment's top-level "|" delimiter stays unambiguous. Emitted without
# color (the claude group color is applied by the caller); usage level is
# conveyed by the bar fill, not by color. Emits nothing when usage is absent.
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

  printf '%s %s%%' "${bar}" "${used}"
}

main() {
  # Read the JSON payload once into a global consumed by json_get.
  input=$(cat)

  # Line 1 collects environment segments (git + cloud context); line 2 holds the
  # working directory, the Claude session signals, and the time. Splitting keeps
  # each line short enough to avoid being truncated on narrow terminals.
  local line1 line2

  # Resolve the current directory up front; it is rendered on line 2 below.
  local cwd
  cwd=$(json_get '.workspace.current_dir')

  # Git branch/hash/dirty + unpushed count. Seeds line 1; git_segment already
  # emits a leading two-space separator, trimmed later if line 1 stays empty.
  line1=$(git_segment)

  # Terraform workspace - magenta.
  line1+=$(tf_segment "${cwd}")

  # AWS profile (from the environment) - yellow.
  local aws_profile="${AWS_PROFILE:-}"
  [[ -n "${aws_profile}" ]] && line1+="  $(render_tag aws "${C_YELLOW}" "${aws_profile}")"

  # Kubernetes context - blue.
  line1+=$(k8s_segment)

  # Claude session signals consolidated into one "[claude:...]" tag: model,
  # session id, context usage, and cost, joined with "|" and all colored orange.
  # Each sub-field is included only when present, so absent fields are omitted
  # (no empty "||").
  local claude_fields=()

  # Model name.
  local model_name
  model_name=$(resolve_model_name)
  [[ -n "${model_name}" ]] && claude_fields+=("${model_name}")

  # Session id (short prefix).
  local session_id
  session_id=$(json_get '.session_id')
  [[ -n "${session_id}" ]] && claude_fields+=("${session_id:0:8}")

  # Context-window usage bar.
  local used context_field
  used=$(json_get '.context_window.used_percentage')
  context_field=$(context_bar "${used}")
  [[ -n "${context_field}" ]] && claude_fields+=("${context_field}")

  # Session cost in dollars (cumulative).
  local total_cost cost
  total_cost=$(json_get '.cost.total_cost_usd')
  if [[ -n "${total_cost}" ]]; then
    cost=$(awk "BEGIN { printf \"%.4f\", ${total_cost} }")
    claude_fields+=("\$${cost}")
  fi

  # Line 2 segments, appended only when present so absent ones leave no leading
  # separator. The first segment starts the line bare; subsequent ones prepend
  # the usual two-space separator.
  local -a line2_segments=()

  # Directory (home shortened to ~, deep paths collapsed to "…/...") - cyan.
  local display_dir
  display_dir="${cwd/#$HOME/~}"
  display_dir=$(truncate_path "${display_dir}")
  line2_segments+=("$(render_tag dir "${C_CYAN}" "${display_dir}")")

  # Emit the claude segment only when at least one sub-field exists.
  [[ "${#claude_fields[@]}" -gt 0 ]] && \
    line2_segments+=("$(render_tag claude "${C_LIGHT_ORANGE}" "${claude_fields[@]}")")

  # Current time (HH:MM:SS) - bright white.
  line2_segments+=("$(render_tag time "${C_BRIGHT_WHITE}" "$(date +%H:%M:%S)")")

  # Output style, when not the default - bright magenta.
  local output_style
  output_style=$(json_get '.output_style.name')
  [[ -n "${output_style}" && "${output_style}" != "default" ]] && \
    line2_segments+=("$(render_tag style "${C_BRIGHT_MAGENTA}" "${output_style}")")

  local IFS='' # join with an explicit two-space separator below, not IFS
  line2=$(printf '%s' "${line2_segments[0]:-}")
  local i
  for ((i = 1; i < ${#line2_segments[@]}; i++)); do
    line2+="  ${line2_segments[i]}"
  done

  # Trim the leading two-space separator the first line-1 segment carries, then
  # print each line only when it has content (line 1 is empty outside a git repo
  # with no cloud context).
  line1="${line1#  }"
  [[ -n "${line1}" ]] && printf '%s\n' "${line1}"
  [[ -n "${line2}" ]] && printf '%s\n' "${line2}"

  return 0
}

# Statusline command: requires jq.
if ! command -v jq >/dev/null 2>&1; then
  echo "statusline: jq not installed"
  exit 0
fi

main "$@"
