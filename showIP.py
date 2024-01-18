#!/usr/bin/python3

import grovelcd
import time
import subprocess
import re
import grovepi
import os.path
import sys

only_address = False
if len(sys.argv) > 1 and sys.argv[1] == '--init':
    only_address = True
if only_address == False:
    badFirmware = True
    try:
        version = grovepi.version()
        version = version.replace(".", "")
        badFirmware = False
    except:
        version = "???"
    try:
        burnDate = time.strftime("%d%m", time.gmtime(
            os.path.getmtime('/boot/firmware/burning-date.txt')))
    except:
        burnDate = "0000"
    imgDate = ""
    try:
        with open('/boot/image-date.txt') as im:
            imgDate = im.read()
    except IOError:
        imgDate = ""

    try:
        gitVer = subprocess.check_output(
            "sudo git --git-dir=/home/dss/grove-base/.git log -1 --format=\"%at\"  | xargs -I{} date -d @{} +%d%m%y", shell=True)
        gitVer = gitVer.decode()
        print(gitVer)
        grovelcd.setText("MRT%s %s\nIMG FW%s (%s)" % (
            imgDate[0:4]+imgDate[6:8], gitVer[0:6], version, burnDate))
    except Exception as e:
        gitVer = ""

cyclePos = 1

curText = ""

time.sleep(5)


def formatAddr(addr, type):
    retVal = addr
    if len(retVal) < 14:
        retVal += " "*(14-len(retVal))
    if len(retVal) == 14:
        retVal += ":"
    if len(retVal) < 16:
        retVal += type
    return retVal[0:16]


countLeft = 300
while countLeft == None or countLeft > 0:
    try:
        if only_address:
            grovelcd.setRGB(128, 128, 128)
        else:
            grovelcd.setRGB(128, 128, 128)
        result = subprocess.check_output(['ip', 'route'])
        result = result.decode()
        curPos = 0
        ethAddr = "No ethernet"
        wlanAddr = "No wireless"
        for line in result.split('\n'):
            values = re.split('\s+', line)
            if len(values) > 2:
                if countLeft == None:
                    countLeft = 30
                if values[0] == 'default':
                    pass
    #        grovelcd.setText("%s\ngateway"%values[2])
                else:
                    if values[2].find("eth") != -1:
                        ethAddr = formatAddr(values[8], "e")
                    if values[2].find("wlan") != -1:
                        wlanAddr = formatAddr(values[8], "w")
        adapterList = subprocess.check_output(['ifconfig'])
        if adapterList.find(b"wlan0") == -1 and countLeft<280:
            wlanAddr = "Plug USB WIFI in"
        newText = ethAddr+"\n"+wlanAddr
        if newText != curText:
            curText = newText
            grovelcd.setText(newText)
    except:
        pass
    time.sleep(2.0)
    if countLeft != None:
        countLeft -= 2
