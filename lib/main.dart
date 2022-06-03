import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timelines/timelines.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  Marker? marker;
  Circle? circle;
  GoogleMapController? _controller;
  final LatLng initialLocation = const LatLng(30.0539785, 31.2235324);

  Stream<LatLng> get directions async* {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/json/directions.json");

    Map<String, dynamic> parsedDirections = jsonDecode(data);
    List<LatLng> points = (parsedDirections["points"] as List<dynamic>)
        .map((e) => LatLng(e["lat"], e["lng"]))
        .toList();
    for (var currentLocation in points) {
      yield currentLocation;

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/location.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LatLng latLng, Uint8List imageData) {
    setState(() {
      marker = Marker(
        markerId: const MarkerId("driver"),
        position: latLng,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData),
      );
      // circle = Circle(
      //   circleId: const CircleId("car"),
      //   radius: 5,
      //   zIndex: 1,
      //   strokeColor: Colors.blue,
      //   center: latLng,
      //   fillColor: Colors.blue.withAlpha(70),
      // );
    });
  }

  updateLocation() async {
    Uint8List imageData = await getMarker();

    directions.listen((newLocalData) {
      if (_controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 14,
            ),
          ),
        );
        updateMarkerAndCircle(newLocalData, imageData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 14,
            ),
            markers: Set.of((marker != null) ? [marker!] : []),
            circles: Set.of((circle != null) ? [circle!] : []),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              updateLocation();
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 250,
              child: BottomSheet(
                enableDrag: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.red,
                onClosing: () {
                  log("Closing");
                },
                builder: (ctx) => Timeline(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    TimelineTile(
                      nodeAlign: TimelineNodeAlign.start,
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
                    TimelineTile(
                      nodeAlign: TimelineNodeAlign.start,
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
                    TimelineTile(
                      nodeAlign: TimelineNodeAlign.start,
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
                    TimelineTile(
                      nodeAlign: TimelineNodeAlign.start,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
