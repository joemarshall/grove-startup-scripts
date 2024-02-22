# 
# put commands to run after git update here - don't modify checkUpdate.sh or
# else you need an extra reboot

# remove old armhf version of avrdude and patch it ourselves
sudo dpkg -s avrdude:armhf
if [ $? -eq 0 ]; then 
    sudo apt-get remove -y avrdude:armhf 
    sudo apt-get -y install avrdude
    # add gpio conf for grovepi to avrdude
    sudo cp avrdude.conf /etc/avrdude.conf
    sudo chown root:root /etc/avrdude.conf
fi


echo "Git changed - copying code across"
sudo chown pi.pi -R /home/pi/grove-startup-scripts
if [ -s "/home/pi/g54mrt-useful-code/startup-scripts/checkUpdate.sh" ] 
then
    sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local
fi
pushd /home/dss
sudo cp /etc/skel/.bashrc .bashrc
sudo cp /etc/skel/.bashrc .profile
sudo sed -i "1i export PYTHONPATH=~/grove-base" .profile
sudo sed -i "1i export PYTHONPATH=~/grove-base" .bashrc
sudo chown dss.dss .bashrc 
sudo chown dss.dss .profile

sudo cp /home/pi/grove-startup-scripts/getlatest.sh .
sudo chown dss.dss /home/dss/getlatest.sh
sudo -u dss bash ./getlatest.sh


sudo mkdir -p /home/dss/.ssh
sudo cp /home/pi/grove-startup-scripts/authorized_keys /home/dss/.ssh/
sudo chown dss.dss /home/dss/.ssh
sudo chown dss.dss /home/dss/.ssh/authorized_keys
sudo chmod 644 /home/dss/.ssh/authorized_keys
# fix dss password in case someone changed it
sudo grep -q dss /etc/shadow || echo 'dss:$y$j9T$KO7JYfq4trQCsxsxJ0oPC1$G9zo8sbrS4PVoLNMhaROoor3YB1f56V1dBz8OnGWeaB:19034::::::'|sudo tee -a /etc/shadow
popd

sudo /usr/bin/python /home/pi/grove-startup-scripts/checkFirmware.py
bash /home/pi/grove-startup-scripts/install_packages.sh
