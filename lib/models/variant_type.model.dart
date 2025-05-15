import '../helpers/supabase.helper.dart';

class VariantType {
  String variantTypeId, variantTypeName;

  static String tableName = "variant_type";

  VariantType({required this.variantTypeId, required this.variantTypeName});

  factory VariantType.fromJson(Map<String, dynamic> json) {
    return VariantType(
      variantTypeId: json["variant_type_id"],
      variantTypeName: json["variant_type_name"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "variant_type_id": variantTypeId,
      "variant_type_name": variantTypeName,
    };
  }
}

class VariantTypeSnapshot {
  VariantType variantType;

  VariantTypeSnapshot(this.variantType);

  static Future<List<VariantType>> getVariants() async {
    return SupabaseSnapshot.getList(
      table: VariantType.tableName,
      fromJson: VariantType.fromJson,
    );
  }

  static Future<Map<String, VariantType>> getMapVariants() async {
    Map<String, VariantType> variants =
        await SupabaseSnapshot.getMapT<String, VariantType>(
          table: VariantType.tableName,
          fromJson: VariantType.fromJson,
          getId: (p0) => p0.variantTypeId,
        );

    return variants;
  }
}
