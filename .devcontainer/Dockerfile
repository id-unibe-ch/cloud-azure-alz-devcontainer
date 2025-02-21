FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root

ENV TERRAFORM_DOCS_VERSION=v0.19.0

RUN mkdir -p /etc/apt/keyrings && apt-get update && apt-get install curl jq apt-transport-https ca-certificates gnupg lsb-release python3-pip -y && rm -rf /var/lib/apt/lists/*

# Add Repositories
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/microsoft.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/microsoft.list > /dev/null

RUN curl -sLS https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null 

RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list 

RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee -a /etc/apt/sources.list.d/trivy.list

# Install tools
RUN apt-get update && apt-get install -y azure-cli gh terraform trivy && rm -rf /var/lib/apt/lists/*

RUN curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/$TERRAFORM_DOCS_VERSION/terraform-docs-$TERRAFORM_DOCS_VERSION-$(uname)-amd64.tar.gz \
    && tar -xzf terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && mv terraform-docs /usr/local/bin/terraform-docs

RUN pip3 install pre-commit checkov

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

RUN /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/sourcemeta/jsonschema/main/install -H "Cache-Control: no-cache, no-store, must-revalidate")"

# Install homebrew
RUN mkdir -p /home/linuxbrew \
  && git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew \
  && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) \
  && chown -R vscode /home/linuxbrew/.linuxbrew

USER vscode

ENV PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
RUN brew config && brew cleanup --prune=all 
