import 'package:pizza_store_app/models/variant_type.model.dart';

import '../helpers/supabase.helper.dart';

class Variant {
  String variantId, variantName;
  VariantType variantType;
  int priceChange;

  static String tableName = "variant";

  Variant({
    required this.variantId,
    required this.variantName,
    required this.variantType,
    required this.priceChange,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      variantId: json["variant_id"],
      variantName: json["variant_name"],
      variantType: VariantType.fromJson(json['variant_type']),
      priceChange: json["price_change"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "variant_id": priceChange,
      "variant_type_id": variantType.toJson(),
      "variant_name": variantName,
      "price_change": priceChange,
    };
  }
}

class VariantSnapshot {
  Variant variant;

  VariantSnapshot(this.variant);

  static Future<List<Variant>> getVariants() async {
    return SupabaseSnapshot.getList(
      table: Variant.tableName,
      fromJson: Variant.fromJson,
      selectString: "*, variant_type(*)",
    );
  }

  static Future<Map<String, Variant>> getMapVariants() async {
    Map<String, Variant> variants =
        await SupabaseSnapshot.getMapT<String, Variant>(
          table: Variant.tableName,
          fromJson: Variant.fromJson,
          getId: (p0) => p0.variantId,
          selectString: "*, variant_type(*)",
        );

    return variants;
  }
}
