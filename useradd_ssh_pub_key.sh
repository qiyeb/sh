#!/bin/sh
# 功能：创建管理员用户、配置SSH密钥、设置sudo权限

set -e  # 任何命令失败则退出脚本

# 配置变量
USERNAME="kjds"
PASSWORD="super-sheng*v0"  # 生产环境建议使用更复杂的密码
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhfj3fbJMaMImfjlE4SrlkERz8d8FJhfhl45aoV98yrI+aPQl1n3SmiHiXcOoFdPJyergKsljjxgeHqJYMJPpau+rYjV72/hckuk1+2udpe3/2TSST/lcTgy9xcP1nqyz6zJdcXxYhQiVJfWgvmmBuvlrNkJNKN7VyuCo7HgOnUYx+SHAo2HfxcZgesY542VdrBAqjrV3n2ukbZuqx0PZmqH4CHAsDK+eiCiqXmcP2kCf2nnCulvMOHkSjk0gLbx9WgQIzvHVT/+7vyZb4cFCWuAhF52BfR6TyzkkiZ9R0LAjIQWNo0Myr9wkP2LBNwrLRfkxihEYGUEpyg+lp409mt8p8XynnwWcHmRzI/vKCKckzSNlSwRA0AtveX8tvqyILhi7LyEL07h6bCLqBagYsvhZd/xxYmATUmlC4DbK77zHzBCv52pPenthEGllEVcxcSQM0jh5oUNq7mX2vw/Af0DtaX05YA4JldOM2Bbtmn85ylmJRPGrdTFV1cT1Ig8GdF9Y7YwBZ/7dgzNT8MjZwyP41rRUVgohaom74Lftk3f3XKSDm1Dbs5sGG35PLlOriCISuijDPqArDgowjCv7h4ImUTC1TL9FlueFWziMPfp8QuairZDVmevSradEskU9EP2A1aXmk1SYtTd61yLog2YfcizA4XUHmJWPTScFnYw== KJDS@example.com"  # 替换为你的公钥

echo "=== 开始配置用户 $USERNAME ==="

# 1. 安装必要软件包
echo "安装依赖包..."
opkg update
opkg install shadow-useradd shadow-usermod sudo tailscale ethtool kmod-tcp-bbr ss || {
    echo "错误：软件包安装失败"
    exit 1
}

# 2. 创建用户
echo "创建用户 $USERNAME..."
if ! grep -q "^$USERNAME:" /etc/passwd; then
    useradd -m -s /bin/ash "$USERNAME" || {
        echo "错误：用户创建失败"
        exit 1
    }
else
    echo "用户已存在，跳过创建"
fi

# 3. 设置密码
echo "设置密码..."
echo "$USERNAME:$PASSWORD" | chpasswd || {
    echo "错误：密码设置失败"
    exit 1
}

# 4. 添加到root组
echo "添加到管理员组..."
if ! id "$USERNAME" | grep -q "root"; then
    usermod -a -G root "$USERNAME" || {
        echo "错误：添加到root组失败"
        exit 1
    }
else
    echo "用户已在root组中"
fi

# 5. 配置sudo权限
echo "配置sudo权限..."
if ! grep -q "^$USERNAME" /etc/sudoers; then
    echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers || {
        echo "错误：sudo配置失败"
        exit 1
    }
else
    echo "sudo权限已存在"
fi

# 6. 配置SSH密钥
echo "配置SSH密钥..."
mkdir -p "/home/$USERNAME/.ssh"
echo "$SSH_KEY" > "/home/$USERNAME/.ssh/authorized_keys"

# 设置权限
chmod 700 "/home/$USERNAME/.ssh"
chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"

# 重启SSH服务
/etc/init.d/dropbear restart

echo "=== 配置完成 ==="
echo "用户名: $USERNAME"
echo "密码: $PASSWORD (首次登录后请立即更改)"
echo "SSH连接命令: ssh $USERNAME@[路由器IP]"
