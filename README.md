# one-click-shell

> run once, get everything

## networking
<details>
  
  <summary>CentOS</summary>
  
  ```bash
  nmcli con add type ethernet ifname eth0 con-name con-eth0 ip4 10.0.0.100/24 gw4 10.0.0.254 ipv4.dns 223.5.5.5
  nmcli con reload
  nmcli con up con-eth0
  ```

</details>
<details>
  
  <summary>Debian</summary>
  
  ```bash
  ifdown ens33
  cat > "/etc/network/interfaces.d/eth0.cfg" <<EOF
  auto eth0
  iface eth0 inet static
    address 10.0.0.100
    netmask 255.255.255.0
    gateway 10.0.0.254
    dns.nameservers 223.5.5.5
  EOF
  ifup eth0
  ```

</details>
