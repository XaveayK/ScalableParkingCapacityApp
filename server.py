#====================================================================================================
# File Author: Xavier Kidston, Alex Creencia
# File name: server.py
# Description: File that hosts the webserver AND the API implementation. This file will sort out API
#              Routes based on the URI. **Some paths will require JSON parsing.
#=====================================================================================================

# Add in images, lat/long instead of address, no need to change anything in API, just need to store. 
# Build parking lot dynamically entirely, doesn't matter much its size, just reasonable. 
from asyncio.constants import LOG_THRESHOLD_FOR_CONNLOST_WRITES
import asyncio
from cProfile import run
from sqlite3 import Cursor
import flask
import pyodbc
import apiStructs
from flask import request
from PIL import Image, ImageDraw


# Images to create the parking lot map are loaded in the following 2 lines, change the path to where the file is located on your pc
carIcon = Image.open("G:\School Files\Capstone\\testStall.png")
emptyStall = Image.open("G:\School Files\Capstone\\emptyTestStall.png")

# dicates the size of the "thumbnails" 
size = 1000, 900

# formatting the icons above to fit the map created from them
carIcon.thumbnail(size)
emptyStall.thumbnail(size)
leftIcon = carIcon.rotate(90, expand=True)
downIcon = carIcon.rotate(180, expand=True)
rightIcon = carIcon.rotate(270, expand=True)
leftEmptyStall = emptyStall.rotate(90, expand=True)
downEmptyStall = emptyStall.rotate(180, expand=True)
rightEmptyStall = emptyStall.rotate(270, expand=True)


from credentials import driver, server, password as pw, database as db, username as un # This is your own personal credentials file in the same directory.

connection = pyodbc.connect('DRIVER='+driver+';SERVER=tcp:'+server+';PORT=1433;DATABASE='+db+';UID='+un+';PWD='+ pw)
cursor = connection.cursor()

app = flask.Flask(__name__)

# Function: imgPaste
# Purpose: pastes an icon defined globally into the backgroundImg, based on orientation, type at position xValue, yValue
# Params:  orientation   - The orientation of the parking stall (up, right, left, down abbreviated to "U", "R", "L", "D")
#          type          - The type of stall, either empty or filled (based on isAvailable member in database) = True or False
#          backgroundImg - The background image we are pasting the icon's onto (the canvas if you will)
#          xValue        - The xValue where the icon is pasted
#          yValue        - The yValue where the icon is pasted 
# Returns: nothing
async def imgPaste(orientation, type, backgroundImg, xValue, yValue):
    if type:
        match orientation:
            # switch statement for drawing when there is NO car in the stall/stall is available
            case "L":
                backgroundImg.paste(leftEmptyStall, (xValue, yValue), leftEmptyStall)
            case "R":
                backgroundImg.paste(rightEmptyStall, (xValue, yValue), rightEmptyStall)
            case "D":
                backgroundImg.paste(downEmptyStall, (xValue, yValue), downEmptyStall)
            case _:
                backgroundImg.paste(emptyStall, (xValue, yValue), emptyStall)
    else:
        # switch statement when there IS a car in the stall/stall is taken
        match orientation:
            case "L":
                backgroundImg.paste(leftIcon, (xValue, yValue), leftIcon)
            case "R":
                backgroundImg.paste(rightIcon, (xValue, yValue), rightIcon)
            case "D":
                backgroundImg.paste(downIcon, (xValue, yValue), downIcon)
            case _:
                backgroundImg.paste(carIcon, (xValue, yValue), carIcon)
    return


# Helper function to assist with all stored procedures calls, allowing for easier future maintenance.
# Params: storedProcedure - The stored procedure string
#         params          - The parameters to pass to the stored procedure
#         functionCall    - either none, or the cursor method to call (i.e cursor.fetchone)
# Returns: result - either None or the result of the method call on cursor.
async def storedProcedureHelper(storedProcedure, params, functionCall):
    result = None
    cursor.execute(storedProcedure, params)
    if functionCall != None:
        result = functionCall()
    cursor.commit()
    return result

