#!/usr/bin/env bash

set -xe

BREW_PREFIX="/home/linuxbrew/.linuxbrew"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

USERNAME=""
POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
for CURRENT_USER in ${POSSIBLE_USERS[@]}; do
    if id -u ${CURRENT_USER} > /dev/null 2>&1; then
        USERNAME=${CURRENT_USER}
        break
    fi
done
if [ "${USERNAME}" = "" ]; then
    USERNAME=root
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y build-essential procps curl file git

# Install homebrew
mkdir -p "${BREW_PREFIX}"
echo "Installing Homebrew..."
git clone --depth 1 https://github.com/Homebrew/brew "${BREW_PREFIX}/Homebrew"
mkdir -p "${BREW_PREFIX}/Homebrew/Library/Taps/homebrew"
git clone --depth 1 https://github.com/Homebrew/homebrew-core "${BREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core"

mkdir "${BREW_PREFIX}/bin"
ln -s "${BREW_PREFIX}/Homebrew/bin/brew" "${BREW_PREFIX}/bin"
chown -R ${USERNAME} "${BREW_PREFIX}"

ls "${BREW_PREFIX}/bin"
echo "export PATH=${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:\$PATH" >> /etc/bash.bashrc
echo "export PATH=${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:\$PATH" >> /etc/zsh/zshrc

sudo -u $USERNAME bash ./as_user.sh 

# Cleanup
rm -rf /var/lib/apt/lists/*

echo 'Done!'
