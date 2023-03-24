import grovelcd
import time
grovelcd.setRGB(255,0,0)
grovelcd.setText("First boot")
x=0
while True:
    x=x+1
    x=x%255
    grovelcd.setRGB(255-x,x,0)
    time.sleep(0.1)