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
            #Grab Serial readout from first device
            HWID1 = printCheck(ard1)
            #If Hardware ID is fed instead of no response
            if HWID1 != None:
                #check if sensor is already set to recently active
                if globals()[HWID1].active != True:
                    #set sensor to active
                    globals()[HWID1].active = True
                    #update unix time last active
                    globals()[HWID1].time = int(round(time.time()))
                    #generate API URL based on sensor
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID1)
                    P1 = requests.put(APICall)
                    print(P1)
                    print(P1.content)
                else:
                    #if sensor is already active, update time
                    globals()[HWID1].time = int(round(time.time()))
        except:
            print("ARD1 Communication Failed!")

        try:
            HWID2 = printCheck(ard2)
            if HWID2 != None:
                if globals()[HWID2].active != True:
                    globals()[HWID2].active = True
                    globals()[HWID2].time = int(round(time.time()))
                    print(globals()[HWID2].active)
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID2)
                    P2 = requests.put(APICall)
                    print(P2)
                    print(P2.content)
                else:
                    globals()[HWID2].time = int(round(time.time()))
        except:
            print("ARD2 Communication Failed!")

        try:
            HWID3 = printCheck(ard3)
            if HWID3 != None:
                if globals()[HWID3].active != True:
                    globals()[HWID3].active = True
                    globals()[HWID3].time = int(round(time.time()))
                    print(globals()[HWID3].active)
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID3)
                    P3 = requests.put(APICall)
                    print(P3)
                    print(P3.content)
                else:
                    globals()[HWID3].time = int(round(time.time()))
        except:
            print("ARD1 Communication Failed!")

        try:
            HWID4 = printCheck(ard4)
            if HWID4 != None:
                if globals()[HWID4].active != True:
                    globals()[HWID4].active = True
                    globals()[HWID4].time = int(round(time.time()))
                    print(globals()[HWID4].active)
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID4)
                    P4 = requests.put(APICall)
                    print(P4)
                    print(P4.content)
                else:
                    globals()[HWID4].time = int(round(time.time()))

        except:
            print("ARD4 Communication Failed!")

        

        for i in sensList:
            currTime = int(round(time.time()))
            #if sensor is active and it has been over a minute since last trigger
            if i.time <= (currTime-60) and i.active == True:
                i.active = False
                print(i.active)
                APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(i.name)
                r = requests.put(APICall)
                print(r)
                print(r.content)
