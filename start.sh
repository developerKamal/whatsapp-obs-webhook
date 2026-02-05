#!/usr/bin/env bash
set -e

if [ -z "$TAILSCALE_AUTHKEY" ]; then
  echo "Missing TAILSCALE_AUTHKEY env var"
  exit 1
fi

# Start tailscaled in userspace mode (no /dev/net/tun needed)
tailscaled \
  --tun=userspace-networking \
  --state=/tmp/tailscale.state \
  --socket=/tmp/tailscale.sock \
  &

# Give it a moment
sleep 2

# Bring the network up without trying to touch iptables
tailscale --socket=/tmp/tailscale.sock up \
  --auth-key="$TAILSCALE_AUTHKEY" \
  --hostname="render-whatsapp-webhook" \
  --netfilter-mode=off \
  --accept-dns=false \
  --reset

# Start your node server
node server.js
