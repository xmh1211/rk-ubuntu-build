# Ubuntu Image Builder for Rockchip RK35xx

[中文文档](readme_CN.md) | [English Version](README.md)

![structure](https://img.shields.io/badge/Project_Structure-Organized-009688?logo=files&style=flat)

## 📂 File Structure
```
env/
├── custom/          # Custom configurations
│   ├── boot256-ext4root.env
│   ├── boot256-xfsroot.env
│   └── ...
├── linux/           # Linux distributions
│   ├── focal.env    # Ubuntu 20.04
│   ├── jammy-xfce.env  # Ubuntu 22.04 with XFCE
│   └── ...
├── machine/         # Device models
│   ├── h68k.env     # For H68K board
│   ├── h69k-max.env # For H69K-MAX board
│   └── ...
└── soc/             # Chip configurations
    ├── rk3568.env   # RK3568 chipset
    ├── rk3588.env   # RK3588 chipset
    └── ...
```

![components](https://img.shields.io/badge/Upstream_Components-Manual_Upload-009688?logo=archive&style=flat)

## 📂 Core Components Management

### Upstream Directory Structure
```
upstream/
├── bootfs/           # Boot filesystems
│   └── <machine>/    # Per-device boot assets
│       ├── boot.bmp  # Boot logo
│       ├── boot.cmd  # U-Boot commands
│       └── boot.scr  # Compiled boot script
├── bootloader/       # Bootloaders
│   └── <machine>/    # Device-specific binaries
│       ├── idbloader.img
│       └── u-boot.itb
└── kernel/           # Kernel packages
    ├── mainline/     # Mainline kernels
    ├── rk3588/       # RK3588专用内核
    └── rk35xx/       # RK35xx系列专用内核
```

### Kernel Preparation (Manual Steps)
1. **Download Packages** from kernel maintainers
2. **Upload Files** to corresponding directories:
```bash
# Example: Upload RK35xx kernel
cp boot-5.10.160*.tar.gz upstream/kernel/rk35xx/
cp dtb-rockchip-5.10.160*.tar.gz upstream/kernel/rk35xx/
```

📦 **Required Packages per Kernel**:
| Package Type          | Naming Pattern                    |
|-----------------------|-----------------------------------|
| Boot Files            | `boot-<version>.tar.gz`           |
| Device Tree Blobs     | `dtb-rockchip-<version>.tar.gz`   |
| Kernel Headers        | `header-<version>.tar.gz`         |
| Kernel Modules        | `modules-<version>.tar.gz`        |

❗ **Important**:  
Kernel versions must match between packages. Example valid set:  
```
boot-5.10.160-rk35xx-flippy-2412a.tar.gz
dtb-rockchip-5.10.160-rk35xx-flippy-2412a.tar.gz
modules-5.10.160-rk35xx-flippy-2412a.tar.gz
```

## 🛠️ Build Instructions

### 1. Create Root File System
```bash
# Syntax: ./mkrootfs.sh <linux-flavor>
sudo ./mkrootfs.sh focal          # Ubuntu 20.04
sudo ./mkrootfs.sh jammy-xfce     # Ubuntu 22.04 with XFCE
```

🔍 **Parameter Explanation**  
`<linux-flavor>` corresponds to `.env` files in `env/linux/` directory. For example:
- `focal` → `env/linux/focal.env`
- `jammy-xfce` → `env/linux/jammy-xfce.env`

### 2. Generate Target Image
```bash
# Syntax: ./mkimg.sh <soc> <machine> <linux-flavor> [custom]
sudo ./mkimg.sh rk3568 h68k focal           # Basic usage
sudo ./mkimg.sh rk3588 h69k-max jammy-xfce boot256-ext4root  # With custom config
```

🔍 **Parameter Details**  
| Parameter      | Location               | Example File            | Required |
|----------------|------------------------|-------------------------|----------|
| `<soc>`        | `env/soc/`             | rk3568.env              | Yes      |
| `<machine>`    | `env/machine/`         | h68k.env                | Yes      |
| `<linux-flavor>`| `env/linux/`          | jammy-xfce.env          | Yes      |
| `[custom]`     | `env/custom/`          | boot256-ext4root.env    | Optional |

## 🧩 Configuration Files
All `.env` files use simple key-value format:
```ini
# Example env/linux/focal.env
export DEBOOTSTRAP_MIRROR="http://mirrors.ustc.edu.cn/ubuntu-ports/"
export SOURCES_LIST_WORK="${WORKDIR}/conf/focal/sources.list.work"
export SOURCES_LIST_ORIG="${WORKDIR}/conf/focal/sources.list"
export OS_RELEASE="focal"
export DIST_ALIAS="focal"
```

[切换到中文版](readme_CN.md)
