class CustomerOrderInfo {
  final String orderId;
  final String shippingAddress;
  final String status;
  final DateTime orderTime;
  final String customerName;
  final String phoneNumber;

  // Shipper Info
  final String shipperId;
  final String shipperName;
  final String shipperPhone;

  CustomerOrderInfo({
    required this.orderId,
    required this.shippingAddress,
    required this.status,
    required this.orderTime,
    required this.customerName,
    required this.phoneNumber,
    required this.shipperId,
    required this.shipperName,
    required this.shipperPhone,
  });

  factory CustomerOrderInfo.fromJson(Map<String, dynamic> json) {
    final customer = json['app_user'] ?? {};
    final shipper = json['shipper'];

    return CustomerOrderInfo(
      orderId: json['order_id'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      status: json['status'] ?? '',
      orderTime: DateTime.tryParse(json['order_time'] ?? '') ?? DateTime.now(),
      customerName: customer['user_name'] ?? '',
      phoneNumber: customer['phone_number'] ?? '',
      shipperId: shipper != null ? (shipper['user_id'] ?? '') : '',
      shipperName: shipper != null ? (shipper['user_name'] ?? '') : '',
      shipperPhone: shipper != null ? (shipper['phone_number'] ?? '') : '',
    );
  }
}
