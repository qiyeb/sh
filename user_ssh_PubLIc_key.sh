#!/bin/sh
# fix_ssh_access.sh

USER="kjds"
PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhfj3fbJMaMImfjlE4SrlkERz8d8FJhfhl45aoV98yrI+aPQl1n3SmiHiXcOoFdPJyergKsljjxgeHqJYMJPpau+rYjV72/hckuk1+2udpe3/2TSST/lcTgy9xcP1nqyz6zJdcXxYhQiVJfWgvmmBuvlrNkJNKN7VyuCo7HgOnUYx+SHAo2HfxcZgesY542VdrBAqjrV3n2ukbZuqx0PZmqH4CHAsDK+eiCiqXmcP2kCf2nnCulvMOHkSjk0gLbx9WgQIzvHVT/+7vyZb4cFCWuAhF52BfR6TyzkkiZ9R0LAjIQWNo0Myr9wkP2LBNwrLRfkxihEYGUEpyg+lp409mt8p8XynnwWcHmRzI/vKCKckzSNlSwRA0AtveX8tvqyILhi7LyEL07h6bCLqBagYsvhZd/xxYmATUmlC4DbK77zHzBCv52pPenthEGllEVcxcSQM0jh5oUNq7mX2vw/Af0DtaX05YA4JldOM2Bbtmn85ylmJRPGrdTFV1cT1Ig8GdF9Y7YwBZ/7dgzNT8MjZwyP41rRUVgohaom74Lftk3f3XKSDm1Dbs5sGG35PLlOriCISuijDPqArDgowjCv7h4ImUTC1TL9FlueFWziMPfp8QuairZDVmevSradEskU9EP2A1aXmk1SYtTd61yLog2YfcizA4XUHmJWPTScFnYw== KJDS@example.com
"

# 创建用户目录
mkdir -p /home/$USER
chown $USER:$USER /home/$USER

# 配置 SSH
mkdir -p /home/$USER/.ssh
echo $PUBLIC_KEY > /home/$USER/.ssh/authorized_keys
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
chown -R $USER:$USER /home/$USER/.ssh

# 配置 SSH 服务
uci set dropbear.@dropbear[0].PasswordAuth='off'
uci set dropbear.@dropbear[0].RootPasswordAuth='off'
uci commit dropbear
/etc/init.d/dropbear restart

echo "SSH public key authentication configured for $USER"