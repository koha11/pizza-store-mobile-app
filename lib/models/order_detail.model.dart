import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';

import '../helpers/supabase.helper.dart';
import 'Item.model.dart';

class OrderDetail {
  String orderId, itemId;
  String? variantId;
  Map<String, Variant>? variantMaps;
  int amount, actualPrice;
  String? note;
  Item item;

  static String tableName = "order_detail";

  OrderDetail({
    required this.orderId,
    required this.itemId,
    required this.amount,
    this.note,
    required this.actualPrice,
    required this.item,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json["order_id"],
      itemId: json["item_id"],
      amount: json["amount"],
      actualPrice: json["actual_price"],
      note: json["note"],
      item: Item.fromJson(json["item"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "item_id": itemId,
      "amount": amount,
      "note": note,
      "actual_price": actualPrice,
    };
  }
}

class OrderDetailSnapshot {
  OrderDetail orderDetail;

  OrderDetailSnapshot(this.orderDetail);

  static Future<List<OrderDetail>> getOrderDetails() async {
    return SupabaseSnapshot.getList(
      table: OrderDetail.tableName,
      fromJson: OrderDetail.fromJson,
      selectString: "*, item(*)",
    );
  }

  static Future<Map<String, OrderDetail>> getMapOrderDetails() {
    return SupabaseSnapshot.getMapT<String, OrderDetail>(
      table: OrderDetail.tableName,
      fromJson: OrderDetail.fromJson,
      getId: (p0) => p0.orderId,
      selectString: "*, item(*)",
    );
  }

  static Future<void> createOrderDetail({
    required OrderDetail orderDetail,
  }) async {
    await SupabaseSnapshot.insert(
      table: OrderDetail.tableName,
      insertObject: orderDetail.toJson(),
    );
  }

  static Future<void> deleteOrderDetail({
    required String orderId,
    required String itemId,
  }) async {
    await SupabaseSnapshot.delete(
      table: OrderDetail.tableName,
      equalObject: {'order_id': orderId, 'item_id': itemId},
    );
  }

  static Future<void> updateItemAmount(
    String orderId,
    String itemId,
    int amount,
  ) async {
    await supabase
        .from('order_detail')
        .update({'amount': amount})
        .eq('order_id', orderId)
        .eq('item_id', itemId);
  }

  static Future<void> addItemToCart(
    String orderId,
    Item item,
    int amount,
  ) async {
    try {
      await SupabaseSnapshot.insert(
        table: OrderDetail.tableName,
        insertObject: {
          'order_id': orderId,
          'item_id': item.itemId,
          'amount': amount,
          'actual_price': item.price,
          'note': null,
        },
      );
    } catch (e) {
      print('Lỗi thêm sản phẩm vào giỏ hàng: $e');
      rethrow;
    }
  }

  static Future<void> clearCart({required String orderId}) async {
    try {
      await SupabaseSnapshot.delete(
        table: OrderDetail.tableName,
        equalObject: {'order_id': orderId},
      );
      await SupabaseSnapshot.delete(
        table: CustomerOrder.tableName,
        equalObject: {'order_id': orderId},
      );
    } catch (e) {
      print('Lỗi khi xóa đơn hàng: $e');
      rethrow;
    }
  }

  static Future<void> editOrderDetail({
    required String orderId,
    required String itemId,
  }) async {
    await SupabaseSnapshot.update(
      table: OrderDetail.tableName,
      updateObject: {"order_id": orderId},
      equalObject: {"item_id": itemId},
    );
  }

  static Future<List<OrderDetail>> getOrderDetailsByOrderId({
    required String orderId,
  }) async {
    var data = await SupabaseSnapshot.getList(
      table: OrderDetail.tableName,
      fromJson: OrderDetail.fromJson,
      equalObject: {"order_id": orderId},
    );

    return data;
  }
}
