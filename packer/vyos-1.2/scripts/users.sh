#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# Load pubkey for david user
loadkey david /tmp/id_rsa.pub

# Disable ssh password authentication
set service ssh disable-password-authentication

# Disable password login for david user
set system login user david authentication encrypted-password '!'

commit
save
