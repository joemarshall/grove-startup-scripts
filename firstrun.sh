#! /bin/bash

# enable i2c
sudo raspi-config nonint do_i2c 0

# add dss user

if id "dss"; then
    echo "DSS user exists"
else
    sudo useradd dss -m -G i2c,audio,video,gpio,spi
    sudo chpasswd <<< "dss:dss"
    sudo mkdir /home/dss
    sudo adduser dss i2c
    sudo sed -i "1i export PYTHONPATH=~/grove-base" /home/dss/.profile
fi

# install our packages 
sudo bash /home/pi/grove-startup-scripts/install_packages.sh

sudo /sbin/iw wlan0 set power_save off

# this will stop firstrun being called
sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local
sudo chown -R pi.pi /home/pi/grove-startup-scripts

bash /home/pi/grove-startup-scripts/afterupdate.sh

# now reboot into full system
sudo reboot 


