#!/bin/bash

PODMAN_MODE=$1

# Install podman client & multipass
brew install podman multipass

# Symlink as otherwise `az acr login` does not work.
ln -s /usr/local/bin/podman /usr/local/bin/docker || true

# Podman setup
SSH_PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
echo '
ssh_authorized_keys:
  - '${SSH_PUB_KEY}'' >> user-data

./create.sh $PODMAN_MODE