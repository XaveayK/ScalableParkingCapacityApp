import 'dart:async';

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
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<http.Response>(
      stream: _get(),
      builder: (context, snapshot) => snapshot.hasData
          ? Center(child: Text(snapshot.data!.body))
          : CircularProgressIndicator(),
    );
  }
/**
 * Create Stream
 */

  Stream<http.Response> _get() async* {
    yield* Stream.periodic(Duration(seconds: 5), (_) {
      return http.get(Uri.parse("http://numbersapi.com/random/"));
    }).asyncMap((event) async => await event);
  }
}
