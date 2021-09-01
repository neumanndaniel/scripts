#!/bin/bash

INSTANCE_NAME="podman"

podman system connection remove $INSTANCE_NAME
multipass stop $INSTANCE_NAME
multipass delete $INSTANCE_NAME
multipass purge