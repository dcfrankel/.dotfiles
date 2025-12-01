#!/usr/bin/env zsh
## A sane set of default overrides and customizations for the kubectl CLI

# Add shared commands defaults to the list
SHARED_KUBECTL_CLI_SUFFIX=(--all-namespaces)

# List pods with specific label
function k-pod-labels() {
  kubectl get pods -l $1 ${SHARED_KUBECTL_CLI_SUFFIX[@]}
}
