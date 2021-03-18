#!/bin/bash
set -e
# Create a secret with gpg.asci keys

if [ -z "$1" ]; then
  echo "Usage: $0 <GPG KEY>"
  exit 1
fi

KEY=$(gpg --export-secret-keys -a $1 | base64 -w0)

if [ -z "$KEY" ]; then
  echo "Invalid Key: $1"
  exit 1
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: gpg-asc
  namespace: argocd
type: Opaque
data:
  gpg.asc: ${KEY}
EOF
