import 'dart:async';

import 'dart:convert' show base64, json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/etc/TestClass.dart';
import 'package:google_maps_in_flutter/widgets/ParkingLotTile.dart';
import 'package:http/http.dart' as http;

/**
 * 
 * This class is responsible for initializing a stateful widget that
 * fetches the image in an asynchronous manner
 * 
 * @author: John Penaflor
 */

class ParkingLot extends StatefulWidget {
  final String parkingLotName;
  final int numFloors;
  final String _url =
      "https://pacific-oasis-59208.herokuapp.com/api/v1/parking-lot/";

  const ParkingLot(
      {Key? key, required this.parkingLotName, required this.numFloors})
      : super(key: key);

  @override
  _ParkingLotState createState() => _ParkingLotState();
}
/**
 * This private class defines the state of the Stateful Widget of the 
 * parking lot. A Future method should exist as this allows data to be 
 * constantly updated asynchronously/given delay.
 * 
 * @author: John Penaflor
 */

class _ParkingLotState extends State<ParkingLot> {
  late List parkingLotImages = [];
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: _createWidgetList(widget.numFloors),
      initialData: [],
      builder: (ctxt, snapshot) {
        return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50.0),
            child: (snapshot.hasData)
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext ctx, int index) {
                      //fetches the image
                      final element = snapshot.data[index];
                      Widget zoomableElem = InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20.0),
                        minScale: 0.1,
                        maxScale: 5,
                        child: Container(child: element),
                      );

                      return zoomableElem;
                    },
                    itemCount: snapshot.data.length)
                : CircularProgressIndicator());
      },
    );
  }

  Future<String> _read(int floor) async {
    String str = "";
    final response = await http.get(Uri.parse(
        widget._url + widget.parkingLotName + '/' + floor.toString()));
    if (response.statusCode == 200) {
      // ignore: deprecated_member_use

      Map<String, dynamic> values = json.decode(response.body);

      return values['image'];
    } else {
      return "Invalid link!";
    }

    return str;
  }

  Stream<List<dynamic>> _createWidgetList(int numFloors) async* {
    bool _running = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    parkingLotImages = await _populateImages(numFloors);
    yield parkingLotImages;
    while (_running) {
      await Future<void>.delayed(const Duration(seconds: 30));
      parkingLotImages = await _populateImages(numFloors);
      yield parkingLotImages;
    }

    //return a list of widgets:
  }

  Future<List> _populateImages(int numFloors) async {
    List<dynamic> parkingLotImages = [];
    for (var i = 1; i <= numFloors; i++) {
      String encodedStr = await _read(i);
      // ignore: deprecated_member_use
      if (encodedStr != 'Invalid link!') {
        var b64Bytes = base64.decode(encodedStr);
        var image = Image.memory(
          b64Bytes,
          width: 250,
          height: 250,
          gaplessPlayback: true,
          alignment: Alignment.center,
        );
        ParkingLotTile tile = new ParkingLotTile(floorNum: i, image: image);

        parkingLotImages.add(tile);
      } else {
        parkingLotImages.add(getErrorContainer());
      }
    }

    return parkingLotImages;
  }

  Widget getErrorContainer() {
    return Container(
      color: Colors.blueGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.error,
            color: Colors.red,
            size: 40.0,
          ),
          SizedBox(height: 20.0),
          Text('Cannot get data!',
              style: TextStyle(
                  fontFamily: 'UniSans', color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
