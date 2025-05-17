import 'package:flutter/cupertino.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';

class CustomerOrderInfo {
  final String orderId;
  final String shippingAddress;
  final OrderStatus status;
  final DateTime orderTime;
  final String customerName;
  final String phoneNumber;
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
    final customer = json['app_user'] as Map<String, dynamic>? ?? {};
    final shipper = json['shipper'] as Map<String, dynamic>? ?? {};

    return CustomerOrderInfo(
      orderId: json['order_id']?.toString() ?? '',
      shippingAddress: json['shipping_address']?.toString() ?? '',
      status: OrderStatus.fromString(json['status']?.toString() ?? 'pending'),
      orderTime: DateTime.tryParse(json['order_time']?.toString() ?? '') ?? DateTime.now(),
      customerName: customer['user_name']?.toString() ?? '',
      phoneNumber: customer['phone_number']?.toString() ?? '',
      shipperId: shipper['user_id']?.toString() ?? '',
      shipperName: shipper['user_name']?.toString() ?? '',
      shipperPhone: shipper['phone_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'shipping_address': shippingAddress,
      'status': status.name, // Lưu tên enum thay vì đối tượng
      'order_time': orderTime.toIso8601String(),
      'app_user': {
        'user_name': customerName,
        'phone_number': phoneNumber,
      },
      'shipper': {
        'user_id': shipperId,
        'user_name': shipperName,
        'phone_number': shipperPhone,
      },
    };
  }
}