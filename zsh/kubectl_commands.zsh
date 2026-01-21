#!/usr/bin/env zsh
## A sane set of default overrides and customizations for the kubectl CLI

# Add shared commands defaults to the list
SHARED_KUBECTL_CLI_SUFFIX=(--all-namespaces -o=wide)

# List pods with specific label
function k-pod-labels() {
  kubectl get pods -l $1 ${SHARED_KUBECTL_CLI_SUFFIX[@]}
}

# List pods with a given name
function k-find-pods() {
  # Makes sure to keeper table header in output
  TABLE_HEADER="NAME"
  kubectl get pods ${SHARED_KUBECTL_CLI_SUFFIX[@]} | grep --color=never -e "$TABLE_HEADER" -e $1
}

# Get an objects fields
function k-object-fields() {
  kubectl explain $1 --recursive=true
}
