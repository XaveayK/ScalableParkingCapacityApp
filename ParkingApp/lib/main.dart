// ignore_for_file: empty_constructor_bodies

import 'package:flutter/material.dart';

import 'package:google_maps_in_flutter/screens/LoadingScreen.dart';
import 'package:google_maps_in_flutter/screens/MapScreen.dart';

void main() {
  //runApp(const MyApp());

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(duration: 2, goToPage: MapScreen())));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        fontFamily: "UniSans",
      ),
      home: MapScreen(),
    );
  }
}
