import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/etc/RouteCreator.dart';
import 'package:google_maps_in_flutter/screens/ParkingScreen.dart';

/**
 * A class that creates a Pill widget which is responsible for showing the
 * information of the parking lot; a button is shown to view the state of
 * the parking lot
 * 
 * @author: John Penaflor
 */
class Pill extends StatelessWidget {
  final String landmark;
  final int total;
  final int available;
  final int numFloors;

  const Pill(
      {Key? key,
      required this.landmark,
      required this.total,
      required this.available,
      required this.numFloors})
      : super(key: key);
  /**
   * build: build method that builds the widget:
   *  set the margin, padding, decoration, and let the child widget be
   * a column of Text 
   * 
   * @param: context
   */

  @override
  Widget build(BuildContext context) {
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Label("Landmark: " + this.landmark),
          Label("Total: " + this.total.toString()),
          Label("Available: " + this.available.toString()),
          RaisedButton(
              onPressed: () {
                _nextScreen(context);
              },
              child: Label("Additional Info"),
              color: Colors.blue)
        ])
        //add child for container here:
        );
  }
  /**
   * Label: private method that creates a Text widget 
   * with font of Unisans
   * 
   * @param: String text
   * @returns: Text widget
   */

  Text Label(String text) {
    return Text(text,
        style: TextStyle(
            fontFamily: 'UniSans', color: Colors.white, fontSize: 14));
  }

  void _nextScreen(BuildContext context) {
    RouteCreator route = new RouteCreator(
        screen: ParkingScreen(
      parkingLotName: this.landmark,
      numFloors: numFloors,
    ));
    Navigator.of(context).push(route.createRoute());
  }
}
