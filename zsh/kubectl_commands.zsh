#!/usr/bin/env zsh
## A sane set of default overrides and customizations for the kubectl CLI

# Add shared commands defaults to the list
SHARED_KUBECTL_CLI_SUFFIX=(--all-namespaces -o=wide)

# List pods with specific label
function k-get-pod-labels() {
  local labels=$1
  kubectl get pods -l "$labels" ${SHARED_KUBECTL_CLI_SUFFIX[@]}
}

# List pods with a given name
function k-get-pods() {
  # Makes sure to keeper table header in output
  local TABLE_HEADER="NAME"
  local pod_name=$1
  kubectl get pods ${SHARED_KUBECTL_CLI_SUFFIX[@]} | grep --color=never -e "$TABLE_HEADER" -e "$pod_name"
}

# Get an objects fields
function k-object-fields() {
  kubectl explain $1 --recursive=true
}
