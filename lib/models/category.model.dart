import 'package:pizza_store_app/models/Item_variant.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';

import '../helpers/supabase.helper.dart';

class Category {
  String categoryId, categoryName;
  String? categoryImage;
  List<Variant>? variants;

  static const String tableName = "category";
  static const String selectAllStr =
      "*, item_variant(*, variant:variant_id(*, variant_type(*)))";

  Category({
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
    this.variants,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<dynamic> itemVariantsJson = json["item_variant"] ?? [];

    List<Variant> variants =
        itemVariantsJson.isEmpty
            ? []
            : itemVariantsJson
                .map((ivJson) => ItemVariant.fromJson(ivJson).variant)
                .toList();

    return Category(
      categoryId: json["category_id"],
      categoryName: json["category_name"],
      categoryImage: json["category_image"],
      variants: variants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "category_id": categoryId,
      "category_name": categoryName,
      "category_image": categoryImage,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}

class CategorySnapshot {
  Category category;

  CategorySnapshot(this.category);

  static Future<List<Category>> getCategories({equalObject}) async {
    return SupabaseSnapshot.getList(
      table: Category.tableName,
      fromJson: Category.fromJson,
      equalObject: equalObject,
      selectString: Category.selectAllStr,
    );
  }

  static Future<Map<String, Category>> getMapCategories() {
    return SupabaseSnapshot.getMapT<String, Category>(
      table: Category.tableName,
      fromJson: Category.fromJson,
      getId: (p0) => p0.categoryId,
    );
  }

  static Future<Category?> getCategoryById(String id) {
    return SupabaseSnapshot.getById(
      selectString: Category.selectAllStr,
      table: Category.tableName,
      fromJson: Category.fromJson,
      idKey: "category_id",
      idValue: id,
    );
  }
}
