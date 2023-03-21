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

while true
do
    # add google deb source for tensorflow 
    echo "deb [signed-by=/usr/share/keyrings/coral-edgetpu-archive-keyring.gpg] https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/coral-edgetpu-archive-keyring.gpg >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y git
    sudo apt install libatlas-base-dev python3-tflite-runtime
    sudo apt-get install -y /home/pi/grove-startup-scripts/avrdude_6.2-2_armhf.deb
    sudo apt-get install -y screen
    sudo apt-get install -y libncurses5
    sudo apt-get install -y libftdi1
    sudo apt-get install -y subversion
    sudo apt-get install -y python3-pip
    sudo pip3 install numpy
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y

    # if git is broken, remove apt-get lists and update again, otherwise we're done
    git --version && break 
    
    sudo rm /var/lib/apt/lists/*
 done
