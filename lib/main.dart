import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sabbar/bindings/tracking_binding.dart';
import 'package:sabbar/consts/colors.dart';
import 'package:sabbar/controllers/tracking_controller.dart';
import 'package:sabbar/enums/delivery_status.dart';
import 'package:sabbar/services/local_notification_service.dart';
import 'package:sabbar/ui/widgets/map_widget.dart';
import 'package:sabbar/ui/widgets/tracking_status_widget.dart';
import 'package:sabbar/ui/widgets/tracking_summary_widget.dart';
import 'package:sabbar/ui/widgets/user_avatar_widget.dart';

import 'ui/widgets/name_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await LocalNotificationService().initialize();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Handover',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
        ),
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
      initialBinding: TrackingBinding(),
    );
  }
}

class TrackingScreen extends GetView<TrackingController> {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: black,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const MapWidget(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: controller.order.isDelivered ? 410 : 360,
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
                    padding: const EdgeInsets.only(top: 90),
                    child: Obx(
                      () => ListView(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const NameWidget(),
                          controller.order.isDelivered
                              ? const TrackingSummaryWidget()
                              : const TrackingStatusWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const UserAvatarWidget(),
        ],
      ),
    );
  }
}
