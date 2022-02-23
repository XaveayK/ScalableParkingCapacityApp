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
        fontFamily: "UniSans",
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
  This method fetches the json file from the assets/map_styles directory and then uses
  the setMapStyle to set the map style

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
          backgroundColor: Colors.grey[900],
        ),
        /*
        create a stack of widgets (one for GoogleMap and the other which
        holds a Container Widget that shows the landmark info and the number of
        cars parked.)
        Each widget has a parent widget called: 
          Positioned

        */
        body: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
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
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 20,
              child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset.zero,
                        )
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Landmark: West Edmonton Mall",
                            style: TextStyle(
                                fontFamily: 'UniSans',
                                color: Colors.white,
                                fontSize: 14)),
                        Text("Capacity",
                            style: TextStyle(
                                fontFamily: 'UniSans',
                                color: Colors.white,
                                fontSize: 14)),
                        Text("Status",
                            style: TextStyle(
                                fontFamily: 'UniSans',
                                color: Colors.white,
                                fontSize: 14))
                      ])),
              //add child for container here:
            )
          ],
        ));
  }
}
