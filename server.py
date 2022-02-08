from asyncio.constants import LOG_THRESHOLD_FOR_CONNLOST_WRITES
from cProfile import run
import flask
import pyodbc
from credentials import driver, server, password as pw, database as db, username as un # This is your own personal credentials file in the same directory.

#with pyodbc.connect('DRIVER='+driver+';SERVER=tcp:'+server+';PORT=1433;DATABASE='+db+';UID='+un+';PWD='+ pw) as conn:
#    with conn.cursor() as cursor:
#        cursor.execute("QUERY HERE")

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

#Adds a parking lot
@app.route("/api/v1/newLot/<string:placeName>/<string:lotID>/<int:stallAmount>", methods=['POST'])
def newParkingLot(placeName, lotID, stallAmount):
    return placeName, lotID, stallAmount

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
    app.run(host="0.0.0.0", port=6969)


