import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sabbar/controllers/tracking_controller.dart';

class NameWidget extends GetView<TrackingController> {
  const NameWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Text(
        controller.order.user.name,
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }
}
