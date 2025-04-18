# Site-to-Site VxLAN Setup
## 简介
VxLAN技术在铁路安全云平台中主要应用在不同地域间实验室组网问题的解决，具有技术透明、组网方便、不受地理限制的特点，是跨实验室组网的关键技术。本文所述步骤利用多网卡计算机模拟实验室网关，使用VxLAN技术进行实验室组网，对不同子网的互通性、隔离性进行实验，验证其可行性。
## VxLAN部署结构
本实验的主要配置如下图所示。多网卡计算机作为网关，其`eth0`通过互联网相连，提供建立vxlan的链路，每个网关节点的其他网卡`eth1`和`eth2`分别接入到其他子网。为简化网络拓扑，每个子网用一台单网卡计算机表示，子网之间相互独立。

![image](https://github.com/user-attachments/assets/e9fe4209-2341-4d78-ba24-5e909239b7f8)

在网关内部，建立起两个VxLAN分别为`vxlan0`和`vxlan1`，再利用软件建立起两个网桥用于vxlan和网卡的桥接，实现与子网的连接。

## 操作步骤
1. **建立VxLAN**： 此脚本在两台网关上运行，其中`opposite_ip`为对方网关的IP，而不是本机网关的IP地址。
```sh
ip link add vxlan0 type vxlan id 40 dstport 4789 remote <opposite_ip> dev eth0
ip addr add 10.88.88.2/24 dev vxlan0
ip link set vxlan0 up
```
2. **建立网桥**：
请保证`bridge-utils`被安装。可使用`apt install bridge-utils`进行安装。对于每个vlan都需要建立对应的网桥
```sh
ip link add br-vxlan0 type bridge
```
3. **桥接网络端口**：
将vxlan网络接口进行桥接，并将步骤1中所设置的ip转移到桥接器上：
```sh
ip link set vxlan0 master br-vxlan0
ip link set br-vxlan0 up 
ip addr del 10.88.88.2/24 dev vxlan0
ip addr add 10.88.88.1/24 dev br-vxlan0
```
将需要桥接的LAN连接到桥接器上,并将对应的网卡设置IP
```sh
ip link set eth1 master br-vxlan0
ip addr add eth1 192.168.10.3
```



