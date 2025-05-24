import 'package:flutter/cupertino.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';

import 'app_user.model.dart';
import 'customer_order.model.dart';

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
      'status': status.name,
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

// class CustomerOrderInfo{
//   CustomerOrder? customerOrder;
//   AppUser? appUser;
//
//   CustomerOrderInfo({
//     this.customerOrder,
//     this.appUser,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'customer_order': this.customerOrder?.toJson(),
//       'app_user': this.appUser?.toJson(),
//
//     };
//   }
//
//   factory CustomerOrderInfo.fromMap(Map<String, dynamic> map){
//     return CustomerOrderInfo(
//       customerOrder: CustomerOrder.fromJson(map['customer_order']) as CustomerOrder,
//       appUser: AppUser.fromJson(map['app_user']) as AppUser,
//     );
//   }
// }