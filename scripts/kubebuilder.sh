#!/bin/bash
# Install kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo tee >/etc/apt/sources.list.d/kubernetes.list <<EOF
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.28/deb/ /
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/v1.28/deb/ /
EOF

sudo apt-get update
sudo apt-get install -y kubectl


# download kubebuilder and install locally.
wget -O kubebuilder https://ghfast.top/https://github.com/kubernetes-sigs/kubebuilder/releases/download/v4.11.0/kubebuilder_linux_amd64
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/