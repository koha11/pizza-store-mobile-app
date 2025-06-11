import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/order_variant.model.dart';
import 'package:pizza_store_app/widgets/ShowSnackbar.dart';

import '../enums/OrderStatus.dart';
import '../helpers/supabase.helper.dart';
import 'order_detail.model.dart';

class CustomerOrder {
  String orderId;
  String customerId;
  String? managerId, shipperId;
  AppUser? customer;
  AppUser? manager, shipper;
  String? note = "", shippingAddress = "";
  OrderStatus status;
  DateTime? orderTime, acceptTime, deliveryTime, finishTime;
  bool paymentMethod = false;
  int? shippingFee, totalAmount = 0;
  List<OrderDetail>? orderDetails = [];
  int? total;

  static const String tableName = "customer_order";
  static const String selectAllStr =
      "*, "
      "customer:customer_id (*), "
      "manager:manager_id (*), "
      "shipper:shipper_id (*), "
      "order_detail(*, item:item_id (*, category:category_id (*))), "
      "order_variant(*, variant:variant_id(*, variant_type:variant_type_id(*)))";

  CustomerOrder({
    required this.orderId,
    required this.customer,
    required this.status,
    this.orderTime,
    this.manager,
    this.shipper,
    this.note,
    required this.customerId,
    this.managerId,
    this.shipperId,
    this.shippingAddress,
    this.totalAmount,
    this.acceptTime,
    this.deliveryTime,
    this.finishTime,
    required this.paymentMethod,
    this.shippingFee,
    this.total,
    this.orderDetails,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    List<dynamic> orderDetailsJson = json["order_detail"] ?? [];
    List<dynamic> orderVariantsJson =
        json["order_variant"] ?? []; // list cac order_variant

    List<OrderDetail> orderDetails =
        orderDetailsJson.isEmpty
            ? []
            : orderDetailsJson
                .map((odJson) => OrderDetail.fromJson(odJson))
                .toList();

    List<OrderVariant> orderVariants =
        orderVariantsJson.isEmpty
            ? []
            : orderVariantsJson.map((ov) => OrderVariant.fromJson(ov)).toList();

    if (orderDetails.isNotEmpty && orderVariants.isNotEmpty) {
      for (var ov in orderVariants) {
        OrderDetail od = orderDetails.firstWhere(
          (od) => od.itemId == ov.itemId,
        );

        final key = ov.variant!.variantTypeId;

        if (od.variantMaps.containsKey(key)) {
          od.variantMaps[key]!.add(ov.variant!);
        } else {
          od.variantMaps.assign(key, [ov.variant!]);
        }
      }
    }

    return CustomerOrder(
      orderId: json["order_id"],
      customer:
          json["customer"] == null ? null : AppUser.fromJson(json["customer"]),
      customerId: json["customer_id"],
      managerId: json["manager_id"],
      shipperId: json["shipper_id"],
      manager:
          json["manager"] == null ? null : AppUser.fromJson(json["manager"]),
      shipper:
          json["shipper"] == null ? null : AppUser.fromJson(json["shipper"]),
      totalAmount:
          json["shipper"] == null ? 0 : (json["total_amount"] as num).toInt(),
      orderTime:
          json["order_time"] != null
              ? DateTime.parse(json["order_time"])
              : null,
      acceptTime:
          json["accept_time"] != null
              ? DateTime.parse(json["accept_time"])
              : null,
      deliveryTime:
          json["delivery_time"] != null
              ? DateTime.parse(json["delivery_time"])
              : null,
      finishTime:
          json["finish_time"] != null
              ? DateTime.parse(json["finish_time"])
              : null,
      status: OrderStatus.fromString(json["status"]),
      paymentMethod: json["payment_method"],
      shippingFee:
          json["shipping_fee"] == null
              ? 0
              : (json["shipping_fee"] as num).toInt(),
      shippingAddress: json["shipping_address"],
      orderDetails: orderDetails,
      total: orderDetails.fold(
        0,
        (sum, item) => (sum ?? 0) + item.amount * item.actualPrice,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "customer": customer?.toJson(),
      "manager": manager?.toJson(),
      "shipper": shipper?.toJson(),
      "order_time": orderTime,
      "accept_time": acceptTime,
      "delivery_time": deliveryTime,
      "finish_time": finishTime,
      "status": status.name,
      "total_amount": totalAmount,
      "payment_method": paymentMethod,
      "shipping_fee": shippingFee,
      "shipping_address": shippingAddress,
    };
  }
}

class CustomerOrderSnapshot {
  CustomerOrder customerOrder;

  CustomerOrderSnapshot(this.customerOrder);

  static Stream<List<CustomerOrder>> getOrdersStream() {
    return getDataStream(
      table: CustomerOrder.tableName,
      ids: ["order_id"],
      fromJson: CustomerOrder.fromJson,
    );
  }

  static Future<List<CustomerOrder>> getOrdersByCurrentMonthAndYear() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstDayOfNextMonth =
        (now.month == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
    List<CustomerOrder> orders = await CustomerOrderSnapshot.getOrders(
      ltObject: {"order_time": firstDayOfNextMonth.toIso8601String()},
      gtObject: {"order_time": firstDayOfMonth.toIso8601String()},
    );
    return orders;
  }

  static Future<Map<int, int>> groupDataToStatisticChart() async {
    Map<int, int> dailyRevenue = {};

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstDayOfNextMonth =
        (now.month == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
    List<CustomerOrder> orders = await CustomerOrderSnapshot.getOrders(
      ltObject: {"order_time": firstDayOfNextMonth.toIso8601String()},
      gtObject: {"order_time": firstDayOfMonth.toIso8601String()},
      orObject: [
        {"status": OrderStatus.pending.name},
        {"status": OrderStatus.finished.name},
        {"status": OrderStatus.confirmed.name},
        {"status": OrderStatus.shipping.name},
      ],
    );
    for (CustomerOrder order in orders) {
      final orderTime = order.orderTime;
      if (orderTime == null || order.status.name != OrderStatus.finished.name)
        continue;
      final day = orderTime.day;
      dailyRevenue[day] = (dailyRevenue[day] ?? 0) + (order.total ?? 0);
    }
    return dailyRevenue;
  }

  static Future<Map<String, int>> getOrderSummaryStatistic() async {
    Map<String, int> summary = {
      "totalOrder": 0,
      "totalProcessingOrder": 0,
      "totalRevenue": 0,
    };
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstDayOfNextMonth =
        (now.month == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
    List<CustomerOrder> ordersToday = await CustomerOrderSnapshot.getOrders(
      ltObject: {"order_time": firstDayOfNextMonth.toIso8601String()},
      gtObject: {"order_time": firstDayOfMonth.toIso8601String()},
      orObject: [
        {"status": OrderStatus.pending.name},
        {"status": OrderStatus.finished.name},
        {"status": OrderStatus.confirmed.name},
        {"status": OrderStatus.shipping.name},
      ],
    );
    for (CustomerOrder order in ordersToday) {
      summary["totalOrder"] = (summary["totalOrder"] ?? 0) + 1;
      if (order.status.name == OrderStatus.pending.name) {
        summary["totalProcessingOrder"] =
            (summary["totalProcessingOrder"] ?? 0) + 1;
      } else if (order.status.name == OrderStatus.finished.name) {
        summary["totalRevenue"] = (summary["totalRevenue"] ?? 0) + order.total!;
      }
    }
    return summary;
  }

  static Future<CustomerOrder?> getOrderDetail({
    required String orderId,
  }) async {
    final res = await SupabaseSnapshot.getList(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
      selectString: CustomerOrder.selectAllStr,
      equalObject: {"order_id": orderId},
    );
    return res.isNotEmpty ? res.first : null;
  }

  static Future<void> assignShipperToOrder({
    required String orderId,
    required String shipperId,
    required String managerId,
  }) async {
    await SupabaseSnapshot.update(
      table: CustomerOrder.tableName,
      updateObject: {
        "shipper_id": shipperId,
        "accept_time": DateTime.now().toIso8601String(),
        "manager_id": managerId,
        "status": OrderStatus.confirmed.name,
      },
      equalObject: {"order_id": orderId},
    );
  }

  static Future<List<CustomerOrder>> getOrders({
    Map<String, String>? equalObject,
    List<Map<String, dynamic>>? orObject,
    Map<String, bool>? sortObject,
    Map<String, String>? gtObject,
    Map<String, String>? ltObject,
  }) async {
    List<CustomerOrder> orders = await SupabaseSnapshot.getList<CustomerOrder>(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
      equalObject: equalObject,
      orObject: orObject,
      selectString: CustomerOrder.selectAllStr,
      gtObject: gtObject,
      ltObject: ltObject,
      sortObject: sortObject,
    );

    return orders;
  }

  static Future<void> deletePendingOrder(CustomerOrder order) async {
    if (order.status != OrderStatus.pending) {
      showSnackBar(
        desc: "Khong duoc phep xoa don hang ko phai dang cho",
        success: false,
      );
    } else {
      await SupabaseSnapshot.delete(
        table: AppUser.tableName,
        equalObject: {"order_id": order.orderId},
      );
    }
  }

  static Future<Map<String, CustomerOrder>> getMapOrders() {
    return SupabaseSnapshot.getMapT<String, CustomerOrder>(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
      getId: (p0) => p0.orderId,
      selectString: CustomerOrder.selectAllStr,
    );
  }

  static Future<CustomerOrder?> getOrderById(String orderId) {
    return SupabaseSnapshot.getById(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
      idKey: "order_id",
      idValue: orderId,
      selectString: CustomerOrder.selectAllStr,
    );
  }

  static Future<CustomerOrder?> getCustomerCart(String customerId) async {
    final cart = await SupabaseSnapshot.getList(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
      equalObject: {"customer_id": customerId, "status": OrderStatus.cart.name},
      selectString: CustomerOrder.selectAllStr,
    );

    return cart.isEmpty ? null : cart.first;
  }

  static Future<CustomerOrder> createNewOrder(String customerId) async {
    final orderId = "OI-$customerId";
    final order = await supabase.from('customer_order').insert({
      'order_id': orderId,
      'customer_id': customerId,
      'manager_id': null,
      'shipper_id': null,
      'order_time': null,
      'status': OrderStatus.cart.name,
      'payment_method': false,
      'total_amount': 0,
      'shipping_fee': 0,
      'note': null,
      'shipping_address': null,
    });

    return order;
  }

  static Future<String> createOrder({
    required String customerId,
    required String address,
    required int shippingFee,
    required int totalAmount,
  }) async {
    final orderId = await generateId(tableName: CustomerOrder.tableName);

    await supabase.from('customer_order').insert({
      'order_id': orderId,
      'customer_id': customerId,
      'order_time': DateTime.now().toIso8601String(),
      'status': OrderStatus.pending.name,
      'payment_method': false,
      'shipping_fee': shippingFee,
      'shipping_address': address,
      'total_amount': totalAmount,
    });

    return orderId;
  }

  static Future<void> addItemToCart(
    String orderId,
    Item item,
    int amount,
    int actualPrice,
  ) async {
    try {
      await SupabaseSnapshot.insert(
        table: OrderDetail.tableName,
        insertObject: {
          'order_id': orderId,
          'item_id': item.itemId,
          'amount': amount,
          'actual_price': actualPrice,
          'note': null,
        },
      );
    } catch (e) {
      print('Lỗi thêm sản phẩm vào giỏ hàng: $e');
      throw e;
    }
  }
}
