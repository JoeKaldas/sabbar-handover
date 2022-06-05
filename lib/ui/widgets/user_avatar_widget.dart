import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabbar/consts/sizings.dart';
import 'package:sabbar/controllers/tracking_controller.dart';

class UserAvatarWidget extends GetView<TrackingController> {
  const UserAvatarWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedPositioned(
        duration: const Duration(seconds: 1),
        left: (Get.size.width - avatarRadius * 2) / 2,
        bottom: controller.order.isDelivered ? 340 : 290,
        child: CircleAvatar(
          radius: avatarRadius,
          backgroundImage: NetworkImage(controller.order.user.image),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
