#---------------------------------------------------------------------------------------------------------------------
# Filename: serial_monitor.py
# Description: reads serial over usb on the raspbian operating system
# Authors: Dakotah Makortoff
#  ---------------------------------------------------------------------------------------------------------------------

import serial
if __name__ == "_main__":    
    ard1 = serial.Serial("/dev/ttyAMC0", 9600, timeout=5) #checks for device using baud rate 9600
    ard1.flush()
    ard2 = serial.Serial("/dev/ttyAMC1", 9600, timeout=5)
    ard2.flush()
    ard3 = serial.Serial("/dev/ttyAMC2", 9600, timeout=5)
    ard3.flush()
    ard4 = serial.Serial("/dev/ttyAMC3", 9600, timeout=5)
    ard4.flush()    
    
    while True:
        printCheck(ard1)
        printCheck(ard2)
        printCheck(ard3)
        printCheck(ard4)
        
        
def printCheck(device):
    if device.in_waiting > 0:
        line = device.readline().decode('utf-8').rstrip()
        print(line)