# Gets stall information for a single lot
# Each stall entry contained in row has the following attributes:
# row.HardwareID = hardware ID related to the stall (string datatype)
# row.isAvailable = value that tells whether a vehicle is in the stall or not (boolean data type)
# row.ParkingLotName = contains the name of the parking lot the stall is attached to (string datatype)
# row.Position = position coordinates along with orientation of the stall (x,y, Orientation)
@app.route("/api/v1/parking-lot/<string:lotName>", methods=['GET'])
async def getLotInfo(lotName):
    # check if parking lot exists before grabbing all records pertaining to the parking lot name
    count = await storedProcedureHelper("EXEC [dbo].[parkingLotExists] @parkingLotName = ?", lotName, cursor.fetchone)
    #count = await parkingLotExists(lotName)
    if count[0] <= 0:
        return "Parking Lot does not exist in database.", 400
    try:
        rows = await storedProcedureHelper("EXEC [dbo].[GetParkingLotInfo] @parkingLotName = ?", lotName, cursor.fetchall) # Works
        # return rows in John's desired JSON format here
        # keeps track of maximum x and y values to crop the larger background to a reasonable size
        max_x, max_y = 0, 0
        # background image that our Icon's get "pasted" into
        backgroundImg = Image.new( mode = "RGB", size = (9999, 9999), color = (112, 128, 144))

        for row in rows:
            stallOrientation = row.Position.split(",")[2]
            worldPositionX, worldPositionY = int(row.Position.split(",")[0]), int(row.Position.split(",")[1])
            
            if max_x < worldPositionX:
                max_x = worldPositionX 

            if max_y < worldPositionY:
                max_y = worldPositionY

            await imgPaste(stallOrientation, row.isAvailable, backgroundImg, worldPositionX, worldPositionY)
        finalImg = backgroundImg.crop((0, 0, max_x + carIcon.size[0], max_y + carIcon.size[1]))
        finalImg.show()
        rows = await storedProcedureHelper("EXEC [dbo].[GetParkingLotInfo] @parkingLotName = ?", lotName, cursor.fetchall) # Works
        # return rows in John's desired JSON format here
        for row in rows:
            print(row)
        return flask.Response(status=200)
    except:
        return "Error encountered while attemping to access the database.", 500

#Gets the information for a landmark, all lots connected to it
@app.route("/api/v1/landmark/<string:placeName>", methods=['GET'])
async def getPlaceInfo(placeName):
    count = await storedProcedureHelper("Exec [dbo].[landmarkExists] @landmarkName = ?", placeName, cursor.fetchone)
    if count[0] <= 0:
        return "landmark name does not exist ", 400
    try:
        rows = await storedProcedureHelper("EXEC [dbo].[getLandmarkInfo] @landmarkName = ?", placeName, cursor.fetchall)
        # return the rows in John's desired JSON format here
        if rows:
            for row in rows:
                print(row)
        else:
            print("nothing here")
        return flask.Response(status=200)
    except:
        return "Error encountered while attempting to access the database", 500

# Hardware API ROUTE: 
# Update Parking Stall
@app.route("/api/v1/stall-status/<string:stallID>", methods=['PUT'])
async def updateStallInfo(stallID):
    try:
        await storedProcedureHelper("EXEC [dbo].[updateStallInfo] @stallID = ?", stallID, None)
        return flask.Response(status=200)
    except:
        return "ERROR while attempting to access database." , 500


#Adds a parking lot (Does not require placeName)
@app.route("/api/v1/newLot/<string:lotName>", methods=['POST'])
async def newParkingLot(lotName):
    count = await storedProcedureHelper("EXEC [dbo].[parkingLotExists] @parkingLotName = ?", lotName, cursor.fetchone)
    if count[0] > 0:
        return "parking lot already exists", 400
    try:     
        requestData = request.json
        if requestData is not None:
            address = requestData["address"]
            await storedProcedureHelper("Exec [dbo].[AddParkingLot] @parkingLotName = ?, @address = ?", (lotName, address), None)
        else:
            await storedProcedureHelper("Exec [dbo].[AddParkingLot] @parkingLotName = ?", lotName, None)

        return flask.Response(status=200)
    except:
        # Failed somewhere accessing the database
        return "There was an error accessing the database", 500

