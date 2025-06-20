# 关闭selinux
setenforce 0
sed -Ei 's/^(SELINUX=).*/\1disabled/' /etc/selinux/config

# 关闭防火墙
systemctl disable --now firewalld

# 修改默认网卡名
sed -Ei 's/^(GRUB_CMDLINE_LINUX=".*)"/\1 net.ifnames=0"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg || grub-mkconfig -o /boot/grub/grub.cfg

