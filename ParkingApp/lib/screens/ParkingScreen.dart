import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/widgets/DropdownWidget.dart';
import 'package:google_maps_in_flutter/widgets/ParkingLot.dart';
import 'package:google_maps_in_flutter/widgets/helpParkingScreenPill.dart';

/**
 * This class Widget is responsible for creating the screen for the Parking Lot.
 * 
 * @author: John Penaflor
 */
const double PILL_VISIBLE_POSITION = 30;
const double PILL_INVISIBLE_POSITION = -220;

class ParkingScreen extends StatefulWidget {
  final String parkingLotName;
  final int numFloors;

  const ParkingScreen(
      {Key? key, required this.parkingLotName, required this.numFloors})
      : super(key: key);

  @override
  _ParkingScreenState createState() {
    return _ParkingScreenState();
  }
}

class _ParkingScreenState extends State<ParkingScreen> {
  late AnimationController _animatedController;
  double helpPillPos = PILL_VISIBLE_POSITION;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
  }

  String getParkingLotName() {
    return widget.parkingLotName;
  }

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: ParkingLot(
              parkingLotName: widget.parkingLotName,
              numFloors: widget.numFloors,
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: IconButton(
              iconSize: 40.0,
              icon: Icon(Icons.help),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  print(isVisible);
                  isVisible = !isVisible;
                  this.helpPillPos = PILL_VISIBLE_POSITION;
                  print(this.helpPillPos);
                });
              },
            ),
          ),
          if (isVisible)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: 8,
              right: 8,
              bottom: this.helpPillPos,
              child: helpParkingScreenPill(),
            ),
        ]),
      ),
    );
  }
}
/*
child: InteractiveViewer(
              scaleEnabled: true,
              panEnabled: true,
              minScale: 0.1,
              maxScale: 4,
              //boundaryMargin: EdgeInsets.zero,
              boundaryMargin: const EdgeInsets.all(30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: ParkingLot(),
              ),
            ),
*/

/*
 Center(
            child: InteractiveViewer(
              onInteractionUpdate: (ScaleUpdateDetails info) {
                var myScale = info.scale;
                print(myScale);
              },
              scaleEnabled: true,
              panEnabled: true,
              minScale: 1,
              maxScale: 4.6,
              boundaryMargin: const EdgeInsets.all(20.0),
              child: ClipRRect(
                
                borderRadius: BorderRadius.circular(18.0),
                child: ParkingLot(
                  parkingLotName: parkingLotName,
                  numFloors: numFloors,
                ),
              ),
            ),
          ),

*/

  /**
   * build - overriden 
   * 
   */

 