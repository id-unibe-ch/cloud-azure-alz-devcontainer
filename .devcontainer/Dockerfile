FROM mcr.microsoft.com/devcontainers/base:ubuntu AS intermediate

USER root
RUN mkdir -p /etc/apt/keyrings && apt-get update && apt-get install curl jq apt-transport-https ca-certificates gnupg lsb-release python3-pip -y && rm -rf /var/lib/apt/lists/*

FROM intermediate AS azure-build

RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/microsoft.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/microsoft.list > /dev/null
RUN apt-get update && apt-get install -y azure-cli && rm -rf /var/lib/apt/lists/*

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
    && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee -a /etc/apt/sources.list.d/trivy.list
RUN apt-get update && apt-get install -y trivy && rm -rf /var/lib/apt/lists/*

FROM intermediate AS tflint-build

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

FROM intermediate AS jsonschema-build

RUN /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/sourcemeta/jsonschema/main/install -H "Cache-Control: no-cache, no-store, must-revalidate")"

FROM intermediate AS alzlibtool-build

ENV GO_VERSION=1.24.1
RUN curl -sSLo ./go${GO_VERSION}.linux-amd64.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && mv go /usr/local \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

RUN /usr/local/go/bin/go install github.com/Azure/alzlib/cmd/alzlibtool@latest

FROM intermediate

COPY --from=azure-build /usr/bin/az /usr/bin/az 
COPY --from=gh-build /usr/bin/gh /usr/bin/gh
COPY --from=terraform-build /usr/bin/terraform /usr/bin/terraform
COPY --from=terraform-build /usr/bin/terraform-ls /usr/bin/terraform-ls
COPY --from=trivy-build /usr/bin/trivy /usr/bin/trivy
COPY --from=quay.io/terraform-docs/terraform-docs:latest /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY --from=tflint-build /usr/local/bin/tflint /usr/local/bin/tflint
COPY --from=jsonschema-build /usr/local/bin/jsonschema /usr/local/bin/jsonschema
COPY --from=alzlibtool-build /root/go/bin/alzlibtool /usr/local/bin/alzlibtool

RUN pip3 install --no-cache-dir pre-commit checkov

# Install homebrew
RUN mkdir -p /home/linuxbrew \
  && git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew \
  && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) \
  && chown -R vscode /home/linuxbrew/.linuxbrew

USER vscode

ENV PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
RUN brew config && brew cleanup --prune=all 
