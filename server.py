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
@app.route("/api/v1/parking-lot/<string:lotID>", methods=['GET'])
def getLotInfo(lotID):
    data = queryDataBase(
        'SELECT HardWareID, isAvailable ' +
        'FROM Stall ' + 
        'WHERE ParkingLotID=%s;' % (lotID), 1
    )
    return data

#Gets the information for a landmark, all lots connected to it
@app.route("/api/v1/parking-lot/<string:placeName>", methods=['GET'])
def getPlaceInfo(placeName):
    data = queryDataBase(
        'SELECT ParkingLot.LotName, ParkingLot.ParkingLotID ' +
        'FROM ParkingLot ' +
        'JOIN Destination ' +
        'ON ParkingLot.ParkingLotID = Destination.ParkingLotID ' +
        'JOIN Landmark ' +
        'ON Destination.LandMarkID = Landmark.LandmarkID ' + 
        'WHERE Landmark.LandmarkName=%s;' % (placeName), 1
    )
    return data

#Gets the information for individual stalls
@app.route("/api/v1/stall-status/<string:lotID>/<string:hardWareID>", methods=['GET'])
def getStallInfo(lotID, hardWareID):
    data = queryDataBase(
        'SELECT HardWareID, isAvailable ' +
        'FROM Stall ' +
        'WHERE ParkingLotID=%s and HardWareID=%s;' % (lotID, hardWareID), 1
    )
    return data

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
    

#Removes a landmark
@app.route("/api/v1/removeLandMark/<string:placeName>", methods=['DELETE'])
def remLandMark(placeName):
    return placeName

#Removes a parking lot and its stalls
@app.route("/api/v1/removeParkingLot/<string:lotID>")
def remParkingLot(placeName, lotID):
    return placeName, lotID

if __name__ == "__main__":
    conn_str=(conn_str % (driver, server, db, un, pw))
    print(conn_str)
    app.run(host="0.0.0.0", port=6969)