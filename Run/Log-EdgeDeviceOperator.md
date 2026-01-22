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


## Jan 22, 2026
### Installing kind and Create cluster
   1. `kind` has been block by GFW, looking for a workaround with Go:https://kind.sigs.k8s.io/
   2. Run `go install sigs.k8s.io/kind@latest`
   3. Add line at the bottom of `~/.bashrc`: `export PATH=$PATH:/home/ubuntu/go/bin`
   4. Activate kind `source ~/.bashrc`
   5. Validate with `kind --version`:
2. Create local cluster: `kind create cluster`
   It's slow as fuck because of the GFW. I know that I need to bypass with the proxy, or use the image station. I found that USTC offered registry mirror site but no longer now. 
3. ... Described in [Cracking GFW Log](../CrackingGFW/CrackingGFWLog.md)

### Establish Scaffold
1. Kubebuilder init: `kubebuilder init --domain ryan.wang --repo github.com/HsimWong/edge-deploy-controller`
2. 

