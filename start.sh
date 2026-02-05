#!/usr/bin/env bash
set -e

if [ -z "$TAILSCALE_AUTHKEY" ]; then
  echo "Missing TAILSCALE_AUTHKEY env var"
  exit 1
fi

# Start tailscaled (userspace mode, no /dev/net/tun needed)
tailscaled --state=/tmp/tailscale.state --socket=/tmp/tailscale.sock &
sleep 2

# Bring up Tailscale
tailscale --socket=/tmp/tailscale.sock up \
  --authkey="$TAILSCALE_AUTHKEY" \
  --hostname="render-whatsapp-webhook" \
  --tun=userspace-networking

# Start your node server
node server.js
