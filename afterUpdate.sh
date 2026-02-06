# 
# put commands to run after git update here - don't modify checkUpdate.sh or
# else you need an extra reboot

echo "Git changed - copying code across"
sudo chown pi:pi -R /home/pi/grove-startup-scripts
if [ -s "/home/pi/grove-startup-scripts/rc.local" ] 
then
    sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local
fi
if [ ! -s "/home/pi/emergency.sh" ] 
then
    sudo cp /home/pi/grove-startup-scripts/emergency.sh /home/pi/emergency.sh
fi

if [ -f /boot/firmware/setup_dss_mac_address.sh ]; then
    bash /boot/firmware/setup_dss_mac_address.sh
    sudo mount -o remount,rw /boot/firmware
    sudo rm /boot/firmware/setup_dss_mac_address.sh
    sudo mount -o remount,ro /boot/firmware
fi

sudo cp /home/pi/grove-startup-scripts/eduroam.pem /etc/eduroam.pem
sudo chown root:root /etc/eduroam.pem
sudo chmod go-rwx /etc/eduroam.pem

sudo cp /etc/skel/.bashrc /home/dss/.bashrc
sudo cp /etc/skel/.bashrc /home/dss/.profile
sudo sed -i "1i export PYTHONPATH=~/grove-base" /home/dss/.profile
sudo sed -i "1i export PYTHONPATH=~/grove-base" /home/dss/.bashrc
sudo bash -c "echo  \"source ~/pyenv/bin/activate\" >> /home/dss/.bashrc"
sudo bash -c "echo  \"source ~/pyenv/bin/activate\" >> /home/dss/.profile"
sudo chown dss:dss .bashrc 
sudo chown dss:dss .profile

sudo cp /home/pi/grove-startup-scripts/getlatest.sh /home/dss/getlatest.sh
sudo chown dss:dss /home/dss/getlatest.sh
sudo -u dss bash -c "cd /home/dss && bash /home/dss/getlatest.sh"



sudo mkdir -p /home/dss/.ssh
sudo cp /home/pi/grove-startup-scripts/authorized_keys /home/dss/.ssh/
sudo chown dss:dss /home/dss/.ssh
sudo chown dss:dss /home/dss/.ssh/authorized_keys
sudo chmod 644 /home/dss/.ssh/authorized_keys
# fix dss password in case someone changed it
sudo grep -q dss /etc/shadow || echo 'dss:$y$j9T$KO7JYfq4trQCsxsxJ0oPC1$G9zo8sbrS4PVoLNMhaROoor3YB1f56V1dBz8OnGWeaB:19034::::::'|sudo tee -a /etc/shadow

sudo /usr/bin/python /home/pi/grove-startup-scripts/checkFirmware.py


echo "Installing avrdude"
# add gpio conf for grovepi to avrdude
sudo cp /home/pi/grove-startup-scripts/avrdude /usr/bin/avrdude
sudo chmod a+x /usr/bin/avrdude
sudo cp /home/pi/grove-startup-scripts/avrdude.conf /usr/local/etc/avrdude.conf
sudo chown root:root /usr/local/etc/avrdude.conf

# disable cloud-init because it makes boot super slow
sudo touch /etc/cloud/cloud-init.disabled

### the stuff below just makes sure that if the user has a network cable plugged in but no DHCP server,
# it will still get a link-local address so that it can be accessed over the network 
# - this means it can auto-configure on direct cable to cable laptop connection

# Create a NetworkManager connection file that tries DHCP first
CONNFILE1=/etc/NetworkManager/system-connections/eth0-dhcp.nmconnection
UUID1=$(uuid -v4)
sudo bash -c "cat <<- EOF >${CONNFILE1}
[connection]
	id=eth0-dhcp
	uuid=${UUID1}
	type=ethernet
	interface-name=eth0
	autoconnect-priority=100
	autoconnect-retries=2
	[ethernet]
	[ipv4]
	dhcp-timeout=3
	method=auto
	[ipv6]
	addr-gen-mode=default
	method=auto
	[proxy]
	EOF"

# Create a NetworkManager connection file that assigns a Link-Local address if DHCP fails
CONNFILE2=/etc/NetworkManager/system-connections/eth0-ll.nmconnection
UUID2=$(uuid -v4)
sudo bash -c "cat <<- EOF >${CONNFILE2}
	[connection]
	id=eth0-ll
	uuid=${UUID2}
	type=ethernet
	interface-name=eth0
	autoconnect-priority=50
	[ethernet]
	[ipv4]
	method=link-local
	[ipv6]
	addr-gen-mode=default
	method=auto
	[proxy]
	EOF"
# NetworkManager will ignore nmconnection files with incorrect permissions so change them here
sudo chmod 600 ${CONNFILE1}
sudo chmod 600 ${CONNFILE2}