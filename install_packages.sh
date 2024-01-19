##! /bin/bash

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

APT_ARGS="-y --no-upgrade"
# packages that really really need to be installed or else nothing will work
APT_FIRST_PACKAGES="git python3-pip"
# packages that we can update our way out of an install failure
APT_OTHER_PACKAGES="libatlas-base-dev python3-tflite-runtime screen libncurses5 libftdi1 subversion gh"
DEB_FORCE_PACKAGE="/home/pi/grove-startup-scripts/avrdude_6.2-2_armhf.deb"

PIP_PACKAGES="numpy"

while true
do
    # add google deb source for tensorflow and github source for github cli
    echo "deb [signed-by=/usr/share/keyrings/coral-edgetpu-archive-keyring.gpg] https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/coral-edgetpu-archive-keyring.gpg >/dev/null
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo apt-get update 
    sudo apt-get install $APT_ARGS $APT_FIRST_PACKAGES
    sudo apt-get install $APT_ARGS $APT_OTHER_PACKAGES
    # install avrdude first through apt-get, then force the deb file
    sudo apt-get install $APT_ARGS /home/pi/grove-startup-scripts/avrdude_6.2-2_armhf.deb
    sudo dpkg --force-all -i /home/pi/grove-startup-scripts/avrdude_6.2-2_armhf.deb
    sudo pip3 install $PIP_PACKAGES --break-system-packages

    # if git is broken, remove apt-get lists and update again, otherwise we're done
    git --version && break 
    
    sudo rm /var/lib/apt/lists/*
 done
