import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';

class OrderDetailManager {
  String orderId;
  String? note, shippingAddress;
  AppUser? shipper;
  AppUser? manager;
  String status;
  DateTime? orderTime;
  DateTime? acceptTime, deliveryTime, finishTime;
  bool paymentMethod;
  int total, shippingFee;
  AppUser customer;
  List<OrderDetail> orderItems;

  static const String tableName = "customer_order";

  OrderDetailManager({
    required this.orderId,
    required this.customer,
    required this.orderTime,
    this.manager,
    this.shipper,
    this.note,
    required this.shippingAddress,
    required this.status,
    this.acceptTime,
    this.deliveryTime,
    this.finishTime,
    required this.paymentMethod,
    required this.shippingFee,
    required this.total,
    required this.orderItems,
  });

  int get totalPrice {
    return orderItems.fold(
      0,
      (sum, item) => sum + item.amount * item.actualPrice,
    );
  }

  factory OrderDetailManager.fromJson(Map<String, dynamic> json) {
    return OrderDetailManager(
      orderId: json['order_id'],
      customer: AppUser.fromJson(json['customer']),
      status: json['status'],
      note: json['note'],
      shipper:
          json["shipper"] != null ? AppUser.fromJson(json["shipper"]) : null,
      manager:
          json["manager"] != null ? AppUser.fromJson(json["manager"]) : null,
      shippingAddress: json['shipping_address'],
      orderTime:
          json['order_time'] != null
              ? DateTime.parse(json['order_time'])
              : null,
      acceptTime:
          json['accept_time'] != null
              ? DateTime.parse(json['accept_time'])
              : null,
      deliveryTime:
          json['delivery_time'] != null
              ? DateTime.parse(json['delivery_time'])
              : null,
      finishTime:
          json['finish_time'] != null
              ? DateTime.parse(json['finish_time'])
              : null,
      paymentMethod: json['payment_method'],
      total: json['total_amount'] ?? 0,
      shippingFee: json['shipping_fee'],
      orderItems:
          (json['order_detail'] as List)
              .map((e) => OrderDetail.fromJson(e))
              .toList(),
    );
  }
}

class OrderDetailManagerSnapshot {
  OrderDetailManager orderDetailManager;

  OrderDetailManagerSnapshot(this.orderDetailManager);

  static Future<OrderDetailManager?> getOrderDetail({
    required String orderId,
  }) async {
    const select = '''
      *,
      customer:customer_id (*),
       shipper:shipper_id (*),
       manager:manager_id (*),
      order_detail (
        *,
        item:item_id (*)
      )
    ''';

    final res = await SupabaseSnapshot.getList(
      table: OrderDetailManager.tableName,
      fromJson: OrderDetailManager.fromJson,
      selectString: select,
      equalObject: {"order_id": orderId},
    );
    return res.isNotEmpty ? res.first : null;
  }
}
