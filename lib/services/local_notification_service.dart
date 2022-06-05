import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sabbar/consts/logging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails("com.example.sabbar", "com.example.sabbar");
  static const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    badgeNumber: 1,
  );

  static const NotificationDetails platformChannelSpecifics =
      NotificationDetails(
    android: LocalNotificationService.androidPlatformChannelSpecifics,
    iOS: LocalNotificationService.iOSPlatformChannelSpecifics,
  );

  Future initialize() async {
    // Local notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_notification_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: selectNotification,
    );
  }

  static void showLocalNotification({
    required String title,
    required String message,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      message,
      // tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
      platformChannelSpecifics,
    );
  }

  // Clicked on local notification
  void selectNotification(String? payload) async {
    logger.i('notification payload select notification');
    if (payload != null) {
      logger.i('notification payload select notification: $payload');
    }
  }

  // iOS received local notification
  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    logger.i('notification payload on did receive local notification:');
    if (payload != null) {
      logger.i(
          'notification payload on did receive local notification: $payload');
    }
    // Modals.showDialog(
    //   child: MessageScreen(
    //     fullScreen: false,
    //     opaqueBg: false,
    //     bgColor: Styling.kColorScheduleYellow,
    //     title: title ?? "",
    //     titleColor: Styling.kColorBlue,
    //     message: body ?? "",
    //     messageColor: Styling.kColorBlue,
    //     buttonText: "Ok",
    //     buttonTextColor: Styling.kColorBlue,
    //     buttonFunction: () {
    //       if (Get.isDialogOpen ?? false) {
    //         Get.back();
    //       }
    //     },
    //   ),
    // );
  }
}
