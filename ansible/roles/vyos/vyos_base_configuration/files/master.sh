#!/bin/vbash

# Wait until vyos have started
until systemctl is-active multi-user.target
do
  true
done

# Enable WAN interface
ip link set eth1 up

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
