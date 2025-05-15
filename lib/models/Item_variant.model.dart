import 'package:pizza_store_app/models/variant.model.dart';

import '../helpers/supabase.helper.dart';

class ItemVariant {
  String categoryId, variantId;

  static String tableName = "item_variant";

  ItemVariant({required this.variantId, required this.categoryId});

  factory ItemVariant.fromJson(Map<String, dynamic> json) {
    return ItemVariant(
      variantId: json["variant_id"],
      categoryId: json["category_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"variant_id": variantId, "categoryId": categoryId};
  }
}

class ItemVariantSnapshot {
  ItemVariant itemVariant;

  ItemVariantSnapshot(this.itemVariant);

  static Future<List<ItemVariant>> getItemVariants({
    String columnName = "",
    String columnValue = "",
  }) async {
    return SupabaseSnapshot.getList(
      table: ItemVariant.tableName,
      fromJson: ItemVariant.fromJson,
      columnName: columnName,
      columnValue: columnValue,
    );
  }

  static Future<Map<String, ItemVariant>> getMapItemVariants({
    String columnName = "",
    String columnValue = "",
  }) {
    return SupabaseSnapshot.getMapT<String, ItemVariant>(
      table: ItemVariant.tableName,
      fromJson: ItemVariant.fromJson,
      getId: (p0) => p0.variantId,
      columnName: columnName,
      columnValue: columnValue,
    );
  }
}
