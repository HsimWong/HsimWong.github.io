#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: run as root (e.g. sudo ./install-docker-cn.sh)"
  exit 1
fi

echo "[1/5] Remove old/conflicting packages (ignore if not installed)..."
# NOTE: Use a fixed package list; your dpkg command form is incorrect.
pkgs=(
  docker.io docker-doc docker-compose podman-docker
  containerd runc
  docker-ce docker-ce-cli containerd.io
  docker-buildx-plugin docker-compose-plugin
)
apt-get remove -y "${pkgs[@]}" >/dev/null 2>&1 || true
apt-get autoremove -y >/dev/null 2>&1 || true

echo "[2/5] Install prerequisites..."
apt-get update -y
apt-get install -y ca-certificates curl

echo "[3/5] Add Docker GPG key + apt repo (TUNA mirror)..."
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu
Suites: ${codename}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "[4/5] Install Docker Engine + plugins..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[5/5] Enable and verify..."
systemctl enable --now docker

docker --version
docker compose version || true

echo "Docker installation completed."
echo "Optional: add your user to docker group to avoid sudo:"
echo "  sudo usermod -aG docker $SUDO_USER && newgrp docker"

sudo tee /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

USER=$(whoami)
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER
newgrp docker
