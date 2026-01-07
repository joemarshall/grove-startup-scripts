##! /bin/bash
cd ~
sudo chown pi:pi -R .
# wait for network
while true
do
    wget -w3 -O/dev/null https://www.github.com  && break
    sleep 1
    wget -w3 -O/dev/null https://www.github.com  && break
    sleep 1
    wget -w3 -O/dev/null https://www.github.com  && break
    sleep 1
    wget -w3 -O/dev/null https://www.github.com  && break
    sleep 5
    wget -w3 -O/dev/null https://www.github.com  && break
    sleep 5
    wget -w3 -O/dev/null https://www.github.com  && break
    sleep 5
    wget -w3 -O/dev/null https://www.github.com  && break
    sleep 60
    sudo systemctl restart NetworkManager
    sleep 1
done

APT_ARGS="-y --no-upgrade"
# packages that really really need to be installed or else nothing will work
APT_FIRST_PACKAGES="git python3-pip curl"
# packages that we can update our way out of an install failure
APT_OTHER_PACKAGES="libatlas-base-dev screen libncurses5 libftdi1 python3-scipy"
# litert (successor to tflite) for running AI models
PIP_PACKAGES="ai-edge-litert"

while true
do
    if [ -f /boot/firmware/setup_dss_mac_address.sh ]; then
        sudo bash /boot/firmware/setup_dss_mac_address.sh
        sudo rm /boot/firmware/setup_dss_mac_address.sh
    fi

    # install github cli using webi
    curl -sS https://webi.sh/gh | sh; \
    source ~/.config/envman/PATH.env
    sudo apt-get update 
    sudo apt-get install $APT_ARGS $APT_FIRST_PACKAGES
    sudo apt-get install $APT_ARGS $APT_OTHER_PACKAGES
    sudo apt-get install -y avrdude
    # add gpio conf for grovepi to avrdude
    sudo cp /home/pi/grove-startup-scripts/avrdude.conf /etc/avrdude.conf
    sudo cp /home/pi/grove-startup-scripts/avrdude /usr/bin/avrdude
    sudo chown root:root /etc/avrdude.conf
    sudo pip3 install $PIP_PACKAGES --break-system-packages

    # if git is broken, remove apt-get lists and update again, otherwise we're done
    git --version && break 
    
    sudo rm /var/lib/apt/lists/*
 done
