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
                        maxScale: 1.6,
                        child: Container(child: element),
                      );

                      return zoomableElem;
                    },
                    itemCount: snapshot.data.length)
                : CircularProgressIndicator());
      },
    );
    // builder: (context, AsyncSnapshot<Image> image) => image.hasData
    //     ? SizedBox(height: 250.0, child: image.data)
    //     : CircularProgressIndicator(),
    // builder: (context, AsyncSnapshot<dynamic> image) {
    //   if (!image.hasData) {
    //     return CircularProgressIndicator();
    //   } else {
    //     return Container(width: 500, height: 500, child: image.data);
    //   }
    // });
  }

  // @override
  // Widget build(BuildContext context) {
  //   print('got here');
  //   return StreamBuilder<dynamic>(
  //       stream: _get(),
  //       // builder: (context, AsyncSnapshot<Image> image) => image.hasData
  //       //     ? SizedBox(height: 250.0, child: image.data)
  //       //     : CircularProgressIndicator(),
  //       builder: (context, AsyncSnapshot<dynamic> image) {
  //         if (!image.hasData) {
  //           return CircularProgressIndicator();
  //         } else {
  //           return Container(width: 500, height: 500, child: image.data);
  //         }
  //       });
  // }

  /**
  * Create Stream
  */

  // Stream<http.Response> _get() async* {
  //   yield* Stream.periodic(Duration(seconds: 5), (_) {
  //     return http.get(Uri.parse("http://numbersapi.com/random/"));
  //   }).asyncMap((event) async => await event);
  // }

  // Stream<dynamic> _get() async* {
  //   yield* Stream.periodic(Duration(seconds: 1), (_) {
  //     /*
  //     1. do a file-IO of message.txt
  //     2. once the file is read, store to a var;
  //     3. decode to utf-8
  //     4. decode to base64
  //     5. convert bytes to an image

  //     */
  //     return load();
  //   }).asyncMap((event) async => await event);
  // }
  /*
  Future load() async {
    List<Widget> data = [];
    final String encodedStr = await _read();
    if (encodedStr == 'Invalid link!') {
      return Text('Cannot get data!',
          style: TextStyle(
              fontFamily: 'UniSans', color: Colors.white, fontSize: 14));
    }

    var b64Bytes = base64.decode(encodedStr);
    data.add(Image.memory(
      b64Bytes,
      width: 1000,
      height: 1000,
      gaplessPlayback: true,
    ));
  }
  */

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
        parkingLotImages.add(Text('Cannot get data!',
            style: TextStyle(
                fontFamily: 'UniSans', color: Colors.white, fontSize: 14)));
      }
    }

    return parkingLotImages;
  }
}
