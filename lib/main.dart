import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sabbar/consts/colors.dart';
import 'package:sabbar/consts/locations.dart';
import 'package:sabbar/consts/logging.dart';
import 'package:sabbar/services/json_service.dart';
import 'package:sabbar/services/location_service.dart';
import 'package:sabbar/services/local_notification_service.dart';
import 'package:timelines/timelines.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService().initialize();

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
  LocationService locationService = LocationService.instance;
  JsonService jsonService = const JsonService();

  Marker? driverMarker;
  Marker? pickupMarker;
  Marker? destinationMarker;

  GoogleMapController? _controller;

  Future<Uint8List> getMarker(String image) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(image);
    return byteData.buffer.asUint8List();
  }

  Set<Marker> get markers {
    Set<Marker> mapMarkers = {};
    if (driverMarker != null) {
      mapMarkers.add(driverMarker!);
    }
    if (pickupMarker != null) {
      mapMarkers.add(pickupMarker!);
    }
    if (destinationMarker != null) {
      mapMarkers.add(destinationMarker!);
    }

    return mapMarkers;
  }

  void updateMarkerAndCircle(LatLng latLng) async {
    try {
      List<Uint8List> images = await Future.wait([
        getMarker("assets/images/location.png"),
        getMarker("assets/images/pickup.png"),
        getMarker("assets/images/destination.png")
      ]);

      setState(() {
        driverMarker = Marker(
          markerId: const MarkerId("driver"),
          position: latLng,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(images[0]),
        );

        pickupMarker ??= Marker(
          markerId: const MarkerId("pickup"),
          position: pickupLocation,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(images[1]),
        );

        destinationMarker ??= Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(images[2]),
        );
      });
    } catch (e) {
      logger.e(e);
    }
  }

  updateLocation() {
    jsonService.fetchData(context, "assets/json/directions.json").then(
          (data) => locationService.directions(data).listen(
            (newLocalData) {
              if (_controller != null) {
                _controller!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        newLocalData.latitude,
                        newLocalData.longitude,
                      ),
                      zoom: 12.5,
                    ),
                  ),
                );
                updateMarkerAndCircle(newLocalData);
              }
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              myLocationButtonEnabled: false,
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  northeast: pickupLocation,
                  southwest: destinationLocation,
                ),
              ),
              initialCameraPosition: const CameraPosition(
                target: pickupLocation,
                zoom: 12.5,
              ),
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                updateLocation();
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheet(
              enableDrag: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              backgroundColor: yellow,
              onClosing: () {},
              builder: (ctx) => SizedBox(
                height: 100,
                child: Timeline(
                  physics: const NeverScrollableScrollPhysics(),
                  children: deliveryStatuses
                      .map(
                        (deliveryStatus) => TimelineTile(
                          nodeAlign: TimelineNodeAlign.start,
                          contents: Card(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(deliveryStatus.name),
                            ),
                          ),
                          node: const TimelineNode(
                            indicator: DotIndicator(),
                            startConnector: SolidLineConnector(),
                            endConnector: SolidLineConnector(),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
