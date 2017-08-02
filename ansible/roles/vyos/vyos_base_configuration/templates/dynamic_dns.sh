#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

run show interfaces ethernet eth1 brief | grep u/u

if [ $? == 0 ]
then
  IP="$(run show interfaces ethernet eth1 | grep "inet " | awk -F ' ' '{print $4}')"

  (
  echo "server 127.0.0.1"
  echo "zone home.dmarby.se"

  echo "update delete home.dmarby.se A"
  echo "update add home.dmarby.se 60 A ${IP}"
  echo "send"
  ) | /usr/bin/nsupdate

  curl -H "Authorization: Bearer {{ digitalocean_token }}" -H "Content-Type: application/json" \
    -d '{"data": "'${IP}'"}' \
    -X PUT "https://api.digitalocean.com/v2/domains/home.dmarby.se/records/24417816"
fi

exit
