#!/bin/vbash

if [ "$(id -g -n)" != 'vyattacfg' ] ; then
exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template

# Wait until vyos have started
until systemctl is-active vyatta-router
do
  sleep 5
done

configure
set interfaces ethernet eth1 disable
commit

exit
