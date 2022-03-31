import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' show base64, json;

/*
  Map Marker Model:

  This object holds the data for:
    -title: name of the landmark
    -location: in LatLng object; holds latitude and longitude 

*/
const String fake_URL = "https://pacific-oasis-59208.herokuapp.com/api/v1/fake";
const String URL =
    "https://pacific-oasis-59208.herokuapp.com/api/v1/allAvailable";
List<dynamic> tempList = [];

class MapMarker {
  final String title;
  final LatLng location;
  final int total;
  final int avail;
  final int floors;

  const MapMarker(
      {required this.title,
      required this.location,
      required this.total,
      required this.avail,
      required this.floors});

  @override
  String toString() {
    return title +
        " " +
        location.toString() +
        " " +
        total.toString() +
        " " +
        avail.toString();
  }
}

//other functions:
double checkCoord(String toCheck) {
  double coord = 0.0;
  if (toCheck.contains('N') || toCheck.contains('E')) {
    toCheck = toCheck.trim();
    List<String> tempList = toCheck.split("");
    tempList.removeLast();
    toCheck = tempList.join();
    coord = double.parse(toCheck);
  } else if (toCheck.contains('S') || toCheck.contains('W')) {
    toCheck = toCheck.trim();
    List<String> tempList = toCheck.split("");
    tempList.removeLast();
    toCheck = tempList.join();
    String newStr = "-";
    newStr += toCheck;
    coord = double.parse(toCheck);
  } else {
    coord = double.parse(toCheck);
  }

  return coord;
}

//create an iterative function that loads the json data here:
Future<List<dynamic>> createMapMarkerList() async {
  Map<String, dynamic> jsonData;
  //fake URL:
  // final response = await http.get(Uri.parse(fake_URL));

  //fetch all available parking lots here:
  final response = await http.get(Uri.parse(URL));
  if (response.statusCode == 200) {
    tempList.clear();
    //if success:
    jsonData = json.decode(response.body);
    for (String key in jsonData.keys) {
      List<dynamic> data = jsonData[key];
      var _floors = int.parse(data[0]['floors']);

      var _title = key;

      var _latLngStr = data[0]['latlong'];

      _latLngStr = _latLngStr.trim();

      var _latLngArr = _latLngStr.split(",");

      double _latitude = checkCoord(_latLngArr[0].trim());
      double _longitude = checkCoord(_latLngArr[1].trim());

      var _available = int.parse(data[0]['totalAvailable']);

      var _stalls = int.parse(data[0]['totalStalls']);

      tempList.add(MapMarker(
          title: _title,
          location: LatLng(_latitude, _longitude),
          total: _stalls,
          avail: _available,
          floors: _floors));
    }
  } else {
    return tempList;
  }

  return tempList;
}
