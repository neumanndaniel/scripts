#!/bin/bash

PODMAN_MODE=$1

INSTANCE_NAME="podman"
multipass set client.primary-name=$INSTANCE_NAME

multipass launch -c 4 -m 8G -d 32G -n $INSTANCE_NAME --cloud-init user-data 20.04
multipass exec $INSTANCE_NAME -- /home/ubuntu/setup-podman.sh

IP=$(multipass info $INSTANCE_NAME | grep IPv4: | cut -d ':' -f2 | tr -ds ' ' '')
if [ "$PODMAN_MODE" == "root" ]; then
  podman system connection add $INSTANCE_NAME --identity ~/.ssh/id_rsa  ssh://root@${IP}/run/podman/podman.sock
else
  podman system connection add $INSTANCE_NAME --identity ~/.ssh/id_rsa  ssh://ubuntu@${IP}/run/user/1000/podman/podman.sock
fi

# List of volume mounts that Docker for Desktop also mounts per default.
multipass mount /Users $INSTANCE_NAME
multipass mount /Volumes $INSTANCE_NAME
multipass mount /private $INSTANCE_NAME
multipass mount /tmp $INSTANCE_NAME
multipass mount /var/folders $INSTANCE_NAME

multipass list
echo "#######################"
podman system connection list