import 'package:pizza_store_app/models/variant.model.dart';

import '../helpers/supabase.helper.dart';

class ItemVariant {
  String categoryId;
  Variant variant;

  static String tableName = "item_variant";

  ItemVariant({required this.variant, required this.categoryId});

  factory ItemVariant.fromJson(Map<String, dynamic> json) {
    return ItemVariant(
      variant: Variant.fromJson(json["variant"]),
      categoryId: json["category_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"variant": variant.toJson(), "categoryId": categoryId};
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
      selectString:
          "*, variant(variant_id, variant_name, description, price_change)",
    );
  }

  static Future<Map<String, ItemVariant>> getMapItemVariants({
    String columnName = "",
    String columnValue = "",
  }) {
    return SupabaseSnapshot.getMapT<String, ItemVariant>(
      table: ItemVariant.tableName,
      fromJson: ItemVariant.fromJson,
      getId: (p0) => p0.categoryId,
      columnName: columnName,
      columnValue: columnValue,
      selectString:
          "*, variant(variant_id, variant_name, price_change, description)",
    );
  }
}
