FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root

# Install homebrew
RUN mkdir -p /home/linuxbrew \
  && git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew \
  && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) \
  && chown -R vscode /home/linuxbrew/.linuxbrew

USER vscode

ENV PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"

ADD ./Brewfile /tmp/install/Brewfile

RUN brew config && cd /tmp/install && brew bundle -v && brew cleanup --prune=all 
