import 'dart:convert';

import 'package:geolocator/geolocator.dart';
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

      // Change this to make navigation faster/slower
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  double getDistanceInMeters(LatLng startPosition, LatLng endPosition) {
    return Geolocator.distanceBetween(
      startPosition.latitude,
      startPosition.longitude,
      endPosition.latitude,
      endPosition.longitude,
    );
  }
}
