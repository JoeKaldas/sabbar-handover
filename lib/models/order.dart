import 'package:sabbar/services/local_notification_service.dart';

class Order {
  bool didNotifyPickup5km = false;
  bool didNotifyPickup100m = false;
  bool didNotifyDelivery5km = false;
  bool didNotifyDelivery100m = false;

  notifyPickup5Km() {
    didNotifyPickup5km = true;

    LocalNotificationService.showLocalNotification(
      title: "Just an update",
      message: "Driver is near the pickup destination",
    );
  }

  notifyPickup100m() {
    didNotifyPickup100m = true;

    LocalNotificationService.showLocalNotification(
      title: "Just an update",
      message: "Driver has arrived to pickup destination",
    );
  }

  notifyDelivery5Km() {
    didNotifyDelivery5km = true;

    LocalNotificationService.showLocalNotification(
      title: "Just an update",
      message: "Driver is near the delivery destination",
    );
  }

  notifyDelivery100m() {
    didNotifyDelivery100m = true;

    LocalNotificationService.showLocalNotification(
      title: "Just an update",
      message: "Driver has arrived to delivery destination",
    );
  }
}
