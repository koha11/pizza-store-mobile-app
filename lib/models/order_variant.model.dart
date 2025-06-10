import 'package:pizza_store_app/models/customer_order.model.dart';

import '../helpers/supabase.helper.dart';
import 'variant.model.dart';

class OrderVariant {
  String variantId, itemId, orderId;
  Variant variant;
  static String tableName = "order_variant";
  static const String selectAllStr =
      "*, variant:variant_id (*),order_detail(*, item:item_id (*, category:category_id (*)))";
  OrderVariant({
    required this.variantId,
    required this.itemId,
    required this.orderId,
    required this.variant,
  });

  factory OrderVariant.fromJson(Map<String, dynamic> json) {
    return OrderVariant(
      variantId: json["variant_id"],
      itemId: json["item_id"],
      orderId: json["order_id"],
      variant: Variant.fromJson(json["variant"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {"variant_id": variantId, "order_id": orderId, "item_id": itemId};
  }
}

class OrderVariantSnapshot {
  OrderVariant orderVariant;

  OrderVariantSnapshot(this.orderVariant);
  static Future<List<OrderVariant>> getOrderVariant() async {
    return SupabaseSnapshot.getList(
      table: OrderVariant.tableName,
      fromJson: OrderVariant.fromJson,
      selectString: "*, variant(*)",
    );
  }

  static Future<Map<String, OrderVariant>> getMapOrderVariant() {
    return SupabaseSnapshot.getMapT<String, OrderVariant>(
      table: OrderVariant.tableName,
      fromJson: OrderVariant.fromJson,
      getId: (p0) => p0.variantId,
      selectString: "*,variant(*)",
    );
  }

  static Future<void> insertOrderVariant(OrderVariant orderVariant) async {
    await SupabaseSnapshot.insert(
      table: OrderVariant.tableName,
      insertObject: orderVariant.toJson(),
    );
  }

  static Future<void> deleteOrderVariant(OrderVariant orderVariant) async {
    await SupabaseSnapshot.delete(table: OrderVariant.tableName);
  }
}
