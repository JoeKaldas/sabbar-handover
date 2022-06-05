import 'package:flutter/material.dart';
import 'package:sabbar/enums/delivery_status.dart';
import 'package:sabbar/models/user.dart';
import 'package:sabbar/services/local_notification_service.dart';

class Order {
  final User user = User(
      name: "Mohamed Abdullah",
      image: "https://www.w3schools.com/howto/img_avatar.png");
  final List<DeliveryStatus> deliveryStatuses = [
    DeliveryStatus.onTheWay,
  ];

  bool isStatusFinished(DeliveryStatus status) {
    return deliveryStatuses.contains(status);
  }

  bool get isDelivered {
    return deliveryStatuses.contains(DeliveryStatus.delivered);
  }

  notifyPickup5Km(BuildContext context) {
    LocalNotificationService.showLocalNotification(
      context: context,
      id: 1,
      title: "Just an update",
      message: "Driver is near the pickup destination",
    );
  }

  notifyPickup100m(BuildContext context) {
    LocalNotificationService.showLocalNotification(
      context: context,
      id: 2,
      title: "Just an update",
      message: "Driver has arrived to pickup destination",
    );
  }

  notifyDelivery5Km(BuildContext context) {
    LocalNotificationService.showLocalNotification(
      context: context,
      id: 3,
      title: "Just an update",
      message: "Driver is near the delivery destination",
    );
  }

  notifyDelivery100m(BuildContext context) {
    LocalNotificationService.showLocalNotification(
      context: context,
      id: 4,
      title: "Just an update",
      message: "Driver has arrived to delivery destination",
    );
  }
}
