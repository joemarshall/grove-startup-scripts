#!/bin/bash
cd /home/pi/grove-startup-scripts

sudo mkdir /home/dss/.ssh
sudo cp /home/pi/grove-startup-scripts/authorized_keys /home/dss/.ssh/
sudo chown dss.dss /home/dss/.ssh 
sudo chmod 644 /home/dss/.ssh/authorized_keys

# wait until github is connectable
until (/usr/bin/wget -O/dev/null https://www.github.com)
do
  echo "waiting for github"
  sleep 1
done
# pull changes from git in dss user if needed
pushd /home/dss
sudo cp /home/pi/grove-startup-scripts/getlatest.sh .
sudo chown dss.dss /home/dss/getlatest.sh
sudo -u dss bash ./getlatest.sh
popd

set -o pipefail
#pull any changes from git
if git pull | grep -q "up-to-date"; then
  echo "no changes"
else
    if [ $? -ne 0 ]
    then
        # error doing git pull - re-copy repository
        cd /tmp
        rm -rf grove-startup-scripts
        git clone https://github.com/joemarshall/grove-startup-scripts.git
        if [ $? -eq 0 ]
        then
          cd ~
          rm -rf grove-startup-scripts
          mv /tmp/grove-startup-scripts ./grove-startup-scripts
        fi
    fi
# run things that need to be run after this git update
/bin/bash /home/pi/grove-startup-scripts/afterUpdate.sh
fi

sudo chown pi.pi -R /home/pi/grove-startup-scripts
#sudo systemctl disable serial-getty@ttyAMA0.service
sudo /usr/bin/python /home/pi/grove-startup-scripts/checkFirmware.py
