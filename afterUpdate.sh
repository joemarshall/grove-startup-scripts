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

sudo cp /home/pi/grove-startup-scripts/eduroam.pem /etc/eduroam.pem
sudo chown root:root /etc/eduroam.pem
sudo chmod go-rwx /etc/eduroam.pem

pushd /home/dss
sudo cp /etc/skel/.bashrc .bashrc
sudo cp /etc/skel/.bashrc .profile
sudo sed -i "1i export PYTHONPATH=~/grove-base" .profile
sudo sed -i "1i export PYTHONPATH=~/grove-base" .bashrc
sudo chown dss:dss .bashrc 
sudo chown dss:dss .profile

sudo cp /home/pi/grove-startup-scripts/getlatest.sh .
sudo chown dss:dss /home/dss/getlatest.sh
sudo -u dss bash ./getlatest.sh


sudo mkdir -p /home/dss/.ssh
sudo cp /home/pi/grove-startup-scripts/authorized_keys /home/dss/.ssh/
sudo chown dss:dss /home/dss/.ssh
sudo chown dss:dss /home/dss/.ssh/authorized_keys
sudo chmod 644 /home/dss/.ssh/authorized_keys
# fix dss password in case someone changed it
sudo grep -q dss /etc/shadow || echo 'dss:$y$j9T$KO7JYfq4trQCsxsxJ0oPC1$G9zo8sbrS4PVoLNMhaROoor3YB1f56V1dBz8OnGWeaB:19034::::::'|sudo tee -a /etc/shadow
popd

sudo /usr/bin/python /home/pi/grove-startup-scripts/checkFirmware.py

# remove old armhf version of avrdude and patch it ourselves
sudo dpkg -s avrdude:armhf
if [ $? -eq 0 ]; then 
    sudo apt-get remove -y avrdude:armhf 
fi

echo "Installing avrdude"
# add gpio conf for grovepi to avrdude
sudo cp /home/pi/grove-startup-scripts/avrdude /usr/bin/avrdude
sudo chmod a+x /usr/bin/avrdude
sudo cp /home/pi/grove-startup-scripts/avrdude.conf /usr/local/etc/avrdude.conf
sudo chown root:root /usr/local/etc/avrdude.conf
