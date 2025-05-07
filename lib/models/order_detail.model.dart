import '../helpers/supabase.helper.dart';

class OrderDetail {
  String orderId, itemId;
  int amount, actualPrice;
  String? note;

  static String tableName = "category";

  OrderDetail({
    required this.orderId,
    required this.itemId,
    required this.amount,
    this.note,
    required this.actualPrice,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json["order_id"],
      itemId: json["item_id"],
      amount: json["amount"],
      actualPrice: json["note"],
      note: json["actual_price"],
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
}
