import 'package:pizza_store_app/models/variant.model.dart';

import '../helpers/supabase.helper.dart';

class ItemVariant {
  String categoryId, variantId;
  Variant variant;

  static String tableName = "item_variant";
  static const String selectAllStr = "*, variant(*, variant_type(*))";

  ItemVariant({
    required this.variantId,
    required this.categoryId,
    required this.variant,
  });

  factory ItemVariant.fromJson(Map<String, dynamic> json) {
    return ItemVariant(
      variantId: json["variant_id"],
      categoryId: json["category_id"],
      variant: Variant.fromJson(json["variant"]),
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
    Map<String, dynamic>? equalObject,
  }) async {
    return SupabaseSnapshot.getList(
      table: ItemVariant.tableName,
      fromJson: ItemVariant.fromJson,
      equalObject: equalObject,
      selectString: ItemVariant.selectAllStr,
    );
  }

  static Future<Map<String, ItemVariant>> getMapItemVariants({
    Map<String, dynamic>? equalObject,
  }) {
    return SupabaseSnapshot.getMapT<String, ItemVariant>(
      table: ItemVariant.tableName,
      fromJson: ItemVariant.fromJson,
      getId: (p0) => p0.variantId,
      equalObject: equalObject,
      selectString: ItemVariant.selectAllStr,
    );
  }
}
