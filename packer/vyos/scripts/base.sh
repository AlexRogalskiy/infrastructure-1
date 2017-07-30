#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# Add lithium repository
set system package repository lithium components 'main'
set system package repository lithium distribution 'current'
set system package repository lithium url 'http://dev.packages.vyos.net/vyos/'
commit
save

# Add Debian Jessie Repository
set system package repository jessie components 'main contrib non-free'
set system package repository jessie distribution 'jessie'
set system package repository jessie url 'http://httpredir.debian.org/debian/'

# Add vmware repository
set system package repository vmware components 'main'
set system package repository vmware distribution 'trusty'
set system package repository vmware url 'https://packages.vmware.com/packages/ubuntu'

commit
save

sudo apt-get -y install apt-transport-https
sudo apt-get -y update
sudo apt-get -y install open-vm-tools-deploypkg --force-yes
sudo service open-vm-tools restart

# Tweak sshd to prevent DNS resolution (speed up logins)
set service ssh disable-host-validation
commit
save
