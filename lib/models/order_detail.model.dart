import '../helpers/supabase.helper.dart';
import 'Item.model.dart';

class OrderDetail {
  String orderId, itemId;
  int amount, actualPrice;
  String? note;
  Item? item;

  static String tableName = "order_detail";

  OrderDetail({
    required this.orderId,
    required this.itemId,
    required this.amount,
    this.note,
    required this.actualPrice,
    this.item,
  });

  // factory OrderDetail.fromJson(Map<String, dynamic> json) {
  //   return OrderDetail(
  //     orderId: json["order_id"],
  //     itemId: json["item_id"],
  //     amount: json["amount"],
  //     actualPrice: json["actual_price"],
  //     note: json["note"],
  //     item: json["item"] != null && json["item"] is Map<String, dynamic>
  //         ? Item.fromJson(json["item"])
  //         : null,
  //   );
  // }
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    Item? itemParsed;
    try {
      if (json["item"] != null && json["item"] is Map<String, dynamic>) {
        final itemData = Map<String, dynamic>.from(json["item"]);
        itemParsed = Item.fromJson(itemData);
      } else {
        itemParsed = null;
      }
    } catch (e) {
      print("Lỗi parse item: $e");
      itemParsed = null;
    }

    return OrderDetail(
      orderId: json["order_id"],
      itemId: json["item_id"],
      amount: json["amount"],
      actualPrice: json["actual_price"],
      note: json["note"],
      item: itemParsed,
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
    );
  }

  static Future<Map<String, OrderDetail>> getMapOrderDetails() {
    return SupabaseSnapshot.getMapT<String, OrderDetail>(
      table: OrderDetail.tableName,
      fromJson: OrderDetail.fromJson,
      getId: (p0) => p0.orderId,
    );
  }

  static Future<void> updateItemAmount(String orderId, String itemId, int amount) async {
    await supabase
        .from('order_detail')
        .update({'amount': amount})
        .eq('order_id', orderId)
        .eq('item_id', itemId);
  }

  static Future<void> addItemToCart(String orderId, Item item, int amount) async {
    await supabase.from('order_detail').insert({
      'order_id': orderId,
      'item_id': item.itemId,
      'amount': amount,
      'actual_price': item.price,
      'note': null,
    });
  }

  static Future<void> removeItemFromCart(String orderId, String itemId) async {
    await supabase
        .from('order_detail')
        .delete()
        .eq('order_id', orderId)
        .eq('item_id', itemId);
  }

  static Future<void> clearCart(String orderId) async {
    await supabase
        .from('order_detail')
        .delete()
        .eq('order_id', orderId);
  }
}