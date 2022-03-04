import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/etc/RouteCreator.dart';

import 'MapScreen.dart';

class LoadingScreen extends StatelessWidget {
  int duration = 0;
  Widget goToPage;

  LoadingScreen({required this.goToPage, required this.duration});
  /**
   * build: build method that builds the widget:
   *  set the Scaffold as the parent Widget while its body consists of a
   *  Container widget which lets the cross axis and main axis alignment to be 
   *  at the center. The container widget will hold a Column widget which 
   *  holds the logo and the title of the application.
   * 
   * @param: context
   */

  @override
  Widget build(BuildContext context) {
    RouteCreator route = new RouteCreator(screen: MapScreen());

    Future.delayed(Duration(seconds: this.duration), () {
      Navigator.of(context).push(route.createRoute());
    });
    // TODO: implement build
    return Scaffold(
        body: Container(
      color: Colors.grey[800],
      alignment: Alignment.center,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
                child: Icon(Icons.car_rental_rounded,
                    color: Colors.white, size: 100)),
            const SizedBox(
                height:
                    40), //add spacing between the two widgets (logo and Text)
            const Text(
              'Scalable Parking App',
              style: TextStyle(
                  fontSize: 30, fontFamily: 'UniSans', color: Colors.white),
            )
          ]),
    ));
  }
}
