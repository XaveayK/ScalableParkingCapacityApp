from asyncio.constants import LOG_THRESHOLD_FOR_CONNLOST_WRITES
from cProfile import run
import flask
import pyodbc
from credentials import driver, server, password as pw, database as db, username as un # This is your own personal credentials file in the same directory.

#with pyodbc.connect('DRIVER='+driver+';SERVER=tcp:'+server+';PORT=1433;DATABASE='+db+';UID='+un+';PWD='+ pw) as conn:
#    with conn.cursor() as cursor:
#        cursor.execute("QUERY HERE")

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

#Adds a parking lot
@app.route("/api/v1/newLot/<string:placeName>/<string:lotID>", methods=['POST'])
def newParkingLot(placeName, lotID, stallAmount):
    if placeName.lower() != 'null':
        queryDataBase(
            'INSERT INTO '
        )
    return placeName, lotID, stallAmount

#Add a parking stall
@app.route("/api/v1/newStall/<string:lotID>", methods=["POSt"])
def newStall(lotID):
    data = queryDataBase(
        'INSERT INTO Stall (isAvailable, ParkingLotID) ' +
        'VALUES (0, %s);' % lotID, 0
    )
    return lotID

#Adds a new landmark
@app.route("/api/v1/newLandMark/<string:placeName>", methods=['POST'])
def newLandMark(placeName):
    return placeName

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