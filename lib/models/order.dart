import 'package:flutter/material.dart';
import 'package:sabbar/services/local_notification_service.dart';

class Order {
  bool didNotifyPickup5km = false;
  bool didNotifyPickup100m = false;
  bool didNotifyDelivery5km = false;
  bool didNotifyDelivery100m = false;

  notifyPickup5Km(BuildContext context) {
    didNotifyPickup5km = true;

    LocalNotificationService.showLocalNotification(
      context: context,
      id: 1,
      title: "Just an update",
      message: "Driver is near the pickup destination",
    );
  }

  notifyPickup100m(BuildContext context) {
    didNotifyPickup100m = true;

    LocalNotificationService.showLocalNotification(
      context: context,
      id: 2,
      title: "Just an update",
      message: "Driver has arrived to pickup destination",
    );
  }

  notifyDelivery5Km(BuildContext context) {
    didNotifyDelivery5km = true;

    LocalNotificationService.showLocalNotification(
      context: context,
      id: 3,
      title: "Just an update",
      message: "Driver is near the delivery destination",
    );
  }

  notifyDelivery100m(BuildContext context) {
    didNotifyDelivery100m = true;

    LocalNotificationService.showLocalNotification(
      context: context,
      id: 4,
      title: "Just an update",
      message: "Driver has arrived to delivery destination",
    );
  }
}
