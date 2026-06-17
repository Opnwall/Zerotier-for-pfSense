
<div align="center">
    <div align="center"> 中文 | <a href="README.en-US.md">English</div>
</div>

# ZeroTier for pfSense

![pfSense CE](https://img.shields.io/badge/pfSense_CE-blue)
![pfSense Plus](https://img.shields.io/badge/pfSense_Plus-green)
![Architecture](https://img.shields.io/badge/Architecture-amd64-orange)

## 简介

ZeroTier 是一个安全的点对点（P2P）虚拟网络平台，可让设备在局域网（LAN）和广域网（WAN）环境中无缝通信，并提供类似企业级 SDN（软件定义网络）的能力。

由于 pfSense 官方并未提供 ZeroTier 插件，本项目将完整的 ZeroTier 管理界面直接集成到 pfSense WebGUI 中。用户可以直接在 pfSense 管理界面中管理 ZeroTier 服务、加入网络以及查看节点状态。

![](images/config.png)

已测试环境：

- pfSense CE 2.8.1（FreeBSD 15）
- pfSense Plus 26.03.1（FreeBSD 16）

## 功能特性

- WebGUI 图形化管理
- 节点状态监控
- 路由通告支持
- 开机自动启动
- 加入 ZeroTier 网络
- ZeroTier 服务管理
- 同时支持 pfSense CE 与 pfSense Plus

## 安装

将软件包上传到 pfSense：

```shell
/ root/pfSense-pkg-zerotier-1.16.2.pkg
```

通过 SSH 登录 pfSense，执行：

```shell
pkg add pfSense-pkg-zerotier-1.16.2.pkg
```

安装完成后，WebGUI 中将出现以下菜单：

```text
VPN -> ZeroTier VPN
```

## 卸载

```shell
pkg delete pfSense-pkg-zerotier
```

## 启用 ZeroTier

进入：

```text
VPN -> ZeroTier VPN
```

勾选：

```text
Enable Zerotier Client
```

保存配置后，ZeroTier 服务将自动启动。

## 可选的 local.conf 配置

进入：

```text
VPN -> ZeroTier VPN -> Configuration
```

在 `local.conf` 字段中填写可选的 ZeroTier `local.conf` JSON 配置内容。

如果留空，则会删除现有的 `local.conf` 文件。

请确保填写的是合法的 JSON 格式，否则 ZeroTier 可能无法正常启动。

## 加入 ZeroTier 网络

进入：

```text
VPN -> ZeroTier VPN -> Networks
```

点击：

```text
Join
```

输入：

```text
Network ID
```

保存配置即可加入网络。

## 节点授权

首次加入网络后，节点默认处于未授权状态。

登录 ZeroTier Central：

```text
https://my.zerotier.com
```

打开对应网络，进入：

```text
Members
```

找到刚刚加入的 pfSense 节点并进行以下操作：

- 勾选 `Authorized`
- 设置节点名称
- 分配 IP 地址
- 点击 `Save`

授权完成后，pfSense 中的 ZeroTier 网络状态将显示为：

```text
OK
```

## 路由管理

如果希望 ZeroTier 客户端访问 pfSense 后面的内网，需要在 ZeroTier Central 中添加 Managed Routes（托管路由）。

示例：

```text
Destination: 192.168.1.0/24
Via: 10.147.20.2
```
说明：

- `Destination`：pfSense LAN 网段
- `Via`：pfSense 的 ZeroTier IP 地址

配置完成后，远程 ZeroTier 客户端即可访问 pfSense 后方的局域网资源。

## 防火墙规则

如果希望局域网客户端访问远程 ZeroTier 网络，需要添加相应防火墙规则。

示例：

```text
Interface: LAN
Source: LAN net
Destination: any
Action: Pass
```
也可以根据实际需求限制为特定的 ZeroTier 子网。

## 查看 Peer 状态

进入：

```text
VPN -> ZeroTier VPN -> Peers
```

可查看以下信息：

- Peer 状态
- 延迟（Latency）
- 连接方式
- 路由信息
- 节点详情

## 卸载

执行：
```shell
pkg remove pfSense-pkg-zerotier
```

## 连通性测试

配置完成后，建议使用以下命令进行连通性测试：

```shell
ping
```

确认 ZeroTier 节点之间能够正常通信。

## 注意事项

- **不要**在 `Interfaces -> Assignments` 中手动分配 ZeroTier 接口，否则重启后网络配置可能会被重置。
- 插件已自带启动脚本，**不要**通过 Shellcmd 添加启动命令，否则可能导致 pfSense 在启动过程中卡死，无法正常完成引导。

## 免责声明

这是一个非官方社区项目，与 pfSense 团队没有任何关联，也未获得其认可或支持。 部署前请自行审查源代码，并自行承担使用过程中可能产生的风险。
