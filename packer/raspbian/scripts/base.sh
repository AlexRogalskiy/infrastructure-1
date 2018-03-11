#!/bin/bash
# A lot of this is based on https://github.com/svbl/picomrade/blob/master/README.md

# Enable SSH
touch /boot/ssh

# Fix locale
sed -i -r 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen en_US.UTF-8
update-locale en_US.UTF-8

# Install real vim
apt-get purge -y --force-yes vim-tiny
apt-get install -y --force-yes vim

# Add public key for ssh
install -d -m 700 /home/pi/.ssh
cp /tmp/id_rsa.pub /home/pi/.ssh/authorized_keys
chown -R pi:pi /home/pi/.ssh
chmod -R 700 /home/pi/.ssh

# Disable password auth and root login
sed -i -r 's/^#?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i -r 's/^#?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Set wifi credentials
cat << EOF | tee -a /etc/wpa_supplicant/wpa_supplicant.conf
network={
	ssid="${WIFI_SSID}"
	psk="${WIFI_PASSWORD}"
}
EOF

# Setup wireless interface
cat << EOF | tee -a /etc/network/interfaces
auto wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

# Disable swap
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

# Disable avahi-daemon as we don't need it
systemctl disable avahi-daemon

# Remove uneccesary things that write to the sdcard
sed -i '/vfat/s/defaults\s/defaults,noatime/;s/2$/0/;s/1$/0/' /etc/fstab

cat << EOF | tee /etc/cron.hourly/fake-hwclock
#!/bin/sh
exit 0
EOF

cat << EOF | tee /etc/cron.daily/man-db
#!/bin/sh
exit 0
EOF

cat << EOF | tee /etc/cron.weekly/man-db
#!/bin/sh
exit 0
EOF
