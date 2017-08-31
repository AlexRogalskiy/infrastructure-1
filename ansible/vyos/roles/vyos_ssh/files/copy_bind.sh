#!/bin/vbash

RSYNCBIN=/usr/bin/rsync
SSHBIN=/usr/bin/ssh

LOCAL_PATH=/etc/bind/
REMOTE_HOST='10.0.0.3'
REMOTE_PATH='/etc/bind'
REMOTE_BIND_COMMAND='/usr/bin/sudo /bin/systemctl reload bind9'

# Flush journal files to zone files
/usr/bin/sudo /usr/sbin/rndc sync -clean

result=$($RSYNCBIN -aiz --exclude "*.jnl" --exclude "*.key" --delete $LOCAL_PATH -e "$SSHBIN" --rsync-path="/usr/bin/sudo /usr/bin/rsync"  $REMOTE_HOST:$REMOTE_PATH);
count=${#result};

if [ $count -gt 5 ]
then
  $SSHBIN $REMOTE_HOST exec "$REMOTE_BIND_COMMAND";
fi

exit
