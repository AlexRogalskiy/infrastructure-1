#!/bin/vbash

# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template

# Wait until vyos have started
until systemctl is-active multi-user.target
do
  sleep 5
done

# Disable the WAN interface
# Make sure that this is not saved to the boot config, or the configuration won't load on boot.
configure
set interfaces ethernet eth1 disable
commit

exit
