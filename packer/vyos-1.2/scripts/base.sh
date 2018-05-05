#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# Set up DHCP on default interface
set interface ethernet eth0 address dhcp

# Enable and configure SSH
set service ssh
set service ssh disable-host-validation

# Delete default vyos user
delete system login user vyos

# Add Debian Jessie Repository
set system package repository jessie components 'main contrib non-free'
set system package repository jessie distribution 'jessie'
set system package repository jessie url 'http://httpredir.debian.org/debian/'

commit
save
