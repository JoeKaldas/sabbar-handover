import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sabbar/consts/locations.dart';
import 'package:sabbar/consts/logging.dart';
import 'package:sabbar/enums/delivery_status.dart';
import 'package:sabbar/models/order.dart';
import 'package:sabbar/services/json_service.dart';
import 'package:sabbar/services/location_service.dart';

class TrackingController extends GetxController {
  LocationService locationService = LocationService.instance;
  JsonService jsonService = const JsonService();

  GoogleMapController? mapController;

  final _order = Order().obs;

  final _driverMarker = const Marker(markerId: MarkerId("driver")).obs;
  final _pickupMarker = const Marker(markerId: MarkerId("pickup")).obs;
  final _destinationMarker =
      const Marker(markerId: MarkerId("destination")).obs;

  Order get order {
    return _order.value;
  }

  Marker get driverMarker {
    return _driverMarker.value;
  }

  Marker get pickupMarker {
    return _pickupMarker.value;
  }

  Marker get destinationMarker {
    return _destinationMarker.value;
  }

  Future<Uint8List> getMarker(String image) async {
    ByteData byteData = await DefaultAssetBundle.of(Get.context!).load(image);
    return byteData.buffer.asUint8List();
  }

  Set<Marker> get markers {
    return {driverMarker, pickupMarker, destinationMarker};
  }

  void updateMarkerAndCircle(LatLng latLng) async {
    try {
      List<Uint8List> images = await Future.wait([
        getMarker("assets/images/location.png"),
        getMarker("assets/images/pickup.png"),
        getMarker("assets/images/destination.png")
      ]);

      _driverMarker(
        Marker(
          markerId: const MarkerId("driver"),
          position: latLng,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(images[0]),
        ),
      );

      _pickupMarker(
        Marker(
          markerId: const MarkerId("pickup"),
          position: pickupLocation,
          draggable: false,
          zIndex: 1,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(images[1]),
        ),
      );

      _destinationMarker(
        Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation,
          draggable: false,
          zIndex: 1,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(images[2]),
        ),
      );
    } catch (e) {
      logger.e(e);
    }
  }

  void updateLocation() {
    jsonService.fetchData(Get.context!, "assets/json/directions.json").then(
          (data) => locationService.directions(data).listen(
            (LatLng newLocalData) {
              if (mapController != null) {
                mapController!.animateCamera(
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

                if (!order.isStatusFinished(DeliveryStatus.nearPickup)) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, pickupLocation);

                  if (distanceInMeters <= 5000) {
                    order.notifyPickup5Km(Get.context!);
                    _order.update((order) {
                      order?.deliveryStatuses.add(DeliveryStatus.nearPickup);
                    });
                  }
                  return;
                }

                if (!order.isStatusFinished(DeliveryStatus.pickedUp)) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, pickupLocation);

                  if (distanceInMeters <= 100) {
                    order.notifyPickup100m(Get.context!);
                    _order.update((order) {
                      order?.deliveryStatuses.add(DeliveryStatus.pickedUp);
                    });
                  }
                  return;
                }

                if (!order.isStatusFinished(DeliveryStatus.nearDelivery)) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, destinationLocation);

                  if (distanceInMeters <= 5000) {
                    order.notifyDelivery5Km(Get.context!);
                    _order.update((order) {
                      order?.deliveryStatuses.add(DeliveryStatus.nearDelivery);
                    });
                  }
                  return;
                }

                if (!order.isDelivered) {
                  double distanceInMeters = locationService.getDistanceInMeters(
                      newLocalData, destinationLocation);

                  if (distanceInMeters <= 100) {
                    order.notifyDelivery100m(Get.context!);
                    _order.update((order) {
                      order?.deliveryStatuses.add(DeliveryStatus.delivered);
                    });
                  }
                  return;
                }
              }
            },
          ),
        );
  }

  void showSuccessDialog() {
    Get.defaultDialog(
      title: "Success",
      content: const Text("Your rating has been submitted"),
    );
  }
}
