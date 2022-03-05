// ignore_for_file: empty_constructor_bodies
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/widgets/Pill.dart';

import 'package:google_maps_in_flutter/models/map_marker.dart';

//global variables:
const double PIN_VISIBLE_POSITION = 20;
const double PIN_INVISIBLE_POSITION = -220;

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
  double pillPos = PIN_VISIBLE_POSITION;
  late String relativeLandmark = " ";
  bool isVisible = false;

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
          onTap: () {
            setState(() {
              this.pillPos = PIN_VISIBLE_POSITION;
              this.relativeLandmark = mapMarkerList[i].title;
              this.isVisible = true;
            });
          }));
    }
    return markerList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            title: new Text("Parking App",
                style: TextStyle(
                    fontFamily: 'UniSans', color: Colors.white, fontSize: 20)),
            backgroundColor: Colors.grey[900],
            automaticallyImplyLeading: false),
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
                onTap: (LatLng coord) {
                  setState(() {
                    this.pillPos = PIN_INVISIBLE_POSITION;
                  });
                },
                markers: _markers,
              ),
            ),
            //AnimatedPositioned widget allows the Pill child widget to be animated
            //upon clicking a marker from the map
            if (isVisible)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: 8,
                right: 8,
                bottom: this.pillPos,
                child: Pill(landmark: relativeLandmark),
              ),
          ],
        ));
  }
}
