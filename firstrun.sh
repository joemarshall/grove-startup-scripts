# show network status on screen
/usr/bin/python3 /home/pi/grove-startup-scripts/showIP.py &

# wait for network connection
while :
do 
    wget -O- https://www.github.com && break
done

sudo apt-get update -y

sudo apt-get install -y screen
sudo apt-get install -y libncurses5
sudo apt-get install -y libftdi1
sudo apt-get install -y subversion
sudo apt-get install -y git
sudo dpkg -i /home/pi/grove-startup-scripts/avrdude_6.2-2_armhf.deb

sudo /sbin/iw wlan0 set power_save off
# make sure libatlas is installed so numpy works
sudo apt-get install -y --no-upgrade libatlas-base-dev

# this will stop firstrun being called
sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local

# now reboot into full system
sudo reboot 

