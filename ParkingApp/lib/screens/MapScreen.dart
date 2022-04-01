// ignore_for_file: empty_constructor_bodies
import 'dart:async';
import 'dart:io';

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/main.dart';
import 'package:google_maps_in_flutter/widgets/Pill.dart';
import 'package:location/location.dart';

import 'package:google_maps_in_flutter/models/map_marker.dart';

//global variables:
const double MAP_PILL_VISIBLE_POSITION = 550;
const double MAP_PILL_INVISIBLE_POSITION = 1200;
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
class _MapScreenState extends State<MapScreen> with RouteAware {
  //initCameraPosition: sets the initial target and zoom
  //GoogleMapController: controller for a single GoogleMap instance which is
  //running on the host platform; can use methods such as animateCamera

  //initialize a StreamController here to allow pausing and resuming of
  //the subscribed stream:
  late StreamController _streamController;
  late Stream<Set<dynamic>> setStream;
  // ignore: prefer_typing_uninitialized_variables
  late var _setSubscription;

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(53.5461, -113.4938),
    zoom: 11.5,
  );
  //snackbars:
  final pillSnackBar = SnackBar(
      content: const Text('Click anywhere to close the Landmark overlay.',
          style: TextStyle(
              fontFamily: 'UniSans', color: Colors.white, fontSize: 14)));
  final errorSnackBar = SnackBar(
      content: const Text('Cannot get data for markers!',
          style: TextStyle(
              fontFamily: 'UniSans', color: Colors.white, fontSize: 14)));

  final helpSnackBar = SnackBar(
      content: const Text(
          'Click on the "search" button again to close the overlay',
          style: TextStyle(
              fontFamily: 'UniSans', color: Colors.white, fontSize: 14)));
  //'Click on the "search" button again to close the overlay'
  late Future<List<dynamic>> _future;
  late Timer timer;
  int counter = 0;
  late BitmapDescriptor icon;
  final streamError = false;

  //main controller for google map
  Location currentLocation = Location();
  late GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  double mapPillPos = MAP_PILL_VISIBLE_POSITION;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    //call function whenever the map screen is visited
    print('*** Entering ${this.toString()}');
    //print(routeObserver);
    super.didPush();
  }

  @override
  void didPop() {
    print('${this.toString()}: Called didPop');
    super.didPop();
  }

  @override
  void didPopNext() {
    //resume stream controller here:
    _setSubscription.resume();
    print('${this.toString()}:Called didPopNext');
    super.didPopNext();
  }

  @override
  void didPushNext() {
    print('${this.toString()}: Called didPushNext');
    super.didPushNext();
  }

  /**
   * initState: initialize state of the screen here:
   */
  @override
  void initState() {
    //allow subscription of the current route here:
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
    getIcon();
    setStream = _createMarkerSet(context);
    _streamController = StreamController.broadcast();
    _setSubscription = setStream.listen((event) {
      print('stream running...');
      return _streamController.add(event);
    });
    //fetchLocation();
    // _future = createMapMarkerList();
    //check and verify if the mapMarkers are empty or not
    // _checkMarkers();
  }

  // //helper methods that create widgets for alertDialog:
  Widget getCloseButton() {
    return TextButton(
      child: Text('Close'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
  // }

  Future<void> _checkMarkers() async {
    if (mapMarkers.length == 0) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text("No Data!"),
            content: Text("Cannot get data for available parking lots!"),
            actions: [getCloseButton()],
          ),
        );
      });
    }
  }

  getIcon() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)), 'assets/images/blueIcon.png');
    setState(() {
      this.icon = icon;
    });
  }

  Stream<Set<dynamic>> _createMarkerSet(BuildContext context) async* {
    bool _running = true;
    await Future<void>.delayed(const Duration(seconds: 1));
    //NOTE: only uncomment this line when the API is shut down
    //mapMarkers = await createMapMarkerListTest();
    mapMarkers = await createMapMarkerList();

    if (mapMarkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
    List<Marker> markerTemp = toMarker(mapMarkers, context);
    _markers = markerTemp.toSet();
    yield _markers;
    while (_running) {
      // print('Please run me');
      // print(mapMarkers.toString());
      await Future<void>.delayed(const Duration(seconds: 30));
      mapMarkers = await createMapMarkerList();
      List<Marker> markerTemp = toMarker(mapMarkers, context);
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
  List<Marker> toMarker(List<dynamic> mapMarkerList, BuildContext context) {
    List<Marker> markerList = [];
    // print("Length: " + mapMarkerList.length.toString());
    for (var i = 0; i < mapMarkerList.length; i++) {
      markerList.add(Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          markerId: MarkerId(mapMarkerList[i].title),
          position: mapMarkerList[i].location,
          onTap: () {
            setState(() {
              ScaffoldMessenger.of(context).showSnackBar(pillSnackBar);
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
    // ignore: unnecessary_new
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: getScaffold(context),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.grey,
            title: new Text('Are you sure?'),
            content: new Text(
              'Do you want to exit the ParkingApp',
              style: TextStyle(
                  fontFamily: 'UniSans', color: Colors.white, fontSize: 14),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  List<Widget> getWidgetList(List<dynamic> mapMarkerList) {
    List<Widget> widgetList = [];
    widgetList.add(
      Container(
          margin: EdgeInsets.all(1),
          padding: EdgeInsets.all(1),
          child: Text("All Available Parking Lots",
              style: TextStyle(
                  fontFamily: 'UniSans',
                  color: Colors.blueGrey,
                  fontSize: 18))),
    );

    //iterate through and create a clickable container which contains
    //the parking lot info.
    for (int i = 0; i < mapMarkerList.length; i++) {
      print('create');
      widgetList.add(InkWell(
          child: Container(
              margin: EdgeInsets.all(1),
              padding: EdgeInsets.all(1),
              child: Text(mapMarkerList[i].title,
                  style: TextStyle(
                      fontFamily: 'UniSans',
                      color: Colors.white,
                      fontSize: 14))),
          onTap: () {
            _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: mapMarkerList[i].location, zoom: 15)));
          }));
      widgetList.add(SizedBox(height: 5));
    }

    return widgetList;
  }

  Widget getScaffold(BuildContext context) {
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
      body: getScreen(context),
    );
  }

  Widget getScreen(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: StreamBuilder(
              stream: _streamController.stream,
              builder: (context, AsyncSnapshot snapshot) {
                //print("snapshot: " + snapshot.data);

                // if (snapshot.data == null) {
                //   print("ok");
                //   //Scaffold.of(context).showSnackBar(errorSnackBar);
                // }

                // if (snapshot.hasError) {
                //   Scaffold.of(context).showSnackBar(errorSnackBar);
                // }
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
                    _googleMapController = controller;
                    changeMapStyle();
                  },
                  onTap: (LatLng coord) {
                    setState(() {
                      this.isActive = false;
                      this.isVisible = false;

                      this.pillPos = PIN_INVISIBLE_POSITION;
                    });
                  },
                  markers: snapshot.data!,
                );
              }),
        ),
        if (searchIsClicked)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            left: 12,
            right: 12,
            bottom: this.mapPillPos,
            child: getMapPill(),
          ),

        //Container(child: pillWidget(mapMarkers)),
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
              setSubscription: _setSubscription,
              landmark: relativeLandmark,
              total: relativeTotal,
              available: relativeAvail,
              numFloors: relativeFloors,
            ),
          ),

        Align(
            alignment: Alignment.topLeft,
            child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (!searchIsClicked) {
                      ScaffoldMessenger.of(context).showSnackBar(helpSnackBar);
                      this.mapPillPos = MAP_PILL_VISIBLE_POSITION;
                      this.searchIsClicked = true;
                    } else {
                      this.mapPillPos = MAP_PILL_INVISIBLE_POSITION;
                      this.searchIsClicked = false;
                    }
                  });
                },
                child: Icon(Icons.search))),
      ],
    );
  }

  Widget getMapPill() {
    return Container(
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
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: getWidgetList(mapMarkers)),
        ));
  }
}
