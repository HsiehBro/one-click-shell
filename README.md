# one-click-shell

> run once, get everything

## networking

modify the default network card name starting from eth0
```bash
sed -Ei 's/^(GRUB_CMDLINE_LINUX=".*)"/\1 net.ifnames=0"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg || grub-mkconfig -o /boot/grub/grub.cfg
reboot
```

view the system's default network service
```bash
systemctl list-units --type=service | grep -P "NetworkManager|networkd|networking"
```

<details>
  
  <summary>NetworkManager.service</summary>
  
  ```bash
  # yum install -y NetworkManager || yum install -y network-manager
  # sed -i '/^\[ifupdown\]/,/^\[/{s/^managed=.*/managed=true/}' /etc/NetworkManager/NetworkManager.conf
  nmcli con add type ethernet ifname eth0 con-name con-eth0 ip4 10.0.0.100/24 gw4 10.0.0.254 ipv4.dns 223.5.5.5
  nmcli con up con-eth0
  ```

</details>
<details>
  
  <summary>systemd-networkd.service</summary>
  
  ```bash
  cat > "/etc/netplan/00-eth0.conf" << EOF
  network:
    ethernets:
      eth0:
        addresses:
          - "10.0.0.1/24"
        routes:
          - to: default
            via: 10.0.0.254
        nameservers:
          search: [hsieh.com] 
          addresses: [223.5.5.5,223.6.6.6]  
  EOF

  netplan apply
  ```

</details>
<details>
  
  <summary>networking.service</summary>
  
  ```bash
  # apt install -y ifupdown
  ifdown ens33
  cat > "/etc/network/interfaces.d/eth0.cfg" <<EOF
  auto eth0
  # iface eth0 inet auto
  iface eth0 inet static
    address 10.0.0.100
    netmask 255.255.255.0
    gateway 10.0.0.254
    dns.nameservers 223.5.5.5
  EOF
  ifup eth0
  ```

</details>

### Bonding

```bash
nmcli dev
nmcli con add type bond ifname bond0 con-name con-bond0 mode active-backup ip4 10.0.0.100/24 gw4 10.0.0.254
nmcli con add type bond-slave  ifname eth1 con-name bond0-slave-eth1 master bond0
nmcli con add type bond-slave  ifname eth2 con-name bond0-slave-eth1 master bond0
nmcli con reload
```

### Bridge

```bash
# yum install -y bridge-utils
brctl addbr br0
brctl addif br0 eth1
brctl show
```
## time

### timezone

```bash
date -R
systemctl set-timezone Asia/Shanghai
systemctl status
clock -w
```

### chrony

```bash
# SERVER
# yum install -y chrony
systemctl enable --now chronyd
vim /etc/chrony.conf
  server ntp.aliyun.com iburst
  allow 0.0.0.0/0
  local startum 10
systemctl restart chronyd
chronyc sources -v
```

