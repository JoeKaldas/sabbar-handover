class DeliveryStatus {
  final String name;
  bool isFinished;

  DeliveryStatus({
    required this.name,
    this.isFinished = false,
  });

  updateStatus() {
    isFinished = true;
  }
}
