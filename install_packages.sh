#! /bin/bash

NET=0

# wait for network
while true
do
    NET=1
    wget -w3 -O/dev/null https://www.github.com  && break
    sudo iwlist wlan0 scan > /dev/null
    NET=0
    sleep 1
done

while true
do
    sudo apt-get update -y
    sudo apt-get install -y /home/pi/grove-startup-scripts/avrdude_6.2-2_armhf.deb
    sudo apt-get install -y screen
    sudo apt-get install -y libncurses5
    sudo apt-get install -y libftdi1
    sudo apt-get install -y subversion
    # make sure libatlas is installed so numpy works
    sudo apt-get install -y --no-upgrade libatlas-base-dev
    # install tensorflow lite 2.11.0
    sudo python3 -m pip install tflite-runtime=2.11.0
    sudo apt-get install -y git

    # if git is broken, remove apt-get lists and update again, otherwise we're done
    git --version && break 
    
    sudo rm /var/lib/apt/lists/*
 done
