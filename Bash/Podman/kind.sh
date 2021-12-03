#!/bin/bash

brew install gsed

# Podman IP configuration
INSTANCE_NAME="podman"

IP=$(multipass info $INSTANCE_NAME | grep IPv4: | cut -d ':' -f2 | tr -ds ' ' '')

IP_CONFIG_EXISTS=$(cat /private/etc/hosts | grep -c "$IP")
if [[ $IP_CONFIG_EXISTS -eq 0 ]]; then
  echo "$IP $INSTANCE_NAME" | sudo tee -a /private/etc/hosts
fi

# Create KinD cluster
wget https://raw.githubusercontent.com/neumanndaniel/kubernetes/master/kind/single-node.yaml -O /tmp/single-node.yaml
gsed -i 's/127.0.0.1/'$IP'/g' /tmp/single-node.yaml
kind create cluster --config=/tmp/single-node.yaml

# Calico
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl apply -f https://raw.githubusercontent.com/neumanndaniel/kubernetes/master/kind/calico-config.yaml

sleep 120

# Metrics Server
kubectl config set-context --current --namespace kube-system

helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update
helm upgrade metrics-server --install \
  --set apiService.create=true \
  --set extraArgs.kubelet-insecure-tls=true \
  --set extraArgs.kubelet-preferred-address-types=InternalIP \
  bitnami/metrics-server --namespace kube-system