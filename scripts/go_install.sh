#!/usr/bin/env bash
set -e

GO_MIRROR="https://golang.google.cn/dl"
INSTALL_DIR="/usr/local"
PROFILE_FILE="/etc/profile.d/go.sh"

echo "[1/6] Detecting architecture..."

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported arch: $ARCH"
    exit 1
    ;;
esac

echo "Architecture: $ARCH"

echo "[2/6] Fetching latest Go version..."
VERSION=$(curl -fsSL https://golang.google.cn/VERSION?m=text | head -n 1)

if [[ -z "$VERSION" ]]; then
  echo "Failed to get Go version"
  exit 1
fi

TARBALL="${VERSION}.linux-${ARCH}.tar.gz"
echo "Latest version: $VERSION"

echo "[3/6] Downloading Go..."
curl -fLO "${GO_MIRROR}/${TARBALL}"

echo "[4/6] Installing..."
rm -rf ${INSTALL_DIR}/go
tar -C ${INSTALL_DIR} -xzf ${TARBALL}

echo "[5/6] Setting PATH..."
cat > ${PROFILE_FILE} <<EOF
export GOROOT=${INSTALL_DIR}/go
export GOPATH=\$HOME/go
export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH
EOF

chmod +x ${PROFILE_FILE}

echo "[6/6] Cleanup..."
rm -f ${TARBALL}

echo
echo "Go installed successfully."
echo "Run:"
echo "  source ${PROFILE_FILE}"
echo "  go version"


cat <<'EOF' >> ~/.bashrc

# ===== Go environment =====
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=sum.golang.google.cn
export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH
# =========================
EOF

source ~/.bashrc