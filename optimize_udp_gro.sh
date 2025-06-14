#!/bin/sh
# OpenWrt UDP GRO 优化脚本
# 文件名：optimize_udp_gro.sh

echo "=== 开始优化 UDP GRO 配置 ==="

# 配置参数
TIMEOUT=1000  # 超时时间（毫秒）
INTERFACES="eth0 eth1 eth2 wlan0"  # 需要优化的接口

# 应用优化到所有接口
for iface in $INTERFACES; do
    if [ -e /sys/class/net/$iface ]; then
        echo "优化接口: $iface"
        
        # 启用 GRO
        ethtool -K $iface gro on
        
        # 设置 flush 超时
        echo $TIMEOUT > /sys/class/net/$iface/gro_flush_timeout 2>/dev/null
        
        # 检查结果
        GRO_STATUS=$(ethtool -k $iface | grep generic-receive-offload | awk '{print $2}')
        echo "$iface GRO 状态: $GRO_STATUS"
    fi
done

# 永久配置
echo "创建启动脚本..."
cat << 'EOF' > /etc/init.d/udp_gro_optimize
#!/bin/sh /etc/rc.common
START=99
start() {
    sleep 5
    for iface in eth0 eth1 eth2 wlan0; do
        [ -e /sys/class/net/$iface ] || continue
        ethtool -K $iface gro on
        echo 1000 > /sys/class/net/$iface/gro_flush_timeout
    done
}
EOF

chmod +x /etc/init.d/udp_gro_optimize
/etc/init.d/udp_gro_optimize enable

# 调整内核参数
echo "优化内核参数..."
echo "net.core.rmem_max=2500000" >> /etc/sysctl.conf
echo "net.core.wmem_max=2500000" >> /etc/sysctl.conf
sysctl -p

echo "=== 优化完成 ==="
echo "请重启系统使所有配置生效: reboot"
