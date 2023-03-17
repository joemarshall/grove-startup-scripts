#! /bin/bash


# enable i2c
sudo raspi-config nonint do_i2c 0

# add dss user
sudo useradd dss -m -G i2c,audio,video,gpio,spi
sudo chpasswd <<< "dss:dss"
sudo mkdir /home/dss
sudo adduser dss i2c
sudo sed -i "1i export PYTHONPATH=~/grove-base" .profile

sudo bash /home/pi/grove-startup-scripts/install_packages.sh

sudo /sbin/iw wlan0 set power_save off
# show network status on lcd screen
/usr/bin/python3 /home/pi/grove-startup-scripts/showIP.py &


# this will stop firstrun being called
sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local

bash /home/pi/grove-startup-scripts/afterupdate.sh

# now reboot into full system
sudo reboot 


