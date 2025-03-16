# Ubuntu Image Builder for Rockchip RK35xx

[中文文档](readme_CN.md) | [English Version](README.md)

![rk35xx](https://img.shields.io/badge/Platform-Rockchip_RK35xx-009688?logo=linux&style=flat)
![ubuntu](https://img.shields.io/badge/Ubuntu-20.04%7C22.04-dd4814?logo=ubuntu)

## 🛠️ Build Instructions

### 1. Create Root File System
```bash
# For minimal server images
sudo ./mkrootfs.sh focal

# For XFCE desktop images
sudo ./mkrootfs.sh jammy-xfce
```

**Clean existing rootfs**:
```bash
sudo ./mkrootfs.sh focal clean
sudo ./mkrootfs.sh jammy-xfce clean
```

### 2. Generate Target Image
```bash
# Syntax: ./mkimg.sh <soc> <board> <variant>
sudo ./mkimg.sh rk3568 h68k focal
sudo ./mkimg.sh rk3568 h69k-max jammy-xfce
```

### 3. Output Files
```
build/
├── h68k_ubuntu_focal_vYYYYMMDD.img
└── h69k-max_ubuntu_jammy-xfce_vYYYYMMDD.img
```
*Replace YYYYMMDD with actual build date*

## 🖥️ System Requirements
| Component       | Requirement                                  |
|-----------------|---------------------------------------------|
| Host OS         | x86_64: Ubuntu 20.04+/Debian 11+<br>arm64: Armbian/Ubuntu/Debian |
| Storage         | ≥8GB free space (SSD recommended)           |
| Dependencies    | `debootstrap` (latest version from [Ubuntu repo](https://git.launchpad.net/ubuntu/+source/debootstrap)) |

## ❗ Important Notes
1. Always verify image checksum before flashing
2. Desktop variants require at least 16GB storage
3. RK3568 and RK3588 have different U-Boot configurations

[切换到中文版](readme_CN.md)
