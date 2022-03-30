#---------------------------------------------------------------------------------------------------------------------
# Filename: serial_monitor.py
# Description: reads serial over usb on the raspbian operating system
# Authors: Dakotah M
#  ---------------------------------------------------------------------------------------------------------------------

import requests
import time
import serial

class ardsens: #holds status of object
  def __init__(self):
    self.active = False
    self.time = 0
def printCheck(device):
    if device.in_waiting > 0:
        line = device.readline().decode('utf-8').rstrip()
        return line

#sensors of arduino 1-4
A1S1 = ardsens()
A1S2 = ardsens()
A1S3 = ardsens()
A1S4 = ardsens()

A2S1 = ardsens()
A2S2 = ardsens()
A2S3 = ardsens()
A2S4 = ardsens()

A3S1 = ardsens()
A3S2 = ardsens()
A3S3 = ardsens()
A3S4 = ardsens()

A4S1 = ardsens()
A4S2 = ardsens()
A4S3 = ardsens()
A4S4 = ardsens()

sensList = {A1S1, A1S2, A1S3, A1S4, A2S1, A2S2, A2S3, A2S4, A3S1, A3S2, A3S3, A3S3, A4S1, A4S2, A3S3, A4S4}

if __name__ == "__main__":
    try:
        ard1 = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
        ard1.flush()

    except:
        print("Ard1 Connection Failed!")

    try:
        ard2 = serial.Serial('/dev/ttyACM1', 9600, timeout=1)
        ard2.flush()

    except:
        print("Ard2 Connection Failed!")

    try:
        ard3 = serial.Serial('/dev/ttyACM2', 9600, timeout=1)
        ard3.flush()

    except:
        print("Ard3 Connection Failed!")

    try:
        ard4 = serial.Serial('/dev/ttyACM3', 9600, timeout=1)
        ard4.flush()

    except:
        print("Ard4 Connection Failed!")

    while True:
        try:
            HWID1 = printCheck(ard1)
            globals()[HWID1].active = True
            globals()[HWID1].time = int(round(time.time()))
            print(globals()[HWID1].active)
        except:
            print("ard1 check failed! please check device connection!")

        try:
            HWID2 = printCheck(ard2)
            globals()[HWID2].active = True
            globals()[HWID2].time = int(round(time.time()))
            print(globals()[HWID2].active)
        except:
            print("ard2 check failed! please check device connection!")

        try:
            HWID3 = printCheck(ard3)
            globals()[HWID3].active = True
            globals()[HWID3].time = int(round(time.time()))
            print(globals()[HWID3].active)
        except:
            print("ard3 check failed! please check device connection!")

        try:
            HWID4 = printCheck(ard4)
            globals()[HWID4].active = True
            globals()[HWID4].time = int(round(time.time()))
            print(globals()[HWID4].active)
        except:
            print("ard4 check failed! please check device connection!")

        for i in sensList:
            currTime = int(round(time.time()))
            if i.time <= (currTime-60) and i.active == True:
                i.active = False
                print(i.active)