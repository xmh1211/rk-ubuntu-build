# Rockchip RK35xx 设备 Ubuntu 镜像构建工具

[English Documentation](README.md) | [中文文档](readme_CN.md)

![rk35xx](https://img.shields.io/badge/平台-Rockchip_RK35xx-009688?logo=linux&style=flat)
![ubuntu](https://img.shields.io/badge/Ubuntu-20.04%7C22.04-dd4814?logo=ubuntu)

## 🛠️ 构建指南

### 1. 创建根文件系统
```bash
# 最小化服务器镜像
sudo ./mkrootfs.sh focal

# XFCE 桌面镜像
sudo ./mkrootfs.sh jammy-xfce
```

**清理已有根文件系统**:
```bash
sudo ./mkrootfs.sh focal clean
sudo ./mkrootfs.sh jammy-xfce clean
```

### 2. 生成目标镜像
```bash
# 语法: ./mkimg.sh <芯片型号> <开发板> <系统版本>
sudo ./mkimg.sh rk3568 h68k focal
sudo ./mkimg.sh rk3568 h69k-max jammy-xfce
```

### 3. 输出文件
```
build/
├── h68k_ubuntu_focal_vYYYYMMDD.img
└── h69k-max_ubuntu_jammy-xfce_vYYYYMMDD.img
```
*请将 YYYYMMDD 替换为实际构建日期*

## 🖥️ 系统要求
| 组件           | 要求                                         |
|----------------|--------------------------------------------|
| 宿主系统       | x86_64: Ubuntu 20.04+/Debian 11+<br>arm64: Armbian/Ubuntu/Debian |
| 存储空间       | ≥8GB 可用空间 (推荐SSD)                    |
| 依赖项         | `debootstrap` ([最新版本](https://git.launchpad.net/ubuntu/+source/debootstrap)) |

## ❗ 重要提示
1. 烧录前务必校验镜像哈希值
2. 桌面版镜像需要至少16GB存储空间
3. RK3568 和 RK3588 使用不同的 U-Boot 配置

[Switch to English](README.md)
