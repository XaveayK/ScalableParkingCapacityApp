import 'package:flutter/material.dart';

class RouteCreator {
  //attributes: Screen widget
  late Widget screen;

  RouteCreator({required this.screen});

  //this method allows transitioning between pages;
  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, seconaryAnimation) => screen,
      transitionsBuilder: (context, animation, seconaryAnimation, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        const curve = Curves.easeInBack;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
