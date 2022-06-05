import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  LocationService._();
  static final instance = LocationService._();

  Stream<LatLng> directions(String data) async* {
    Map<String, dynamic> parsedDirections = jsonDecode(data);
    List<LatLng> points = (parsedDirections["points"] as List<dynamic>)
        .map((e) => LatLng(e["lat"], e["lng"]))
        .toList();
    for (var currentLocation in points) {
      yield currentLocation;

      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
