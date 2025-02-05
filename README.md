# cloud-azure-alz-devcontainer

This repository containts the default devcontainer definition.

## Overview

The image is based on the base image `mcr.microsoft.com/devcontainers/base:ubuntu` and contains following additional tools:

- Azure CLI
- GitHub CLI
- Terraform
- tflint
- Homebrew
- terraform-docs (by Homebrew)
- pre-commit (by Homebrew)
- checkov (by Homebrew)
- trivy (by Homebrew)

## Usage

Add to a project a file under `.devcontainer/devcontainer.json` with following content:

```json
{
  "image": "ghcr.io/id-unibe-ch/cloud-azure-alz-devcontainer:latest"
}
```