#Adds a parking lot. 
@app.route("/api/v1/newLot/<string:placeName>/<string:lotName>", methods=['POST'])
async def newParkingLotWithLandmark(placeName, lotName):
    #exists = parkingLotExists(lotName)
    exists = await storedProcedureHelper("EXEC [dbo].[parkingLotExists] @parkingLotName = ?", lotName, cursor.fetchone)
    count = await storedProcedureHelper("EXEC [dbo].[landmarkExists] @landmarkName = ?", placeName, cursor.fetchone)
    #count = landmarkExists(placeName)
    if count[0] < 0:
        return "Landmark linked to the parking lot does not exist", 400
    if exists[0] > 0:
        return "parking lot already exists", 400
    try:
        requestData = request.json
        if requestData is not None:
            # If the json data does exist, then this means client is sending the address info 
            await storedProcedureHelper("Exec [dbo].[AddParkingLotWithLandmark] @landmarkName = ?, @parkingLotName = ?, @address = ?",
            (placeName, lotName, requestData["address"]), None)
        else:
            await storedProcedureHelper("Exec [dbo].[AddParkingLotWithLandmark] @landmarkName = ?, @parkingLotName = ?",
            (placeName, lotName), None)
        return flask.Response(status=200)
    except:
        return "Error encountered while accessing the Database", 500
        
#Adds a new landmark, with the landmark name being the placeName obtained from URI, and request being parsed from JSON 
@app.route("/api/v1/newLandmark/<string:placeName>", methods=['POST'])
async def newLandMark(placeName):

    # checking if landmark already exists
    count = await storedProcedureHelper("EXEC [dbo].[landmarkExists] @landmarkName = ?", placeName, cursor.fetchone)
    if count[0] > 0:
        return "Landmark already exists", 400

    try:
        requestData = request.json                                     # we check if json body data came with the API request: e.g. { "address:" "104th street"}
        if requestData is not None:                                    # if it did, submit it to stored procedure
            await storedProcedureHelper("Exec [dbo].[AddLandmark] @landmarkName = ?, @address = ?", 
            (placeName, requestData["address"]),
            None)
        else:
            await storedProcedureHelper("Exec [dbo].[AddLandmark] @landmarkName = ?", 
            (placeName), 
            None)
        return flask.Response(status=200)  
    except:
        return "Error encountered while attempting to access Database", 500
    

#Removes a landmark. Does NOT remove the associated parking lot, since a parking lot can exist without a landmark (unmarked parking lots)
@app.route("/api/v1/removeLandMark/<string:placeName>", methods=['DELETE'])
async def remLandMark(placeName):

    # check if landmark exists before attempting to delete
    count = await storedProcedureHelper("EXEC [dbo].[landmarkExists] @landmarkName = ?", placeName, cursor.fetchone)
    if count[0] <= 0:
        return "Landmark does not exist", 400
    # if it exists, attempt to delete from database
    try:
        await storedProcedureHelper("Exec [dbo].[RemoveLandmark] @landmark = ?", placeName, None)
        return flask.Response(status=200)
    except:
        return "Error encountered while attempting to Delete record from database", 500

#Removes a parking lot and its stalls
@app.route("/api/v1/removeParkingLot/<string:lotName>")
async def remParkingLot(lotName):
    
    # verify if parking lot exists before attempting to delete it
    count = await storedProcedureHelper("EXEC [dbo].[parkingLotExists] @parkingLotName = ?", lotName, cursor.fetchone)
    if count[0] <= 0:
        return "Parking Lot does not exist in database.", 400
    try:
        
        return flask.Response(status=200)
    except:
        return "Error encountered while attempting to Delete record from database", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6969)
