import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sabbar/consts/locations.dart';
import 'package:sabbar/controllers/tracking_controller.dart';

class MapWidget extends GetView<TrackingController> {
  const MapWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(seconds: 1),
        height: Get.size.height - (controller.order.isDelivered ? 380 : 330),
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
          markers: controller.markers,
          onMapCreated: (GoogleMapController mapController) {
            controller.mapController = mapController;
            controller.updateLocation();
          },
        ),
      ),
    );
  }
}
