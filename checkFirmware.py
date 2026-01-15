import sys
import grovelcd
import time
import os
from subprocess import call
import grovepi


def unexportGPIO(num):
    gpioFolder=f"/sys/class/gpio/gpio{num+512}"
    if os.path.exists(gpioFolder):
        with open('/sys/class/gpio/unexport','w') as f:
            f.write(f"{num+512}")

# clear up any weird state left by firmware flashing 
# and/or make sure GPIOs are in a good state for flashing again
def clearGPIO():
    # close grovepi bus
    grovepi.closeBus()
    # unexport gpios
    for c in range(8,12):
        unexportGPIO(c)
    with open('/sys/class/gpio/export','w') as f:
        f.write("520")
    with open('/sys/class/gpio/gpio520/direction','w') as f:
        f.write("out")
    with open('/sys/class/gpio/gpio520/value','w') as f:
        f.write("1")
    for c in range(8,12):
        unexportGPIO(c)

def setLCDText(txt):
    try:
        clearGPIO()
        import smbus2 as smbus
        grovelcd.bus.close()
        grovelcd.bus=None
        time.sleep(0.1)
        grovelcd.bus=smbus.SMBus(1)
        grovelcd.setText(txt)
    except IOError:
        print("Couldn't write to LCD:",txt)

def doUpdate():
    clearGPIO()
    retVal=call(["/usr/bin/avrdude","-c","linuxgpio","-p","m328p"])
    if retVal!=0:
    # # needs jumper between ISP and reset
    #     setLCDText("Jumper wire fromD4 to ISP reset")
    #     while grovepi.digitalRead(2)==0:
    #         time.sleep(0.01)
    #     while grovepi.digitalRead(2)==1:
    #         time.sleep(0.01)
        return
    firmwarePath=os.path.join(os.path.dirname(os.path.realpath(__file__)),"grove_pi_firmware.hex")
    print (firmwarePath)
    setLCDText("Try update firmware\n---------------")
    retVal=call(["/usr/bin/avrdude","-c","linuxgpio","-p","m328p","-U","lfuse:w:0xFF:m"])
    if retVal==0:
        setLCDText("Try update\n**----------")
        retVal=call(["/usr/bin/avrdude","-c","linuxgpio","-p","m328p","-U","hfuse:w:0xDA:m"])
    if retVal==0:
        setLCDText("Try update\n****--------")
        retVal=call(["/usr/bin/avrdude","-c","linuxgpio","-p","m328p","-U","efuse:w:0xFD:m"])
    if retVal==0:
        setLCDText("Try update\n******------")
        retVal=call(["/usr/bin/avrdude","-c","linuxgpio","-p","m328p","-U","flash:w:%s"%(firmwarePath)])
    if retVal==0:
        time.sleep(0.1)
        clearGPIO()
        time.sleep(0.3)
        newVer=grovepi.version()
        setLCDText("Update ok\n"+newVer)
        time.sleep(30)
        import showIP
    else:
       setLCDText("Update failed\nPress button")
    setLCDText("")

def update_if_needed():
    for _retries in range(10):
        try:
            # clear GPIO and reset grovepi
            clearGPIO()
            # important that this happens after we reset the grovepi board
            # or else we lose connection
            currentVersion= grovepi.version()
            if currentVersion!="1.4.0":
                if currentVersion != "-1,-1,-1":
                    # got a different version number, update
                    break
                # if we get here, retry in case the version check just failed for some reason
            else:
                print(f"Current firmware:{currentVersion}")
                return False
        except Exception as e:
            # retry on exception
            print("Couldn't check version:",e)
        time.sleep(1) # wait a second for firmware version

    # if we get here, firmware is out of date, we need to update
    #grovelcd.setRGB(128,128,128)
    #setLCDText("Old firmware")

    try:
        doUpdate()
        clearGPIO()
    except Exception as e:
        print(e)
        estr="FW:"+str(e)
        if len(estr)>32:
            estr=estr[0:32]            
#        setLCDText(estr)


update_if_needed()