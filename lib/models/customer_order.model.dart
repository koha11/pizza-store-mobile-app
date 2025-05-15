import 'dart:ffi';

import '../enums/OrderStatus.dart';
import '../helpers/supabase.helper.dart';

class CustomerOrder {
  String orderId, customerId, shippingAddress;
  String? managerId, shipperId, voucherId, note;
  OrderStatus status = OrderStatus.pending;
  DateTime orderTime;
  DateTime? acceptTime, deliveryTime, finishTime;
  bool paymentMethod;
  int total = 0, shippingFee;

  static String tableName = "customer_order";

  CustomerOrder({
    required this.orderId,
    required this.customerId,
    required this.orderTime,
    this.managerId,
    this.shipperId,
    this.voucherId,
    this.note,
    required this.shippingAddress,
    required this.status,
    this.acceptTime,
    this.deliveryTime,
    this.finishTime,
    required this.paymentMethod,
    required this.shippingFee,
    required this.total,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      orderId: json["order_id"],
      customerId: json["customer_id"],
      managerId: json["manager_id"],
      shipperId: json["shipper_id"],
      voucherId: json["voucher_id"],
      orderTime: json["order_time"],
      acceptTime: json["accept_time"],
      deliveryTime: json["delivery_time"],
      finishTime: json["finish_time"],
      status: json["status"],
      paymentMethod: json["payment_method"],
      total: json["total"],
      shippingFee: json["shipping_fee"],
      shippingAddress: json["shipping_address"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "customer_id": customerId,
      "manager_id": managerId,
      "shipper_id": shipperId,
      "voucher_id": voucherId,
      "order_time": orderTime,
      "accept_time": acceptTime,
      "delivery_time": deliveryTime,
      "finish_time": finishTime,
      "status": status,
      "payment_method": paymentMethod,
      "total": total,
      "shipping_fee": shippingFee,
      "shipping_address": shippingAddress,
    };
  }
}

class CustomerOrderSnapshot {
  CustomerOrder customerOrder;

  CustomerOrderSnapshot(this.customerOrder);

  static Future<List<CustomerOrder>> getOrders() async {
    return SupabaseSnapshot.getList(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
    );
  }

  static Future<Map<String, CustomerOrder>> getMapOrders() {
    return SupabaseSnapshot.getMapT<String, CustomerOrder>(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
      getId: (p0) => p0.orderId,
    );
  }
}