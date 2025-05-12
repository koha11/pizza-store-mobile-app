import '../helpers/supabase.helper.dart';

class Category {
  String categoryId, categoryName;
  String? categoryImage;

  static String tableName = "category";

  Category({
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json["category_id"],
      categoryName: json["category_name"],
      categoryImage: json["category_image"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "category_id": categoryId,
      "category_name": categoryName,
      "category_image": categoryImage,
    };
  }
}

class CategorySnapshot {
  Category category;

  CategorySnapshot(this.category);

  static Future<List<Category>> getCategories() async {
    return SupabaseSnapshot.getList(
      table: Category.tableName,
      fromJson: Category.fromJson,
    );
  }

  static Future<Map<String, Category>> getMapCategories() {
    return SupabaseSnapshot.getMapT<String, Category>(
      table: Category.tableName,
      fromJson: Category.fromJson,
      getId: (p0) => p0.categoryId,
    );
  }
}
