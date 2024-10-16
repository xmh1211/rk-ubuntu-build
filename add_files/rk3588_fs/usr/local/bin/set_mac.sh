#!/bin/bash

# 检查参数数量
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <network_interface>" >&2
    exit 1
fi

# 获取网口名称
INTERFACE=$1

# 配置文件位置
BASE_MAC_CONFIG="/etc/mac_base_addresses.conf"
CURRENT_MAC_CONFIG="/etc/current_mac.conf"

# 获取所有以 e 开头的物理以太网接口，按ASCII顺序排序
INTERFACES=($(for iface in /sys/class/net/*; do
    # 检查是否是以太网接口（值为 1），并以 e 开头
    if [[ -e "$iface/type" && $(cat "$iface/type") -eq 1 && $(basename "$iface") == e* ]]; then
        basename "$iface"
    fi
done | sort))

# 验证输入的网口名称是否在 INTERFACES 数组中
if [[ ! " ${INTERFACES[@]} " =~ " ${INTERFACE} " ]]; then
    echo "Network interface $INTERFACE does not exist in the physical Ethernet interfaces." >&2
    exit 1
fi

# 定义函数获取序列号或唯一标识
get_unique_id() {
    CPU_SN=$(grep 'Serial' /proc/cpuinfo 2>/dev/null | awk '{print $3}' 2>/dev/null)

    if [ -n "$CPU_SN" ]; then
        SERIAL="$CPU_SN"
    elif [ -d /sys/block/mmcblk1 ]; then
        SERIAL=$(cat /sys/block/mmcblk1/device/serial 2>/dev/null)
    elif [ -d /sys/block/mmcblk0 ]; then
        SERIAL=$(cat /sys/block/mmcblk0/device/serial 2>/dev/null)
    elif [ -f /etc/machine-id ]; then
        SERIAL=$(cat /etc/machine-id 2>/dev/null)
    else
        SERIAL=$(od -An -N6 -tx1 /dev/random | tr -d ' \n')
    fi

    SERIAL="${SERIAL,,}"  # 转换为小写
    SERIAL=$(echo "$SERIAL" | sed 's/^0x//')  # 去除前缀 "0X"
    echo "${SERIAL:0:12}"  # 返回前 12 个字符
}

# 读取基础MAC地址的可选值
read_base_mac_address() {
    if [[ -f "$BASE_MAC_CONFIG" ]]; then
        shuf -n 1 "$BASE_MAC_CONFIG"
    else
        return 1
    fi
}

# 保存现有的基础 MAC 地址到配置文件
save_current_mac_address() {
    echo "$1" > "$CURRENT_MAC_CONFIG"
    chmod 600 "$CURRENT_MAC_CONFIG"  # 设置文件权限，为root用户可读写
}

# 保存默认 MAC 地址到配置文件
save_default_mac_addresses() {
    echo -e "02:00:00\n02:00:01\n02:00:02\n02:00:03" > "$BASE_MAC_CONFIG"
    chmod 600 "$BASE_MAC_CONFIG"  # 设置文件权限，为root用户可读写
}

# 生成MAC地址的后3段
generate_mac_suffix() {
    local UNIQUE_ID=$(get_unique_id)
    local BYTE1="${UNIQUE_ID:0:2}"
    local BYTE2="${UNIQUE_ID:2:2}"
    local BYTE3="${UNIQUE_ID:4:2}"
    echo "$BYTE1:$BYTE2:$BYTE3"
}

# MAC地址增减
mac_offset() {
    local MAC_ADDRESS=$1
    local OFFSET=$2

    if ! [[ $MAC_ADDRESS =~ ^([0-9a-f]{2}(:|-)){5}([0-9a-f]{2})$ ]]; then
        echo "Invalid MAC address format." >&2
        return 1
    fi

    IFS=':' read -r b1 b2 b3 b4 b5 b6 <<< "$MAC_ADDRESS"
    MAC_DEC=$(( (0x$b1 << 40) | (0x$b2 << 32) | (0x$b3 << 24) | (0x$b4 << 16) | (0x$b5 << 8) | (0x$b6) ))

    MAC_DEC=$(( MAC_DEC + OFFSET ))

    NEW_MAC=$(printf "%02X:%02X:%02X:%02X:%02X:%02X" \
        $(( (MAC_DEC >> 40) & 0xFF )) \
        $(( (MAC_DEC >> 32) & 0xFF )) \
        $(( (MAC_DEC >> 24) & 0xFF )) \
        $(( (MAC_DEC >> 16) & 0xFF )) \
        $(( (MAC_DEC >> 8) & 0xFF )) \
        $(( MAC_DEC & 0xFF )))

    echo "$NEW_MAC" | tr '[:upper:]' '[:lower:]'  # 转换为小写
}

# 检查并生成基础MAC地址
if [[ -f "$CURRENT_MAC_CONFIG" ]]; then
    # 如果配置文件已存在，读取MAC地址
    BASE_MAC_ADDRESS=$(cat "$CURRENT_MAC_CONFIG")
else
    # 如果配置文件不存在，生成新的基础MAC地址，并保存
    BASE_MAC_ADDRESS=$(read_base_mac_address)
    if [[ -z "$BASE_MAC_ADDRESS" ]]; then
        save_default_mac_addresses
        BASE_MAC_ADDRESS=$(read_base_mac_address)
    fi

    # 保存新的基础 MAC 地址
    save_current_mac_address "$BASE_MAC_ADDRESS"
fi

# 获取MAC地址的后3段
MAC_SUFFIX=$(generate_mac_suffix)

# 组合成完整的MAC地址
FINAL_MAC_ADDRESS="$BASE_MAC_ADDRESS:$MAC_SUFFIX"

# 找到输入的网络接口的索引
INDEX=1
for iface in "${INTERFACES[@]}"; do
    if [[ "$iface" == "$INTERFACE" ]]; then
        break
    fi
    INDEX=$((INDEX + 1))
done

# 忽略空接口
if (( INDEX > 0 )); then
    # 根据接口的索引进行增减，总是减去1作为偏移
    OFFSET=$((INDEX - 1))  # 直接使用索引减去1作为偏移
    [ $OFFSET -gt 0 ] && FINAL_MAC_ADDRESS=$(mac_offset "$FINAL_MAC_ADDRESS" "$OFFSET")

    # 获取当前接口的 MAC 地址并转换为小写
    CURRENT_MAC_ADDRESS=$(cat /sys/class/net/$INTERFACE/address | tr '[:upper:]' '[:lower:]')

    # 检查当前 MAC 地址是否与新设置的地址相同
    if [[ "$CURRENT_MAC_ADDRESS" == "$FINAL_MAC_ADDRESS" ]]; then
        echo "MAC Address for $INTERFACE is already set to $FINAL_MAC_ADDRESS. No changes made."
    else
        echo "Resulting MAC Address for $INTERFACE: $FINAL_MAC_ADDRESS"

        # 设置指定接口的 MAC 地址
        ip link set dev "$INTERFACE" down             # 先将接口关闭
        ip link set dev "$INTERFACE" address "$FINAL_MAC_ADDRESS"  # 设置新的 MAC 地址
        ip link set dev "$INTERFACE" up               # 重新启用接口
        echo "MAC Address for $INTERFACE has been set to $FINAL_MAC_ADDRESS."
    fi
else
    echo "Interface $INTERFACE not found in the sorted list." >&2
fi
