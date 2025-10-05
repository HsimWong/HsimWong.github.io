# Environment Preparation

## Experiment Environment
1. Chinese network behind the wall (having VPN, but not accessible via linux)
2. Linux 2004, CPU Intel i5-10210
3. Virtual machines: KVM+libvirt


## Get Environment Ready: Setup VM and Docker
### Usual problems when setting up VM
1. Some instances always rebooted with down interface that makes the instance unaccessble via ssh. There are two workarounds: 1) enable `systemd-networkd` so that the dhcp can be activated automatically; 2) write a netplan under `/etc/netplan`. I tried both and they worked.

2. When the vm space is not sufficient, this is what is needed:
```shell
# Execute this line first on the host
qemu-img resize -f raw debian.img +10GB 
# Then execute these codes inside VM
yum install -y cloud-utils*
growpart /dev/vda 1  # (This expands partition 1 on /dev/vda)
pvresize /dev/vda1
```
3. Setup Docker on VM
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

4. Install Kubernetes
Debian / Ubuntu 用户
首先导入 gpg key：

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
新建 /etc/apt/sources.list.d/kubernetes.list，内容为
```
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.28/deb/ /
# deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/v1.28/deb/ /
```
