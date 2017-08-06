#!/bin/vbash

# Disable the interface immidately so that we don't break the master on boot
ip link set eth1 down

# Wait until vyos have started
until systemctl is-active multi-user.target
do
  true
done

# Delete the mirror
tc qdisc del dev eth1 ingress
tc qdisc del dev eth1 root

# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template

# Disable DHCP server
# Make sure that this is not saved to the boot config, or the configuration might not load on boot.
configure
set service dhcp-server disabled 'true'
commit

exit
