#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# Set up DHCP on default interface on our servers VLAN
set interface ethernet eth0 vif 20 address dhcp

# Enable and configure SSH
set service ssh
set service ssh disable-host-validation

# Delete default vyos user
delete system login user vyos

commit
save
