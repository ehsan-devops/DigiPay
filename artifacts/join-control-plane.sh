#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <apiserver-advertise-address>"
  exit 1
fi

NODE_IP="$1"

kubeadm join 192.168.56.20:6443 --token 5fihr9.a1fesy9svdai39cc --discovery-token-ca-cert-hash sha256:85192132a1fe8de27a25e5f3280f4af8dbe4df451591d732dd1a77fc95011d0a  --control-plane --certificate-key e34633949fcec64f06cc06bcea72f7b4b0b9733d4d4bb61bb917fe68b7e37a9c --apiserver-advertise-address "${NODE_IP}"
