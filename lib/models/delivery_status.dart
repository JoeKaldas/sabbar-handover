class DeliveryStatus {
  final String name;
  bool status = false;

  DeliveryStatus({required this.name});

  updateStatus() {
    status = true;
  }
}
