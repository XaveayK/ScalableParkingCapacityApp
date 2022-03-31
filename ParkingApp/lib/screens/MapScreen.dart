// ignore_for_file: empty_constructor_bodies
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/widgets/Pill.dart';
import 'package:location/location.dart';

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

  final errorSnackBar = SnackBar(
      content: const Text('Cannot get data for markers!',
          style: TextStyle(
              fontFamily: 'UniSans', color: Colors.white, fontSize: 14)));

  late Future<List<dynamic>> _future;
  late Timer timer;
  int counter = 0;
  late BitmapDescriptor icon;

  //main controller for google map
  Location currentLocation = Location();
  late GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  double pillPos = PIN_VISIBLE_POSITION;
  late String relativeLandmark = " ";
  late int relativeTotal = 0;
  late int relativeAvail = 0;
  late int relativeFloors;
  bool searchIsClicked = false;
  bool isVisible = false;
  bool isActive = false;
  bool hasError = false;
  late List mapMarkers = [];

  @override
  void initState() {
    super.initState();
    getIcon();
    //fetchLocation();
    _future = createMapMarkerList();
  }

  getIcon() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)), 'assets/images/blueIcon.png');
    setState(() {
      this.icon = icon;
    });
  }

  Stream<Set<dynamic>> _createMarkerSet() async* {
    print("begin: " + _markers.toString());
    bool _running = true;
    await Future<void>.delayed(const Duration(seconds: 1));
    mapMarkers = await createMapMarkerList();
    List<Marker> markerTemp = toMarker(mapMarkers);
    _markers = markerTemp.toSet();
    yield _markers;
    while (_running) {
      await Future<void>.delayed(const Duration(seconds: 30));
      mapMarkers = await createMapMarkerList();
      List<Marker> markerTemp = toMarker(mapMarkers);
      _markers = markerTemp.toSet();
      yield _markers;
    }
  }

  changeMapStyle() {
    getJsonFile("assets/map_styles/night.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void fetchLocation() async {
    var location = await currentLocation.getLocation();
    print("info: " +
        location.latitude.toString() +
        " " +
        location.longitude.toString());

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('Home'),
          position:
              LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0)));
    });
  }

  void setMapStyle(String mapStyle) {
    _googleMapController.setMapStyle(mapStyle);
  }

  //this method populates the necessary locations to have a pinpoint marker
  //in latitude and longitude
  List<Marker> toMarker(List<dynamic> mapMarkerList) {
    List<Marker> markerList = [];
    for (var i = 0; i < mapMarkerList.length; i++) {
      markerList.add(Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(
              (isActive) ? BitmapDescriptor.hueRed : BitmapDescriptor.hueCyan),
          markerId: MarkerId(mapMarkerList[i].title),
          position: mapMarkerList[i].location,
          onTap: () {
            setState(() {
              this.isActive = true;
              this.pillPos = PIN_VISIBLE_POSITION;
              this.relativeLandmark = mapMarkerList[i].title;
              this.relativeTotal = mapMarkerList[i].total;
              this.relativeAvail = mapMarkerList[i].avail;
              this.relativeFloors = mapMarkerList[i].floors;

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
            child: StreamBuilder(
                stream: _createMarkerSet(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    print('error');
                    Scaffold.of(context).showSnackBar(errorSnackBar);
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return GoogleMap(
                    //minMaxZoomPreference: MinMaxZoomPreference(10, 100),
                    zoomGesturesEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      print('onMap');
                      _googleMapController = controller;
                      changeMapStyle();
                    },
                    onTap: (LatLng coord) {
                      setState(() {
                        this.isActive = false;
                        this.pillPos = PIN_INVISIBLE_POSITION;
                      });
                    },
                    markers: snapshot.data!,
                  );
                }),
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
              child: Pill(
                landmark: relativeLandmark,
                total: relativeTotal,
                available: relativeAvail,
                numFloors: relativeFloors,
              ),
            ),

          Positioned(
            left: 30,
            right: 30,
            bottom: 600,
            child: Container(
              margin: EdgeInsets.all(30),
              padding: EdgeInsets.all(30),
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
            ),
          ),

          Align(
              alignment: Alignment.topLeft,
              child: FloatingActionButton(
                  onPressed: () {}, child: Icon(Icons.search))),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     child: Icon(Icons.location_searching),
      //     onPressed: () {
      //       fetchLocation();
      //       print("size: " + _markers.length.toString());
      //     }),
    );
  }
}
