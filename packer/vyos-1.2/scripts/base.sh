#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# Add Debian Jessie Repository
set system package repository jessie components 'main contrib non-free'
set system package repository jessie distribution 'jessie'
set system package repository jessie url 'http://httpredir.debian.org/debian/'

# Tweak sshd to prevent DNS resolution (speed up logins)
set service ssh disable-host-validation
commit
save
