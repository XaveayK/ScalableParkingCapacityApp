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

conn_str = (
    r'DRIVER=%s;'
    r'server=tcp:%s;'
    r'PORT=1433;'
    r'DATABASE=%s;'
    r'UID=%s;'
    r'PWD=%s'
)

# function: parkingLotExists
# Parameters: lotName - the name of the parking lot
# Description: Checks whether the name of the parking lot exists, and stores it in a variable called count.
#              If there are no results, count = 0
def parkingLotExists(lotName):
    existProcedure = "EXEC [dbo].[parkingLotExists] @parkingLotName = ?"
    cursor.execute(existProcedure, lotName)
    count = cursor.fetchone()[0]
    cursor.commit()
    return count

# function: landmarkExists
# Parameters: placeName - The name of the landmark
# Description: Checks whether the name of the landmark exists, and stores it in a variable called count. 
#              if there are no results, count = 0
def landmarkExists(placeName):
    existProcedure = "Exec [dbo].[landmarkExists] @landmarkName = ?"
    cursor.execute(existProcedure, [placeName])
    count = cursor.fetchone()[0]
    cursor.commit()
    return count

#Query the database with a premade query
#Params: query - the query to execute
#        bool  - If the query is select/(add or remove)
def queryDataBase(query, bool):
    with pyodbc.connect(conn_str) as conn:
        with conn.cursor() as cursor:
            cursor.execute(query)
            if bool:
                data = cursor.fetchall()
    return data

#Gets stall information for a single lot
# Each stall entry contained in row has the following attributes:
# row.HardwareID = hardware ID related to the stall (string datatype)
# row.isAvailable = value that tells whether a vehicle is in the stall or not (boolean data type)
# row.ParkingLotName = contains the name of the parking lot the stall is attached to (string datatype)
@app.route("/api/v1/parking-lot/<string:lotName>", methods=['GET'])
def getLotInfo(lotName):
    # check if parking lot exists before grabbing all records pertaining to the parking lot name
    count = parkingLotExists(lotName)
    if count <= 0:
        return "Parking Lot does not exist in database.", 400
    try:
        storedProcedure = "EXEC [dbo].[GetParkingLotInfo] @parkingLotName = ?"
        params = lotName
        cursor.execute(storedProcedure, params)
        rows = cursor.fetchall()
        cursor.commit()
        # return rows in John's desired JSON format here 
        

        return flask.Response(status=200)
    except:
        return "Error encountered while attemping to access the database.", 500

#Gets the information for a landmark, all lots connected to it
@app.route("/api/v1/landmark/<string:placeName>", methods=['GET'])
def getPlaceInfo(placeName):
    count = landmarkExists(placeName)
    if count <= 0:
        return "landmark name does not exist ", 400
    try:
        storedProcedure = "EXEC [dbo].[getLandmarkInfo] @landmarkName = ?"
        cursor.execute(storedProcedure, placeName)
        rows = cursor.fetchall()
        cursor.commit()
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
def updateStallInfo(stallID):
    try:
        storedProcedure = "EXEC [dbo].[updateStallInfo] @stallID = ?"
        cursor.execute(storedProcedure, stallID)
        cursor.commit()
        return flask.Response(status=200)
    except:
        return "ERROR while attempting to access database." , 500


#Adds a parking lot (Does not require placeName)
@app.route("/api/v1/newLot/<string:lotName>", methods=['POST'])
def newParkingLot(lotName):
    count = parkingLotExists(lotName)
    if count > 0:
        return "parking lot already exists", 400
    try:     
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
    except:
        # Failed somewhere accessing the database
        return "There was an error accessing the database", 500

#Adds a parking lot. 
@app.route("/api/v1/newLot/<string:placeName>/<string:lotName>", methods=['POST'])
def newParkingLotWithLandmark(placeName, lotName):
    exists = parkingLotExists(lotName)
    count = landmarkExists(placeName)
    if count < 0:
        return "Landmark linked to the parking lot does not exist", 400
    if exists > 0:
        return "parking lot already exists", 400
    try:
        requestData = request.json
        if requestData is not None:
            # If the json data does exist, then this means client is sending the address info 
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
    except:
        return "Error encountered while accessing the Database", 500
        
#Adds a new landmark, with the landmark name being the placeName obtained from URI, and request being parsed from JSON 
@app.route("/api/v1/newLandmark/<string:placeName>", methods=['POST'])
def newLandMark(placeName):

    # checking if landmark already exists
    count = landmarkExists(placeName)
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

    # check if landmark exists before attempting to delete
    count = landmarkExists(placeName)
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
@app.route("/api/v1/removeParkingLot/<string:lotName>")
def remParkingLot(lotName):
    
    # verify if parking lot exists before attempting to delete it
    count = parkingLotExists(lotName)
    if count <= 0:
        return "Parking Lot does not exist in database.", 400
    try:
        
        return flask.Response(status=200)
    except:
        return "Error encountered while attempting to Delete record from database", 500

if __name__ == "__main__":
    conn_str=(conn_str % (driver, server, db, un, pw))
    print(conn_str)
    app.run(host="0.0.0.0", port=6969)