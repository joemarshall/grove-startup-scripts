#! /bin/bash

## Emergency reset script

# restore backed up networkmanager files if something gets lost (i.e. sd card corrupts)
for backup_file in /etc/NetworkManagerBackup/*.nmconnection; do
	if [ -s "$backup_file" ]; then
		filename=$(basename "$backup_file")
		target_file="/etc/NetworkManager/system-connections/$filename"
		if [ ! -s "$target_file" ] || [ $(stat -f%z "$target_file" 2>/dev/null || stat -c%s "$target_file") -lt 100 ]; then
			sudo cp "$backup_file" "$target_file"
			sudo chmod 600 "$target_file"
		fi
	fi
done


# if update script exists and is >0 length then exit and let it do its thing
test -s /home/pi/grove-startup-scripts/checkUpdate.sh && exit

cd /tmp
rm -rf grove-startup-scripts
git clone https://github.com/joemarshall/grove-startup-scripts.git
if [ $? -eq 0 ]
then
    cd /home/pi
    chown pi:pi -R /home/pi/grove-startup-scripts
    rm -rf /home/pi/grove-startup-scripts
    mv /tmp/grove-startup-scripts /home/pi/grove-startup-scripts
fi
