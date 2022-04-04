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
        print(line)
        return line

#sensors of arduino 1-10
sensList={}
for A in range(1,11):
    for S in range(1,21):
        currDev = "A" + str(A) + "S" +str(S)
        sensList[currDev] = ardsens()


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
                if sensList[HWID1].active != True:
                    #set sensor to active
                    sensList[HWID1].active = True
                    #update unix time last active
                    sensList[HWID1].time = int(round(time.time()))
                    #generate API URL based on sensor
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID1)
                    P1 = requests.put(APICall)
                    print(P1)
                    print(P1.content)
                else:
                    #if sensor is already active, update time
                    sensList[HWID1].time = int(round(time.time()))
        except:
            print("ARD1 Communication Failed!")

        try:
            HWID2 = printCheck(ard2)
            if HWID2 != None:
                if sensList[HWID2].active != True:
                    sensList[HWID2].active = True
                    sensList[HWID2].time = int(round(time.time()))
                    print(sensList[HWID2].active)
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID2)
                    P2 = requests.put(APICall)
                    print(P2)
                    print(P2.content)
                else:
                    sensList[HWID2].time = int(round(time.time()))
        except:
            print("ARD2 Communication Failed!")

        try:
            HWID3 = printCheck(ard3)
            if HWID3 != None:
                if sensList[HWID3].active != True:
                    sensList[HWID3].active = True
                    sensList[HWID3].time = int(round(time.time()))
                    print(sensList[HWID3].active)
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID3)
                    P3 = requests.put(APICall)
                    print(P3)
                    print(P3.content)
                else:
                    sensList[HWID3].time = int(round(time.time()))
        except:
            print("ARD3 Communication Failed!")

        try:
            HWID4 = printCheck(ard4)
            if HWID4 != None:
                if sensList[HWID4].active != True:
                    sensList[HWID4].active = True
                    sensList[HWID4].time = int(round(time.time()))
                    print(sensList[HWID4].active)
                    APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(HWID4)
                    P4 = requests.put(APICall)
                    print(P4)
                    print(P4.content)
                else:
                    sensList[HWID4].time = int(round(time.time()))

        except:
            print("ARD4 Communication Failed!")

        

        for i in sensList:
            currTime = int(round(time.time()))
            #if sensor is active and it has been over a minute since last trigger
            if sensList[i].time <= (currTime-60) and sensList[i].active == True:
                sensList[i].active = False
                print(sensList[i].active)
                APICall = "https://pacific-oasis-59208.herokuapp.com/api/v1/stall-status/"+str(i)
                r = requests.put(APICall)
                print(r)
                print(r.content)      
