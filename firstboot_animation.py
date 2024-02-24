import grovelcd
import time
import socket
import subprocess

try:
    grovelcd.setRGB(255,0,0)
    grovelcd.setText("First boot")
except OSError:
    print(".")
    time.sleep(0.5)

x=0

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        # doesn't even have to be reachable
        s.connect(('10.254.254.254', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = ''
    finally:
        s.close()    
    return IP

def has_wifi():
    try:
        subprocess.check_call("netstat -i |grep -c wlan0",shell=True)
        return True
    except subprocess.CalledProcessError:
        return False
        


curtext=""
wifi_here=has_wifi()

while True:
    try:
        ip=get_ip()
        x=x+1
        x=x%255
        grovelcd.setRGB(255-x,x,0)
        if wifi_here:
            text=f"First boot\n{ip}"
        else:
            text=f"First (no wifi)\n{ip}"
        if curtext!=text:
            curtext=text
            grovelcd.setText(curtext)
    except OSError:
        print(".")
        time.sleep(0.5)
    time.sleep(0.1)
