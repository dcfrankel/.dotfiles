#!/usr/bin/env zsh
## A sane set of default overrides and customizations for the kubectl CLI

# Add shared commands defaults to the list
if [[ -z "${SHARED_KUBECTL_CLI_SUFFIX+x}" ]]; then
  SHARED_KUBECTL_CLI_SUFFIX=(--all-namespaces -o=wide)
  readonly SHARED_KUBECTL_CLI_SUFFIX
fi

# List pods with specific label
function k_get_pod_labels() {
  local labels=$1
  kubectl get pods -l "$labels" "${SHARED_KUBECTL_CLI_SUFFIX[@]}"
}

# List pods with a given name
function k_get_pods() {
  # Makes sure to keeper table header in output
  local table_header="NAME"
  local pod_name=$1
  kubectl get pods "${SHARED_KUBECTL_CLI_SUFFIX[@]}" | grep --color=never -e "$table_header" -e "$pod_name"
}

# Get an objects fields
function k_object_fields() {
  kubectl explain "$1" --recursive=true
}
