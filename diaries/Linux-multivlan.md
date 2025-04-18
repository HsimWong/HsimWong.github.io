# Linux 多VLAN流量区分
## 简介
VLAN技术可以被用来区分和隔离不同的广播域，在应对IP冲突时可以通过不同VLAN进行不同主机的区分。但有时需要一个主机同时处理不同VLAN的信息，一个可行的方案是使用不同的物理网卡进行区分，但一方面存在主机以太网端口数量有限的情况，另一方面还需要占用对应数量的交换机端口，存在资源浪费的情况。另一个方案是建立虚拟网卡，在节点内部通过不同网卡编号进行区分。
## 结构
![image](https://github.com/user-attachments/assets/c9dfb58c-ac34-48e4-82d4-adb4cfd43ed6)

在节点内部，多个VLAN的流量通过一个以太网端口进入。建立对应的虚拟网卡以区分不同VLANid的流量。

## 实验步骤
1. 检查是否添加了vlan内核模块
```sh
lsmod | grep 8021q
modprobe 8021q
```
2. 安装vlan`apt install vlan`
3. 创建对应的VLAN接口：`ip link add link eth0 name eth0.131 type vlan id 131`.请注意，只有物理接口能够被用做base来创建虚拟接口。
4. 为虚拟接口配置IP：`ip addr add 10.254.0.99/24 dev eth0.131`
5. 开启虚拟接口：`ip link set up eth0.131`


## Reference
[1]<a href="https://wiki.ubuntu.com/vlan">https://wiki.ubuntu.com/vlan</a>
