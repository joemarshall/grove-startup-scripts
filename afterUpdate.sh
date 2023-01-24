# 
# put commands to run after git update here - don't modify checkUpdate.sh or
# else you need an extra reboot
echo "Git changed - copying code across"
sudo chown pi.pi -R /home/pi/g54mrt-useful-code
if [ -s "/home/pi/g54mrt-useful-code/startup-scripts/checkUpdate.sh" ] 
then
    sudo cp /home/pi/grove-startup-scripts/rc.local /etc/rc.local
fi
cd /home/dss
sudo cp /home/pi/grove-startup-scripts/getlatest.sh .
sudo chown dss.dss /home/dss/getlatest.sh
sudo -u dss bash ./getlatest.sh

sudo mkdir /home/dss/.ssh
sudo cp /home/pi/grove-startup-scripts/authorized_keys /home/dss/.ssh/
sudo chown dss.dss /home/dss/.ssh
sudo chown dss.dss /home/dss/.ssh/authorized_keys
sudo chmod 644 /home/dss/.ssh/authorized_keys
# fix dss password in case someone changed it
sudo grep -q dss /etc/shadow || echo 'dss:$y$j9T$KO7JYfq4trQCsxsxJ0oPC1$G9zo8sbrS4PVoLNMhaROoor3YB1f56V1dBz8OnGWeaB:19034::::::'|sudo tee -a /etc/shadow
cd /home/pi

sudo /usr/bin/python /home/pi/checkFirmware.py
