import 'package:get/get.dart';
import 'package:sabbar/controllers/tracking_controller.dart';

class TrackingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TrackingController>(TrackingController());
  }
}
