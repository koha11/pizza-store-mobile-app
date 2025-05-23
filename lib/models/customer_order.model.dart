import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/models/Item.model.dart';

import '../enums/OrderStatus.dart';
import '../helpers/supabase.helper.dart';
import 'order_detail.model.dart';

class CustomerOrder {
  String orderId, customerId;
  String? managerId, shipperId, note, shippingAddress;
  OrderStatus status;
  DateTime? orderTime;
  DateTime? acceptTime, deliveryTime, finishTime;
  bool paymentMethod;
  int totalAmount = 0, shippingFee;

  static const String tableName = "customer_order";

  CustomerOrder({
    required this.orderId,
    required this.customerId,
    required this.orderTime,
    this.managerId,
    this.shipperId,
    this.note,
    required this.shippingAddress,
    required this.status,
    required this.totalAmount,
    this.acceptTime,
    this.deliveryTime,
    this.finishTime,
    required this.paymentMethod,
    required this.shippingFee,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      orderId: json["order_id"],
      customerId: json["customer_id"],
      managerId: json["manager_id"],
      shipperId: json["shipper_id"],
      totalAmount: (json["total_amount"] as num).toInt() ?? 0,
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
      shippingFee: (json["shipping_fee"] as num).toInt(),
      shippingAddress: json["shipping_address"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "customer_id": customerId,
      "manager_id": managerId,
      "shipper_id": shipperId,
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

  static Future<String?> getCustomerCart(String customerId) async {
    final cart = await SupabaseSnapshot.getList(
      table: CustomerOrder.tableName,
      fromJson: CustomerOrder.fromJson,
      equalObject: {"customer_id": customerId, "status": OrderStatus.cart.name},
    );

    return cart.isEmpty ? null : cart.first.orderId;
  }

  static Future<String> createNewOrder(String customerId) async {
    final orderId = "OI${customerId}";
    await supabase.from('customer_order').insert({
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
    return orderId;
  }

  static Future<String> placeOrder({
    required String customerId,
    required String address,
    required int shippingFee,
    required int totalAmount,
  }) async {
    final orderId = await generateId(tableName: CustomerOrder.tableName);
    //final orderId = 'OI' + DateTime.now().millisecondsSinceEpoch.toString();
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

  // cập nhật trạng thái
  static Future<void> updateOrderStatus(String orderId, String status) async {
    await supabase
        .from('customer_order')
        .update({'status': status})
        .eq('order_id', orderId);
  }

  static Future<void> updateOrderStatusAndTotal(
    String orderId,
    OrderStatus status,
    int totalAmount,
    int Shipfree,
  ) async {
    await supabase
        .from('customer_order')
        .update({
          'status': status,
          'total_amount': totalAmount,
          'shipping_fee': Shipfree,
        })
        .eq('order_id', orderId);
  }

  // Lấy thông tin sản phẩm trong giỏ hàng
  static Future<Map<String, OrderDetail>> getCartItems(String orderId) async {
    final items = await SupabaseSnapshot.getMapT<String, OrderDetail>(
      table: OrderDetail.tableName,
      fromJson: OrderDetail.fromJson,
      selectString: "*, item(*)",
      equalObject: {"order_id": orderId},
      getId: (p0) => p0.itemId,
    );

    // final Map<String, OrderDetail> items = {};
    // for (var item in response) {
    //   try {
    //     final orderDetail = OrderDetail.fromJson(item);
    //     items[orderDetail.itemId] = orderDetail;
    //   } catch (e) {
    //     print('Lỗi chuyển item: $e');
    //   }
    // }
    return items;
  }

  static Future<void> addItemToCart(
    String orderId,
    Item item,
    int amount,
  ) async {
    try {
      await supabase.from('order_detail').insert({
        'order_id': orderId,
        'item_id': item.itemId,
        'amount': amount,
        'actual_price': item.price * amount,
        'note': null,
      });
    } catch (e) {
      print('Lỗi thêm sản phẩm vào giỏ hàng: $e');
      rethrow;
    }
  }

  // // tính tiền
  // static Future<void> updateOrderTotal(String orderId, int total) async {
  //   await supabase
  //       .from('customer_order')
  //       .update({'total_amount': total})
  //       .eq('order_id', orderId);
  // }
  //
  // Phương thức cập nhật số lượng sản phẩm trong giỏ hàng
  // static Future<void> updateCartItemAmount({required String orderId,
  //   required String itemId,
  //   required int newAmount,}) async {
  //   try {
  //     await SupabaseSnapshot.update(
  //         table: OrderDetail.tableName,
  //         updateObject: {
  //           'total_amount': new
  //         });
  //     // await supabase
  //     //     .from('order_detail')
  //     //     .update({'amount': newAmount})
  //     //     .eq('order_id', orderId)
  //     //     .eq('item_id', itemId);
  //   } catch (e) {
  //     print('Lỗi cập nhật số lượng trong database: $e');
  //     rethrow;
  //   }
  // }
}
