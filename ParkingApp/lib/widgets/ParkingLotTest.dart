import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/etc/TestClass.dart';

class ParkingLotTest extends StatefulWidget {
  @override
  _ParkingLotTestState createState() => _ParkingLotTestState();
}

class _ParkingLotTestState extends State<ParkingLotTest> {
  Image? im;
  int sec = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer t) => load());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(width: 500.0, height: 500.0, child: im);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    TestClass tClass = new TestClass();
    String strin = tClass.getTest();
    //print('ok: $strin');

    var b64Bytes = base64.decode(strin);
    im = Image.memory(
      b64Bytes,
      gaplessPlayback: true,
    );
  }
}
