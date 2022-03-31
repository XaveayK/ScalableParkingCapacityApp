import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/etc/RouteCreator.dart';

import 'MapScreen.dart';

class LoadingScreen extends StatelessWidget {
  int duration = 0;
  Widget goToPage;

  LoadingScreen({required this.goToPage, required this.duration});

  @override
  Widget build(BuildContext context) {
    RouteCreator route = new RouteCreator(screen: MapScreen());
    //allow transition to the next page (MapScreen) with the delay of 3 seconds
    Future.delayed(Duration(seconds: this.duration), () {
      Navigator.of(context).push(route.createRoute());
    });
    // TODO: implement build
    return Scaffold(
        body: Container(
      color: Colors.grey[800],
      alignment: Alignment.center,
      //child widgets:
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
                //icon for the app
                child: Icon(Icons.car_rental_rounded,
                    color: Colors.white, size: 100)),
            const SizedBox(height: 40), //allows space between two widgets
            const Text(
              'Scalable Parking App',
              style: TextStyle(
                  fontSize: 30, fontFamily: 'UniSans', color: Colors.white),
            )
          ]),
    ));
  }
}
