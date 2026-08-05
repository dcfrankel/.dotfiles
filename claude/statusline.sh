#!/usr/bin/env bash

# Statusline command: requires jq
if ! command -v jq >/dev/null 2>&1; then
  echo "statusline: jq not installed"
  exit 0
fi

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON (use // empty consistently)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
session_name=$(printf '%s' "$input" | jq -r '.session_name // empty')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty')
output_style=$(printf '%s' "$input" | jq -r '.output_style.name // empty')
remaining=$(printf '%s' "$input" | jq -r '.context_window.remaining_percentage // empty')

# Resolve a friendly model name. On Bedrock the model id/display_name is an
# application-inference-profile ARN; reverse-map it via modelOverrides in settings.json.
settings_file="$HOME/.claude/settings.json"
model_id=$(printf '%s' "$input" | jq -r '.model.id // empty')
model_display=$(printf '%s' "$input" | jq -r '.model.display_name // empty')

# Pick whichever field carries the ARN (if any)
model_raw="$model_display"
case "$model_id" in *application-inference-profile/*) model_raw="$model_id";; esac

model_name="$model_display"
case "$model_raw" in
    *application-inference-profile/*)
        profile_id="${model_raw##*/}"
        key=""
        if [ -f "$settings_file" ]; then
            key=$(jq -r --arg pid "$profile_id" '
                (.modelOverrides // {}) | to_entries
                | map(select((.value | sub(".*/";"")) == $pid) | .key)
                | map(select(test("^claude-[a-z]+-[0-9]") and (contains("[1m]") | not)))
                | first // empty' "$settings_file")
        fi
        if [ -n "$key" ]; then
            # claude-opus-4-8 -> Opus 4.8 ; strip trailing date suffix like -20251001
            model_name=$(printf '%s' "$key" \
                | sed -E 's/^claude-//; s/-[0-9]{6,}$//' \
                | awk -F- '{
                    fam=toupper(substr($1,1,1)) substr($1,2);
                    ver=""; for(i=2;i<=NF;i++){ ver = ver (i==2?"":".") $i }
                    printf "%s%s", fam, (ver!=""?" "ver:"")
                  }')
        fi
        ;;
esac

# Get current time - HH:MM:SS format
current_time=$(date +%H:%M:%S)

# Get AWS profile from environment
aws_profile="${AWS_PROFILE:-}"

# Get Terraform workspace (if in terraform project)
tf_workspace=""
if [ -n "$cwd" ] && { [ -d "$cwd/.terraform" ] || [ -f "$cwd/.terraform.lock.hcl" ]; }; then
    if command -v terraform >/dev/null 2>&1; then
        tf_workspace=$(cd "$cwd" && timeout 2 terraform workspace show 2>/dev/null)
    fi
fi

# Get git status (skip optional locks for performance, timeout to prevent UI hangs)
git_info=""
git_color=""
unpushed_count=""
if timeout 3 git -c core.useBuiltinFSMonitor=false rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(timeout 3 git -c core.useBuiltinFSMonitor=false symbolic-ref --short HEAD 2>/dev/null || timeout 3 git -c core.useBuiltinFSMonitor=false rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Combine branch with short hash (avoid duplication in detached-HEAD state)
        short_hash=$(timeout 3 git -c core.useBuiltinFSMonitor=false rev-parse --short HEAD 2>/dev/null)
        ref="$branch"
        [ -n "$short_hash" ] && [ "$short_hash" != "$branch" ] && ref="$branch $short_hash"

        # Check for uncommitted changes
        if ! timeout 3 git -c core.useBuiltinFSMonitor=false diff --quiet 2>/dev/null || ! timeout 3 git -c core.useBuiltinFSMonitor=false diff --cached --quiet 2>/dev/null; then
            git_info=" $ref *"
            git_color="\033[33m"  # Yellow for dirty
        else
            git_info=" $ref"
            git_color="\033[32m"  # Green for clean
        fi

        # Get unpushed commit count
        upstream=$(timeout 3 git -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref @{u} 2>/dev/null)
        if [ -n "$upstream" ]; then
            unpushed=$(timeout 3 git -c core.useBuiltinFSMonitor=false log @{u}.. --oneline 2>/dev/null | wc -l | tr -d ' ')
            if [ "$unpushed" -gt 0 ]; then
                unpushed_count=" $unpushed"
            fi
        fi
    fi
fi

# Build the status line with colors
# Directory (shortened home path) - Cyan
display_dir="${cwd/#$HOME/~}"
status_line=$(printf "\033[36m%s\033[0m" "$display_dir")

# Git info - Green (clean) or Yellow (dirty)
if [ -n "$git_info" ]; then
    status_line+=$(printf " ${git_color}%s\033[0m" "$git_info")
fi

# Unpushed commits - Red
if [ -n "$unpushed_count" ]; then
    status_line+=$(printf " \033[31m↑%s\033[0m" "$unpushed_count")
fi

# Terraform workspace - Magenta
if [ -n "$tf_workspace" ] && [ "$tf_workspace" != "default" ]; then
    status_line+=$(printf "  \033[35m[tf:%s]\033[0m" "$tf_workspace")
fi

# AWS Profile - Yellow
if [ -n "$aws_profile" ]; then
    status_line+=$(printf "  \033[33m[aws:%s]\033[0m" "$aws_profile")
fi

# Kubernetes context - Cyan
k8s_context=""
if command -v kubectl >/dev/null 2>&1; then
    k8s_context=$(timeout 2 kubectl config current-context 2>/dev/null)
fi
if [ -n "$k8s_context" ]; then
    status_line+=$(printf "  \033[36m[k8s:%s]\033[0m" "$k8s_context")
fi

# Context usage progress bar - Magenta/Red
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
    bar_width=10
    filled=$(( (used * bar_width + 99) / 100 ))
    [ "$filled" -gt "$bar_width" ] && filled=$bar_width
    empty=$(( bar_width - filled ))
    bar=""
    for i in $(seq 1 "$filled"); do bar="${bar}█"; done
    for i in $(seq 1 "$empty"); do bar="${bar}░"; done
    if [ "$used" -ge 80 ]; then
        bar_color="\033[31m"   # Red when >= 80% used
    elif [ "$used" -ge 60 ]; then
        bar_color="\033[33m"   # Yellow when >= 60% used
    else
        bar_color="\033[35m"   # Magenta otherwise
    fi
    status_line+=$(printf "  ${bar_color}%s %s%%\033[0m" "$bar" "$used")
fi

# Session cost in dollars (cumulative, provided by Claude Code) - Cyan
total_cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$total_cost" ]; then
    cost=$(awk "BEGIN { printf \"%.4f\", $total_cost }")
    status_line+=$(printf "  \033[36m\$%s\033[0m" "$cost")
fi

# Session name (if set) - Blue
if [ -n "$session_name" ]; then
    status_line+=$(printf "  \033[34m%s\033[0m" "$session_name")
fi

# Model name - Magenta
if [ -n "$model_name" ]; then
    status_line+=$(printf "  \033[35m[%s]\033[0m" "$model_name")
fi

# Session ID (short prefix) - Dim blue
if [ -n "$session_id" ]; then
    short_id="${session_id:0:8}"
    status_line+=$(printf "  \033[2;34m[%s]\033[0m" "$short_id")
fi

# Output style (if not default) - Yellow
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    status_line+=$(printf "  \033[33m%s\033[0m" "$output_style")
fi

# Current time - White/Gray
status_line+=$(printf "  \033[37m%s\033[0m" "$current_time")

# Print the status line
echo "$status_line"