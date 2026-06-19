#!/usr/bin/env bash
set -euo pipefail
kubeadm join 192.168.56.20:6443 --token 5fihr9.a1fesy9svdai39cc --discovery-token-ca-cert-hash sha256:85192132a1fe8de27a25e5f3280f4af8dbe4df451591d732dd1a77fc95011d0a 