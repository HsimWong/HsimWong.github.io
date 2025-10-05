# Environment Preparation

Preparing for Kubernetes under Chinese network environment can be surprisingly frustrating however, there are still ways to work around. Confronting with nasty problems can be easy once you engage yourself with the community. Here's how I worked around. 

## Experiment Environment
1. Chinese network behind the wall (having VPN, but not accessible via linux)
2. Linux 2004, CPU Intel i5-10210
3. Virtual machines: KVM+libvirt


## Get Environment Ready: Setup VM and Docker
### Usual problems when setting up VM
#### 1. Instance unaccessible via ssh even after sshd_config is configured
Some instances always rebooted with down interface that makes the instance unaccessble via ssh. There are two workarounds: 1) enable `systemd-networkd` so that the dhcp can be activated automatically; 2) write a netplan under `/etc/netplan`. I tried both and they worked.

#### 2. VM insufficient space
When the vm space is not sufficient, this is what is needed:
```shell
# Execute this line first on the host
qemu-img resize -f raw debian.img +10GB 
# Then execute these codes inside VM
yum install -y cloud-utils*
growpart /dev/vda 1  # (This expands partition 1 on /dev/vda)
pvresize /dev/vda1
```
#### 3. Setup Docker on VM
```shell
echo "Installing docker and its components\n"
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
archi=`dpkg --print-architecture`
sudo add-apt-repository \
   "deb [arch=$archi] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt install -y docker-ce

```
Installing docker with the steps is one step away from completion: change `exec-option` to `systemd`

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF
```
Then restart the service

#### 4. Install Kubernetes
For Debian / Ubuntu users, gpg key needs to be induced first
``````
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
``````
Then touch file `/etc/apt/sources.list.d/kubernetes.list`, with content as follow:
```
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.28/deb/ /
# deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/v1.28/deb/ /
```
Install `kubectl, kubeadm, kubelet` with `apt install kubeadm`





