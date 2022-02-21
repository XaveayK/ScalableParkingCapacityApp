// ignore_for_file: empty_constructor_bodies
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/map_marker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}

//this class creates the state of the MapScreen
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

/*
This class is responsible for configuring the state of the Map Screen Widget
This is a private class
*/
class _MapScreenState extends State<MapScreen> {
  //initCameraPosition: sets the initial target and zoom
  //GoogleMapController: controller for a single GoogleMap instance which is
  //running on the host platform; can use methods such as animateCamera
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(53.5461, -113.4938),
    zoom: 11.5,
  );

  //main controller for google map
  late GoogleMapController _googleMapController;
  Set<Marker> _markers = {};

  //
  void _onMapCreated(GoogleMapController controller) {
    //this method allows initializing the markers that will be presented
    //to the Google Map Widget
    setState(() {
      List<Marker> markerTemp = toMarker(mapMarkers);
      _markers = markerTemp.toSet();
    });
  }

  /*
  This method fetches the json file from the assets/map_styles directory;
  
  */
  changeMapStyle() {
    getJsonFile("assets/map_styles/night.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _googleMapController.setMapStyle(mapStyle);
  }

  List<Marker> toMarker(List<MapMarker> mapMarkerList) {
    List<Marker> markerList = [];
    for (var i = 0; i < mapMarkerList.length; i++) {
      markerList.add(Marker(
        markerId: MarkerId(mapMarkerList[i].title),
        position: mapMarkerList[i].location,
      ));
    }
    return markerList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Parking App"),
        backgroundColor: Colors.purple[900],
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _googleMapController = controller;
          _onMapCreated(controller);
          changeMapStyle();
        },
        markers: _markers,
      ),
    );
  }
}
