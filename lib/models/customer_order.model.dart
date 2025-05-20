import 'dart:ffi';

import '../enums/OrderStatus.dart';
import '../helpers/supabase.helper.dart';
import 'order_detail.model.dart';

class CustomerOrder {
  String orderId, customerId;
  String? managerId, shipperId, voucherId, note, shippingAddress;
  String status;
  DateTime? orderTime;
  DateTime? acceptTime, deliveryTime, finishTime;
  bool paymentMethod;
  int total = 0, shippingFee;

  static const String tableName = "customer_order";

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
      status: json["status"],
      paymentMethod: json["payment_method"],
      total: json["total_amount"],
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
      "total_amount": total,
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

  static Future<String> createNewOrder(String customerId) async {
    final orderId = 'OI' + DateTime.now().millisecondsSinceEpoch.toString();
    await supabase.from('customer_order').insert({
      'order_id': orderId,
      'customer_id': customerId,
      'manager_id': null,
      'shipper_id': null,
      'order_time': null,
      'status': 'pending',
      'payment_method': false,
      'total_amount': 0,
      'shipping_fee': 0,
      'note': null,
      'shipping_address': null,
    });
    return orderId;
  }

  // Lấy thông tin sản phẩm trong giỏ hàng
  static Future<Map<String, OrderDetail>> getCartItems(String orderId) async {
    final response = await supabase
        .from('order_detail')
        .select(
          '*, item:item_id(item_id, item_name, item_image, price, description, category_id)',
        )
        .eq('order_id', orderId);

    final Map<String, OrderDetail> items = {};
    for (var item in response) {
      if (item != null) {
        try {
          final orderDetail = OrderDetail.fromJson(item);
          items[orderDetail.itemId] = orderDetail;
        } catch (e) {
          print('Lỗi chuyển item: $e');
        }
      }
    }
    return items;
  }
  //
  // // Cập nhật số lượng sản phẩm trong giỏ hàng
  // static Future<void> updateCartItemAmount(String orderId, String itemId, int newAmount) async {
  //   try {
  //     await supabase
  //         .from('order_detail')
  //         .update({'amount': newAmount})
  //         .eq('order_id', orderId)
  //         .eq('item_id', itemId);
  //
  //     // Cập nhật tổng tiền đơn hàng
  //     await updateOrderTotal(orderId);
  //   } catch (e) {
  //     print('Lỗi cập nhật số lượng trong database: $e');
  //     rethrow;
  //   }
  // }
  //
  // // Xóa sản phẩm khỏi giỏ hàng
  // static Future<void> removeCartItem(String orderId, String itemId) async {
  //   try {
  //     await supabase
  //         .from('order_detail')
  //         .delete()
  //         .eq('order_id', orderId)
  //         .eq('item_id', itemId);
  //
  //     // Cập nhật tổng tiền đơn hàng
  //     await updateOrderTotal(orderId);
  //   } catch (e) {
  //     print('Lỗi xóa sản phẩm khỏi giỏ hàng: $e');
  //     rethrow;
  //   }
  // }

  // // Xóa nhiều sản phẩm khỏi giỏ hàng
  // static Future<void> removeCartItems(String orderId, List<String> itemIds) async {
  //   try {
  //     await supabase
  //         .from('order_detail')
  //         .delete()
  //         .eq('order_id', orderId)
  //         .in_('item_id', itemIds);
  //
  //     // Cập nhật tổng tiền đơn hàng
  //     await updateOrderTotal(orderId);
  //   } catch (e) {
  //     print('Lỗi xóa nhiều sản phẩm khỏi giỏ hàng: $e');
  //     rethrow;
  //   }
  // }

  // // Cập nhật tổng tiền đơn hàng
  // static Future<void> updateOrderTotal(String orderId) async {
  //   try {
  //     final response = await supabase
  //         .from('order_detail')
  //         .select('amount, actual_price')
  //         .eq('order_id', orderId);
  //
  //     int total = 0;
  //     for (var item in response) {
  //       total += item['amount'] * item['actual_price'];
  //     }
  //
  //     await supabase
  //         .from('customer_order')
  //         .update({'total_amount': total})
  //         .eq('order_id', orderId);
  //   } catch (e) {
  //     print('Lỗi cập nhật tổng tiền đơn hàng: $e');
  //     rethrow;
  //   }
  // }
}
