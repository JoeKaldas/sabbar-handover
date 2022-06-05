enum DeliveryStatus {
  onTheWay,
  nearPickup,
  pickedUp,
  nearDelivery,
  delivered,
}

List<DeliveryStatus> get usedStatuses {
  return [
    DeliveryStatus.onTheWay,
    DeliveryStatus.pickedUp,
    DeliveryStatus.nearDelivery,
    DeliveryStatus.delivered,
  ];
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get name {
    switch (this) {
      case DeliveryStatus.onTheWay:
        return 'On the way';
      case DeliveryStatus.pickedUp:
        return 'Picked up delivery';
      case DeliveryStatus.nearDelivery:
        return 'Near delivery destination';
      case DeliveryStatus.delivered:
        return 'Delivered package';
      default:
        return "";
    }
  }
}
