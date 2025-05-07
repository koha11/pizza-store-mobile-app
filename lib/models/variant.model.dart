import '../helpers/supabase.helper.dart';

class Variant {
  String variantId, variantName;
  String? description;
  int priceChange;

  static String tableName = "variant";

  Variant({
    required this.variantId,
    required this.variantName,
    this.description,
    required this.priceChange,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      variantId: json["variant_id"],
      variantName: json["variant_name"],
      description: json["description"],
      priceChange: json["price_change"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "variant_id": priceChange,
      "variant_name": variantName,
      "description": description,
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
    );
  }

  static Future<Map<String, Variant>> getMapVariants() {
    return SupabaseSnapshot.getMapT<String, Variant>(
      table: Variant.tableName,
      fromJson: Variant.fromJson,
      getId: (p0) => p0.variantId,
    );
  }
}
