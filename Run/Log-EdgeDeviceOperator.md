# Project Log edge-device-operator
## Jan 21, 2026
1. Installing Kubectl
```shell
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null <<'EOF'
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.28/deb/ /
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/v1.28/deb/ /
EOF

sudo apt update && sudo apt install kubectl -y
```
**Verification**:
```
ubuntu@VM-8-15-ubuntu:~/hsimwong.github.io/scripts$ kubectl version
Client Version: v1.28.15
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

2. No need, verification:`ubuntu@VM-8-15-ubuntu:~/hsimwong.github.io/scripts$ go version
go version go1.24.2 linux/amd64`

