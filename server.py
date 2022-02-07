from cProfile import run
import flask

app = flask.Flask(__name__)

@app.route("/api/v1/parking-lot/<string:placeName>/<string:lotID>", methods=['GET'])
def getLotInfo(placeName, lotID):
    return placeName, lotID

@app.route("/api/v1/stall-status/<string:placeName>/<string:stallID>", methods=['PUT'])
def getStallInfo(placeName, stallID):
    return placeName, stallID

@app.route("/api/v1/parking-lot/<string:placeName>", methods=['GET'])
def getPlaceInfo(placeName):
    return placeName

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6969)
