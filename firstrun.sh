#! /bin/bash

# enable i2c
sudo raspi-config nonint do_i2c 0
python /home/pi/grove-startup-scripts/firstboot_animation.py &
# add dss user

if id "dss"; then
    echo "DSS user exists"
else
    sudo useradd dss -m -G i2c,audio,video,gpio,spi
    sudo chpasswd <<< "dss:dss"
    sudo mkdir -p /home/dss
    sudo adduser dss i2c
    sudo sed -i "1i export PYTHONPATH=~/grove-base" /home/dss/.profile
fi

# install our packages 
sudo bash /home/pi/grove-startup-scripts/install_packages.sh


# this will stop firstrun being called
sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local
sudo chown -R pi:pi /home/pi/grove-startup-scripts

bash /home/pi/grove-startup-scripts/afterUpdate.sh
sudo /sbin/iw dev wlan0 set power_save off || true

# now reboot into full system
sudo reboot 


