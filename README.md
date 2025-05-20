# one-click-shell

> run once, get everything

## networking

modify the default network card name starting from eth0
```bash
sed -i 's/^\(GRUB_CMDLINE_LINUX=".*\)"/\1 net.ifnames=0"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
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
  nmcli con reload
  nmcli con up con-eth0
  ```

</details>
<details>
  
  <summary>systemd-networkd.service</summary>
  
  ```bash
  # sudo apt install -y systemd
  cat > "/etc/systemd/network/00-eth0.network" << EOF
  [Match]
  Name=eth0
  
  [Network]
  # DHCP=yes
  Address=192.168.1.100/24
  Gateway=192.168.1.1
  DNS=8.8.8.8
  DNS=1.1.1.1
  
  [Route]
  Destination=10.10.0.0/16
  Gateway=192.168.1.254
  
  EOF
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

