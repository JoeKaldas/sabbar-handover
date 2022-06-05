import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:sabbar/consts/colors.dart';
import 'package:sabbar/consts/sizings.dart';
import 'package:sabbar/controllers/tracking_controller.dart';

class TrackingSummaryWidget extends GetView<TrackingController> {
  const TrackingSummaryWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.only(top: 30, bottom: 60),
          child: RatingBar.builder(
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemSize: 50,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: white,
            ),
            unratedColor: deliveryStatusPending,
            onRatingUpdate: (rating) {},
          ),
        ),
        Padding(
          padding: bottomSheetHorizontalPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pickup Time",
                style: Get.context!.textTheme.bodyText1,
              ),
              Text(
                "10:00 PM",
                style: Get.context!.textTheme.bodyText2,
              ),
            ],
          ),
        ),
        const SizedBox(height: bottomSheetRowsSpacing),
        Padding(
          padding: bottomSheetHorizontalPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Time",
                style: Get.context!.textTheme.bodyText1,
              ),
              Text(
                "10:30 PM",
                style: Get.context!.textTheme.bodyText2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 35),
        Padding(
          padding: bottomSheetHorizontalPadding,
          child: Text(
            "Total",
            style: Get.context!.textTheme.bodyText1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: bottomSheetHorizontalSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$30.00",
                style: Get.context!.textTheme.bodyText1?.copyWith(fontSize: 18),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextButton.icon(
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 40),
                    child: Icon(
                      Icons.arrow_back,
                      color: black,
                    ),
                  ),
                  label: const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Submit",
                      style: TextStyle(color: black),
                    ),
                  ),
                  onPressed: () {
                    controller.showSuccessDialog();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 20,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
