#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

run show interfaces ethernet eth1 brief | grep u/u

if [ $? == 0 ]
then
  IP="$(run show interfaces ethernet eth1 | grep "inet " | awk -F ' ' '{print $4}')"

  curl -H "Authorization: Bearer {{ digitalocean_token }}" -H "Content-Type: application/json" \
    -d '{"data": "'${IP}'"}' \
    -X PUT "https://api.digitalocean.com/v2/domains/home.dmarby.se/records/24417816"
fi

exit
