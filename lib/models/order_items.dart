class OrderDetailWithInfo {
  final String customerName;
  final String phoneNumber;
  final String itemName;
  final int amount;
  final int unitPrice;
  final int subTotal;
  final int shippingFee;
  final String deliveryAddress;

  OrderDetailWithInfo({
    required this.customerName,
    required this.phoneNumber,
    required this.itemName,
    required this.amount,
    required this.unitPrice,
    required this.subTotal,
    required this.shippingFee,
    required this.deliveryAddress,
  });

  factory OrderDetailWithInfo.fromSupabase(Map<String, dynamic> data) {
    return OrderDetailWithInfo(
      customerName: data['user_name'] ?? 'Không có tên',
      phoneNumber: data['phone_number'] ?? 'Không có số điện thoại',
      itemName: data['item_name'] ?? 'Không có tên sản phẩm',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      unitPrice: (data['price'] as num?)?.toInt() ?? 0,
      subTotal: ((data['amount'] as num?)?.toInt() ?? 0) *
          ((data['price'] as num?)?.toInt() ?? 0),
      shippingFee: (data['shipping_fee'] as num?)?.toInt() ?? 0,
      deliveryAddress: data['shipping_address'] ?? 'Không có địa chỉ',
    );
  }
}