import 'package:google_maps_flutter/google_maps_flutter.dart';

/*
  Map Marker Model:

  This object holds the data for:
    -title: name of the landmark
    -location: in LatLng object; holds latitude and longitude 

*/
class MapMarker {
  const MapMarker({required this.title, required this.location});
  final String title;
  final LatLng location;
}

//test models:
final _locations = [LatLng(53.5225, -113.6242), LatLng(53.4856, -113.5137)];

final mapMarkers = [
  MapMarker(
    title: 'West Edmonton Mall',
    location: _locations[0],
  ),
  MapMarker(
    title: 'Southgate',
    location: _locations[1],
  )
];
