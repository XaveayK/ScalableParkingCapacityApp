#====================================================================================================
# File Author: Xavier Kidston, Alex Creencia
# File name: server.py
# Description: File that hosts the webserver AND the API implementation. This file will sort out API
#              Routes based on the URI. **Some paths will require JSON parsing.
#=====================================================================================================

from asyncio.constants import LOG_THRESHOLD_FOR_CONNLOST_WRITES
from cProfile import run
from sqlite3 import Cursor
import flask
import pyodbc
import apiStructs
from flask import request
from credentials import driver, server, password as pw, database as db, username as un # This is your own personal credentials file in the same directory.

#with pyodbc.connect('DRIVER='+driver+';SERVER=tcp:'+server+';PORT=1433;DATABASE='+db+';UID='+un+';PWD='+ pw) as conn:
#    with conn.cursor() as cursor:
#        cursor.execute("QUERY HERE")

#connection strings + cursor + connecting to server
connection = pyodbc.connect('DRIVER='+driver+';SERVER=tcp:'+server+';PORT=1433;DATABASE='+db+';UID='+un+';PWD='+ pw)
cursor = connection.cursor()


app = flask.Flask(__name__)

#Gets the information for a single lot
@app.route("/api/v1/parking-lot/<string:placeName>/<string:lotID>", methods=['GET'])
def getLotInfo(placeName, lotID):
    return placeName, lotID

#Gets the information for a landmark, so the lots connected to it
@app.route("/api/v1/parking-lot/<string:placeName>", methods=['GET'])
def getPlaceInfo(placeName):
    return placeName

#Gets the information for individual stalls
@app.route("/api/v1/stall-status/<string:placeName>/<string:stallID>", methods=['PUT'])
def getStallInfo(placeName, stallID):
    return placeName, stallID

#Adds a parking lot (Does not require placeName)
@app.route("/api/v1/newLot/<string:lotName>", methods=['POST'])
def newParkingLot(lotName):
    requestData = request.json
    if requestData is not None:
        address = requestData["address"]
        storedProcedure = "Exec [dbo].[AddParkingLot] @parkingLotName = ?, @address = ?"
        params = (lotName, address)
    else:
        storedProcedure = "Exec [dbo].[AddParkingLot] @parkingLotName = ?"
        params = (lotName)
    
    # After setting up stored Procedure and parameters for it properly, we execute query
    cursor.execute(storedProcedure,params)
    cursor.commit()
    return flask.Response(status=200)

#Adds a parking lot. 
@app.route("/api/v1/newLot/<string:placeName>/<string:lotName>", methods=['POST'])
def newParkingLotWithLandmark(placeName, lotName):
    requestData = request.json
    if requestData is not None:
        address = requestData["address"]
        storedProcedure = "Exec [dbo].[AddParkingLotWithLandmark] @landmarkName = ?, @parkingLotName = ?, @address = ?"
        params = (placeName, lotName, address)
    else:
        storedProcedure = "Exec [dbo].[AddParkingLotWithLandmark] @landmarkName = ?, @parkingLotName = ?"
        params = (placeName, lotName)
    
    # After setting up stored Procedure and parameters for it properly, we execute query
    cursor.execute(storedProcedure, params)
    cursor.commit()

    return flask.Response(status=200)
    
#Adds a new landmark, with the landmark name being the placeName obtained from URI, and request being parsed from JSON 
@app.route("/api/v1/newLandMark/<string:placeName>", methods=['POST'])
def newLandMark(placeName):

    existProcedure = "Exec [dbo].[landmarkExists] @landmarkName = ?"
    count = cursor.execute(existProcedure)
    cursor.commit()
    if count > 0:
        return "Landmark already exists", 400

    try:
        requestData = request.json                                     # we check if json body data came with the API request: e.g. { "address:" "104th street"}
        if requestData is not None:                                    # if it did, submit it to stored procedure
            address = requestData["address"]
            storedProcedure = "Exec [dbo].[AddLandmark] @landmarkName = ?, @address = ?"
            params = (placeName, address)
            cursor.execute(storedProcedure, params)
            cursor.commit()
        else:
            storedProcedure = "Exec [dbo].[AddLandmark] @landmarkName = ?"
            params = (placeName)
            cursor.execute(storedProcedure, params)
            cursor.commit()  
        return flask.Response(status=200)  
    except:
        return "Error encountered while attempting to access Database", 500
    

#Removes a landmark. Does NOT remove the associated parking lot, since a parking lot can exist without a landmark (unmarked parking lots)
@app.route("/api/v1/removeLandMark/<string:placeName>", methods=['DELETE'])
def remLandMark(placeName):

    #check if landmark exists before attempting to delete
    existProcedure = "Exec [dbo].[landmarkExists] @landmarkName = ?"
    count = cursor.execute(existProcedure, placeName).rowcount()
    cursor.commit()  # not sure about this commit
    if count <= 0:
        return "Landmark does not exist", 400
    
    # if it exists, attempt to delete from database
    try:
        storedProcedure = "Exec [dbo].[RemoveLandmark] @landmark = ?"
        params = (placeName)
        cursor.execute(storedProcedure, params)
        cursor.commit()
        return flask.Response(status=200)
    except:
        return "Error encountered while attempting to Delete record from database", 500

#Removes a parking lot and its stalls
@app.route("/api/v1/removeParkingLot/<string:lotID>")
def remParkingLot(placeName, lotID):
    return placeName, lotID

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6969)


