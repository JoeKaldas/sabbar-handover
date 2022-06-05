import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sabbar/consts/colors.dart';
import 'package:sabbar/consts/locations.dart';
import 'package:sabbar/consts/logging.dart';
import 'package:sabbar/consts/spacings.dart';
import 'package:sabbar/extensions/list_map_with_index.dart';
import 'package:sabbar/models/order.dart';
import 'package:sabbar/services/json_service.dart';
import 'package:sabbar/services/location_service.dart';
import 'package:sabbar/services/local_notification_service.dart';
import 'package:timelines/timelines.dart';

import 'ui/widgets/name_widget.dart';

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
        textTheme: const TextTheme(
          headline2: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: black,
          ),
          bodyText1: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: black,
          ),
          bodyText2: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: black,
          ),
        ),
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

  Order order = Order();

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
          zIndex: 1,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(images[1]),
        );

        destinationMarker ??= Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation,
          draggable: false,
          zIndex: 1,
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
            (LatLng newLocalData) {
              if (_controller != null) {
                _controller!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        newLocalData.latitude,
                        newLocalData.longitude,
                      ),
                      zoom: 12,
                    ),
                  ),
                );
                updateMarkerAndCircle(newLocalData);

                if (!order.didNotifyPickup5km) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, pickupLocation);

                  if (distanceInMeters <= 5000 && !order.didNotifyPickup5km) {
                    order.notifyPickup5Km(context);
                  }
                  return;
                }

                if (!order.didNotifyPickup100m) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, pickupLocation);

                  if (distanceInMeters <= 100 && !order.didNotifyPickup100m) {
                    order.notifyPickup100m(context);
                    deliveryStatuses[1].updateStatus();
                  }
                  return;
                }

                if (!order.didNotifyDelivery5km) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, destinationLocation);

                  if (distanceInMeters <= 5000 && !order.didNotifyDelivery5km) {
                    order.notifyDelivery5Km(context);
                    deliveryStatuses[2].updateStatus();
                  }
                  return;
                }

                if (!order.didNotifyDelivery100m) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, destinationLocation);

                  if (distanceInMeters <= 100 && !order.didNotifyDelivery100m) {
                    order.notifyDelivery100m(context);
                    deliveryStatuses[3].updateStatus();
                  }
                  return;
                }
              }
            },
          ),
        );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const AlertDialog(
        title: Text("Success"),
        content: Text("Your rating has been submitted"),
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
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
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
                zoom: 12,
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
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: order.didNotifyDelivery100m ? 400 : 350,
              child: BottomSheet(
                enableDrag: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                backgroundColor: yellow,
                onClosing: () {},
                builder: (ctx) => Container(
                  padding: const EdgeInsets.only(top: 70),
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const NameWidget(),
                      if (order.didNotifyDelivery100m)
                        ...finishedDeliveryWidgets
                      else
                        Timeline(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(20),
                          physics: const NeverScrollableScrollPhysics(),
                          children: deliveryStatuses
                              .mapWithIndex(
                                (deliveryStatus, index) => TimelineTile(
                                  nodeAlign: TimelineNodeAlign.start,
                                  contents: Container(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      top: index == deliveryStatuses.length - 1
                                          ? 20
                                          : 10,
                                      bottom:
                                          index == deliveryStatuses.length - 1
                                              ? 20
                                              : 10,
                                      right: 10,
                                    ),
                                    child: Text(
                                      deliveryStatus.name,
                                      style: TextStyle(
                                        color: deliveryStatus.isFinished
                                            ? black
                                            : deliveryStatusPending,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  node: TimelineNode(
                                    indicator: DotIndicator(
                                      size: 7,
                                      color: deliveryStatus.isFinished
                                          ? black
                                          : deliveryStatusPending,
                                    ),
                                    startConnector: index == 0
                                        ? null
                                        : SolidLineConnector(
                                            color: deliveryStatus.isFinished
                                                ? black
                                                : deliveryStatusPending,
                                          ),
                                    endConnector:
                                        index == deliveryStatuses.length - 1
                                            ? null
                                            : SolidLineConnector(
                                                color: deliveryStatus.isFinished
                                                    ? black
                                                    : deliveryStatusPending,
                                              ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            left: (MediaQuery.of(context).size.width - 120) / 2,
            bottom: order.didNotifyDelivery100m ? 350 : 300,
            child: const CircleAvatar(
              radius: 60.0,
              backgroundImage: NetworkImage(
                  'https://www.w3schools.com/howto/img_avatar.png'),
              backgroundColor: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> get finishedDeliveryWidgets {
    return [
      Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 30, bottom: 60),
        child: RatingBar.builder(
          direction: Axis.horizontal,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemSize: 50,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: white,
          ),
          unratedColor: deliveryStatusPending,
          onRatingUpdate: (rating) {},
        ),
      ),
      Padding(
        padding: bottomSheetHorizontalPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pickup Time",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              "10:00 PM",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
      const SizedBox(height: bottomSheetRowsSpacing),
      Padding(
        padding: bottomSheetHorizontalPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Delivery Time",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              "10:30 PM",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
      const SizedBox(height: 35),
      Padding(
        padding: bottomSheetHorizontalPadding,
        child: Text(
          "Total",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: bottomSheetHorizontalSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "\$30.00",
              style:
                  Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextButton.icon(
                icon: const Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: Icon(
                    Icons.arrow_back,
                    color: black,
                  ),
                ),
                label: const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: black),
                  ),
                ),
                onPressed: () {
                  showSuccessDialog();
                },
                style: TextButton.styleFrom(
                  backgroundColor: white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ];
  }
}
