#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Checking Go installation..."
if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: Go is not installed. Install Go first."
  exit 1
fi

echo "[2/5] Installing kind via Go (GFW workaround)..."
# GOPROXY is critical in mainland China
export GOPROXY=https://goproxy.cn,direct
go install sigs.k8s.io/kind@latest

KIND_BIN="$HOME/go/bin/kind"

if [ ! -x "$KIND_BIN" ]; then
  echo "ERROR: kind binary not found at $KIND_BIN"
  exit 1
fi

echo "[3/5] Ensuring Go bin directory is in PATH..."
BASHRC="$HOME/.bashrc"
GO_BIN_LINE='export PATH=$PATH:$HOME/go/bin'

if ! grep -Fxq "$GO_BIN_LINE" "$BASHRC"; then
  echo "$GO_BIN_LINE" >> "$BASHRC"
  echo "Added PATH export to ~/.bashrc"
else
  echo "PATH export already present in ~/.bashrc"
fi

echo "[4/5] Activating environment..."
# shellcheck disable=SC1090
source "$BASHRC"

echo "[5/5] Validating kind installation..."
kind --version

echo "kind installation completed successfully."
