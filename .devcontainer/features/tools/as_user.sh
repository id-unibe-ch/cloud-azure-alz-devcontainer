#!/usr/bin/env bash

set -xe

BREW_PREFIX="/home/linuxbrew/.linuxbrew"

${BREW_PREFIX}/bin/brew config
${BREW_PREFIX}/bin/brew install terraform-docs \
  trivy \
  checkov \
  pre-commit \
  hashicorp/tap/terraform-ls

${BREW_PREFIX}/bin/brew untap homebrew/core
