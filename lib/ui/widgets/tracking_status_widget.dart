import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:sabbar/consts/colors.dart';
import 'package:sabbar/controllers/tracking_controller.dart';
import 'package:sabbar/enums/delivery_status.dart';
import 'package:sabbar/extensions/list_map_with_index.dart';
import 'package:timelines/timelines.dart';

class TrackingStatusWidget extends GetView<TrackingController> {
  const TrackingStatusWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Timeline(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      children: usedStatuses
          .mapWithIndex(
            (deliveryStatus, index) => TimelineTile(
              nodeAlign: TimelineNodeAlign.start,
              contents: Obx(
                () => Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    top: index == usedStatuses.length - 1 ? 20 : 10,
                    bottom: index == usedStatuses.length - 1 ? 20 : 10,
                    right: 10,
                  ),
                  child: Text(
                    deliveryStatus.name,
                    style: TextStyle(
                      color: controller.order.deliveryStatuses
                              .contains(deliveryStatus)
                          ? black
                          : deliveryStatusPending,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              node: TimelineNode(
                indicator: Obx(
                  () => DotIndicator(
                    size: 7,
                    color: controller.order.deliveryStatuses
                            .contains(deliveryStatus)
                        ? black
                        : deliveryStatusPending,
                  ),
                ),
                startConnector: index == 0
                    ? null
                    : Obx(
                        () => SolidLineConnector(
                          color: controller.order.deliveryStatuses
                                  .contains(deliveryStatus)
                              ? black
                              : deliveryStatusPending,
                        ),
                      ),
                endConnector: index == usedStatuses.length - 1
                    ? null
                    : Obx(
                        () => SolidLineConnector(
                          color: controller.order.deliveryStatuses
                                  .contains(deliveryStatus)
                              ? black
                              : deliveryStatusPending,
                        ),
                      ),
              ),
            ),
          )
          .toList(),
    );
  }
}
