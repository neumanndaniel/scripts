#!/bin/bash

PODMAN_MODE=$1

INSTANCE_NAME="podman"
IP=$(multipass info $INSTANCE_NAME | grep IPv4: | cut -d ':' -f2 | tr -ds ' ' '')
if [ "$PODMAN_MODE" == "root" ]; then
  podman system connection remove $INSTANCE_NAME
  podman system connection add $INSTANCE_NAME --identity ~/.ssh/id_rsa  ssh://root@${IP}/run/podman/podman.sock
else
  podman system connection remove $INSTANCE_NAME
  podman system connection add $INSTANCE_NAME --identity ~/.ssh/id_rsa  ssh://ubuntu@${IP}/run/user/1000/podman/podman.sock
fi