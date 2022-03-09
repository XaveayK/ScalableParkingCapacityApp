import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/widgets/DropdownWidget.dart';
import 'package:google_maps_in_flutter/widgets/ParkingLot.dart';
/**
 * This class Widget is responsible for creating the screen for the Parking Lot.
 * 
 * @author: John Penaflor
 */

class ParkingScreen extends StatelessWidget {
  /**
   * build - overriden 
   * 
   */
  @override
  Widget build(BuildContext context) {
    String dropdownValue = '1';
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Parking Lot View",
            style: TextStyle(
                fontFamily: 'UniSans', color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        color: Colors.blueGrey[900],
        child: Stack(children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: DropdownMenuWidget(),
          ),
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              boundaryMargin: EdgeInsets.zero,
              child: ParkingLot(),
              //child: Image.asset('assets/images/ParkingLot.png'),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: IconButton(
              icon: new Image.asset('assets/images/RefreshIcon.png'),
              color: Colors.white,
              onPressed: () {},
            ),
          )
        ]),
      ),
    );
  }
}
