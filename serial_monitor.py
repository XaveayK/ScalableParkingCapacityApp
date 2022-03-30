#---------------------------------------------------------------------------------------------------------------------
# Filename: serial_monitor.py
# Description: reads serial over usb on the raspbian operating system
# Authors: Dakotah M
#  ---------------------------------------------------------------------------------------------------------------------

import requests
import time
import serial

class ardsens: #holds status of object
  def __init__(self, name):
    self.name = name
    self.active = False
    self.time = 0
def printCheck(device):
    if device.in_waiting > 0:
        line = device.readline().decode('utf-8').rstrip()
        print(line)
        return line

#sensors of arduino 1-4
A1S1 = ardsens("A1S1")
A1S2 = ardsens("A1S2")
A1S3 = ardsens("A1S3")
A1S4 = ardsens("A1S4")

A2S1 = ardsens("A2S1")
A2S2 = ardsens("A2S2")
A2S3 = ardsens("A2S3")
A2S4 = ardsens("A2S4")

A3S1 = ardsens("A3S1")
A3S2 = ardsens("A3S2")
A3S3 = ardsens("A3S3")
A3S4 = ardsens("A3S4")

A4S1 = ardsens("A4S1")
A4S2 = ardsens("A4S2")
A4S3 = ardsens("A4S3")
A4S4 = ardsens("A4S4")

sensList = {A1S1, A1S2, A1S3, A1S4, A2S1, A2S2, A2S3, A2S4, A3S1, A3S2, A3S3, A3S3, A4S1, A4S2, A3S3, A4S4}

if __name__ == "__main__":
    try:
        ard1 = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
        ard1.flush()

    except:
        print("Ard1 Connection Failed!")

    while True:
        try:
            HWID1 = printCheck(ard1)
            if HWID1 != None:
                if globals()[HWID1].active != True:
                    globals()[HWID1].active = True
                    globals()[HWID1].time = int(round(time.time()))
                    print(globals()[HWID1].active)
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID1)
                    P1 = requests.put(APICall)
                    print(P1)
                    print(P1.content)
                else:
                    globals()[HWID1].time = int(round(time.time()))

        except:
            print("ARD1 Communication Failed!")

        

        for i in sensList:
            currTime = int(round(time.time()))
            if i.time <= (currTime-60) and i.active == True:
                i.active = False
                print(i.active)
                APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(i.name)
                r = requests.put(APICall)
                print(r)
                print(r.content)
