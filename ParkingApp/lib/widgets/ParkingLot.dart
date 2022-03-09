import 'dart:async';
import 'dart:io';
import 'dart:convert' show Codec, base64, utf8;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/**
 * 
 * This class is responsible for initializing a stateful widget that
 * fetches the image in an asynchronous manner
 * 
 * @author: John Penaflor
 */

class ParkingLot extends StatefulWidget {
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
  final String ABS_PATH =
      "/home/penny/CapstoneProject/ScalableParkingCapacityApp/ParkingApp/lib/widgets/message.txt";
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('got here');
    return StreamBuilder<Image>(
      stream: _get(),
      builder: (context, AsyncSnapshot<Image> image) => image.hasData
          ? Center(child: image.data)
          : CircularProgressIndicator(),
    );
  }

  /**
  * Create Stream
  */

  // Stream<http.Response> _get() async* {
  //   yield* Stream.periodic(Duration(seconds: 5), (_) {
  //     return http.get(Uri.parse("http://numbersapi.com/random/"));
  //   }).asyncMap((event) async => await event);
  // }

  Stream<Image> _get() async* {
    yield* Stream.periodic(Duration(seconds: 5), (_) {
      /*
      1. do a file-IO of message.txt
      2. once the file is read, store to a var;
      3. decode to utf-8
      4. decode to base64
      5. convert bytes to an image

      */
      print('hello');
      var _test;
      _test = _read();
      var bytes = utf8.decode(_test);
      print('$bytes');
      var b64Bytes = base64.decode(bytes);
      print('$b64Bytes');
      return Image.memory(b64Bytes);
    }).asyncMap((event) async => await event);
  }

  Future<String> _read() async {
    Future<bool> check = File('message.txt').exists();
    print('$check');
    try {
      final file = File(ABS_PATH);
      return await file.readAsString();
    } catch (e) {
      print(e);
      return "Unknown!";
    }
  }
}
