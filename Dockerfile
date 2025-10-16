FROM mcr.microsoft.com/devcontainers/base:ubuntu AS intermediate

USER root

RUN mkdir -p /etc/apt/keyrings \
    && apt-get update \
    && apt-get install curl jq apt-transport-https ca-certificates gnupg lsb-release python3-pip pipx software-properties-common -y \
    && rm -rf /var/lib/apt/lists/* 

FROM intermediate AS azure-build

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

FROM intermediate AS gh-build

RUN curl -sLS https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null 
RUN apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

FROM intermediate AS terraform-build

RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list 
RUN apt-get update && apt-get install -y terraform terraform-ls && rm -rf /var/lib/apt/lists/*

FROM intermediate AS trivy-build

RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee -a /etc/apt/sources.list.d/trivy.list
RUN apt-get update && apt-get install -y trivy && rm -rf /var/lib/apt/lists/*

FROM intermediate AS tflint-build

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

FROM --platform=$BUILDPLATFORM intermediate AS alzlibtool-build

ARG TARGETARCH
ENV GO_VERSION=1.24.1
RUN curl -sSLo ./go${GO_VERSION}.linux-${TARGETARCH}.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && tar -xzf go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && mv go /usr/local \
    && rm go${GO_VERSION}.linux-${TARGETARCH}.tar.gz

RUN /usr/local/go/bin/go install github.com/Azure/alzlib/cmd/alzlibtool@latest

FROM --platform=$BUILDPLATFORM intermediate AS pwsh-build

ARG TARGETARCH
ENV PWSH_VERSION=7.5.3
RUN PWSHARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x64/) \
    && curl -sSLo ./powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-${PWSHARCH}.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar -xzf powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && rm powershell.tar.gz

FROM intermediate

COPY --from=azure-build /usr/bin/az /usr/bin/az 
COPY --from=azure-build /opt/az /opt/az
COPY --from=gh-build /usr/bin/gh /usr/bin/gh
COPY --from=terraform-build /usr/bin/terraform /usr/bin/terraform
COPY --from=terraform-build /usr/bin/terraform-ls /usr/bin/terraform-ls
COPY --from=trivy-build /usr/bin/trivy /usr/bin/trivy
COPY --from=quay.io/terraform-docs/terraform-docs:latest /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY --from=tflint-build /usr/local/bin/tflint /usr/local/bin/tflint
COPY --from=alzlibtool-build /root/go/bin/alzlibtool /usr/local/bin/alzlibtool
COPY --from=pwsh-build /opt/microsoft/powershell/7 /opt/microsoft/powershell/7

RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
  && az bicep install

# Install homebrew
RUN mkdir -p /home/linuxbrew \
    && git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew \
    && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) \
    && chown -R vscode /home/linuxbrew/.linuxbrew

ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN mkdir -p /opt/pipx \
    && pipx install pre-commit checkov check-jsonschema jsonschema-markdown

USER vscode

ENV PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
RUN brew config && brew cleanup --prune=all 
