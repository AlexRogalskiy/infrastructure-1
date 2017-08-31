#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

set interfaces ethernet eth0 address '{{ router_ip }}'
set interfaces ethernet eth0 description 'LAN'

# Set up publickey authentication for the vyos user
set system login user vyos authentication public-keys {{ lookup('file', ssh_public_key_path).split(' ')[2] }} type {{ lookup('file', ssh_public_key_path).split(' ')[0] }}
set system login user vyos authentication public-keys {{ lookup('file', ssh_public_key_path).split(' ')[2] }} key {{ lookup('file', ssh_public_key_path).split(' ')[1] }}

set system login user vyos authentication public-keys vyos type {{ lookup('file', '../vyos_rsa.pub').split(' ')[0] }}
set system login user vyos authentication public-keys vyos key {{ lookup('file', '../vyos_rsa.pub').split(' ')[1] }}

# Enable ssh
set service ssh port '22'

# Disable password auth for ssh
set service ssh disable-password-authentication

commit
save
exit
