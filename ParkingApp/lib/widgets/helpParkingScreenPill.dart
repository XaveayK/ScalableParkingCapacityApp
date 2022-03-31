import 'package:flutter/material.dart';

class helpParkingScreenPill extends StatelessWidget {
  final String prompt =
      "Swipe left and right to navigate through the parking lots to view which stalls are available (tap the question mark icon to close).";

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
        child: Text(prompt,
            style: TextStyle(
                fontFamily: 'UniSans', color: Colors.white, fontSize: 14)));
    //add child for container here:
  }
}
