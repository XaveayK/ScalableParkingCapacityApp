import 'dart:convert';

import 'package:flutter/material.dart';

/**
 * This class is a widget that builds the tile that
 * shows the image and the name of the parking lot.
 */
class ParkingLotTile extends StatelessWidget {
  int floorNum;
  Image image;

  ParkingLotTile({required this.floorNum, required this.image});

  @override
  Widget build(BuildContext context) {
    String floorStr = floorNum.toString();
    String text = 'Floor ' + floorStr;
    return Container(
        width: 400,
        height: 800,
        color: Colors.blueGrey[850],
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text,
                style: TextStyle(
                    fontFamily: 'UniSans', color: Colors.white, fontSize: 14)),
            SizedBox(height: 50),
            image
          ],
        ));
  }
}
