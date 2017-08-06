#!/bin/vbash

# Wait until vyos have started
until systemctl is-active multi-user.target
do
  true
done

# Enable WAN interface
ip link set eth1 up

# Mirror the inbound traffic
tc qdisc add dev eth1 ingress
tc filter add dev eth1 parent ffff:       \
    protocol all                                \
    u32 match u8 0 0                            \
    action mirred egress mirror dev eth0.30

# Mirror the outbound traffic
tc qdisc add dev eth1 handle 1: root prio
tc filter add dev eth1 parent 1:          \
    protocol all                                \
    u32 match u8 0 0                            \
    action mirred egress mirror dev eth0.30

# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template

# Ensure that WAN interface gets address
run renew dhcp interface eth1

# Restart bind
sudo service bind9 restart

# Enable DHCP server
configure
set service dhcp-server disabled 'false'
commit

Restart OpenVPN
set interfaces openvpn vtun0 disable
commit
until ping -c1 www.google.com &>/dev/null
do
 sleep 5
done
delete interfaces openvpn vtun0 disable
commit

exit
