import '../helpers/supabase.helper.dart';

class ItemVariant {
  String variantId, categoryId;

  static String tableName = "item_variant";

  ItemVariant({required this.variantId, required this.categoryId});

  factory ItemVariant.fromJson(Map<String, dynamic> json) {
    return ItemVariant(
      variantId: json["variant_id"],
      categoryId: json["category_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"category_id": variantId, "category_name": categoryId};
  }
}

class ItemVariantSnapshot {
  ItemVariant itemVariant;

  ItemVariantSnapshot(this.itemVariant);

  static Future<List<ItemVariant>> getCategories() async {
    return SupabaseSnapshot.getList(
      table: ItemVariant.tableName,
      fromJson: ItemVariant.fromJson,
    );
  }

  static Future<Map<String, ItemVariant>> getMapCategories() {
    return SupabaseSnapshot.getMapT<String, ItemVariant>(
      table: ItemVariant.tableName,
      fromJson: ItemVariant.fromJson,
      getId: (p0) => p0.categoryId,
    );
  }
}
