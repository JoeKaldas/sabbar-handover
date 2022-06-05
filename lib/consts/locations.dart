import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sabbar/models/delivery_status.dart';

const LatLng initialLocation = LatLng(30.0477386, 31.2622538);
const LatLng pickupLocation = LatLng(30.0663435, 31.218413799999997);
const LatLng destinationLocation = LatLng(30.024287899999997, 31.216787);

final List<DeliveryStatus> deliveryStatuses = [
  DeliveryStatus(name: "On the way", isFinished: true),
  DeliveryStatus(name: "Picked up delivery"),
  DeliveryStatus(name: "Near delivery destination"),
  DeliveryStatus(name: "Delivered package"),
];
