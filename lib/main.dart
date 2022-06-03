import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:timelines/timelines.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handover',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TrackingScreen(),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late StreamSubscription? _locationSubscription;
  final Location _locationTracker = Location();
  late Marker? marker;
  late Circle? circle;
  late GoogleMapController? _controller;

  static const CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/location.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    setState(() {
      marker = Marker(
        markerId: const MarkerId("home"),
        position: latlng,
        rotation: newLocalData.heading!,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData),
      );
      circle = Circle(
        circleId: const CircleId("car"),
        radius: newLocalData.accuracy!,
        zIndex: 1,
        strokeColor: Colors.blue,
        center: latlng,
        fillColor: Colors.blue.withAlpha(70),
      );
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      _locationTracker.enableBackgroundMode(enable: true);

      bool serviceEnabled;
      PermissionStatus permissionGranted;

      // Checking for permissions;
      serviceEnabled = await _locationTracker.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationTracker.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await _locationTracker.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationTracker.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Get current location
      var location = await _locationTracker.getLocation();
      // Update map UI
      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          // Animate camera to new driver's location
          _controller!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                bearing: 192.8334901395799,
                target: LatLng(newLocalData.latitude!, newLocalData.longitude!),
                tilt: 0,
                zoom: 18.00,
              ),
            ),
          );
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialLocation,
            markers: Set.of((marker != null) ? [marker!] : []),
            circles: Set.of((circle != null) ? [circle!] : []),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
          BottomSheet(
            onClosing: () {
              log("Closing");
            },
            builder: (ctx) => TimelineTile(
              oppositeContents: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('opposite\ncontents'),
              ),
              contents: Card(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('contents'),
                ),
              ),
              node: const TimelineNode(
                indicator: DotIndicator(),
                startConnector: SolidLineConnector(),
                endConnector: SolidLineConnector(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
