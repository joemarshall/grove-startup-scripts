#! /bin/bash

# enable i2c
sudo raspi-config nonint do_i2c 0

# show network status on lcd screen
/usr/bin/python3 /home/pi/grove-startup-scripts/showIP.py &


sudo /sbin/iw wlan0 set power_save off

NET=0

for i in {1..10}
do
    NET=1
    wget -w3 -O/dev/null https://www.github.com  && break
    NET=0
    sleep 1
done
if [ $NET = 0 ]; then exit 1; fi

# add dss user
sudo useradd dss -m -G i2c,audio,video,gpio,spi
sudo chpasswd dss:dss
sudo mkdir /home/dss
sudo adduser dss i2c
echo "export PYTHONPATH=~/grove-base" >> /home/dss/.bashrc

sudo apt-get update -y
sudo apt-get install -y /home/pi/grove-startup-scripts/avrdude_6.2-2_armhf.deb
sudo apt-get install -y screen
sudo apt-get install -y libncurses5
sudo apt-get install -y libftdi1
sudo apt-get install -y subversion
sudo apt-get install -y git
# make sure libatlas is installed so numpy works
sudo apt-get install -y --no-upgrade libatlas-base-dev

# this will stop firstrun being called
sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local

bash /home/pi/grove-startup-scripts/afterupdate.sh

# now reboot into full system
sudo reboot 


