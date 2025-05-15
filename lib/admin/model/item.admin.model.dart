import 'package:pizza_store_app/helpers/supabase.helper.dart';
import '../../helpers/supabase.helper.dart' as SupabaseHelper;
import '../../models/category.model.dart';

class ItemAdmin {
  String itemId, itemName;
  Category category;
  String? itemImage, description;
  int price;

  static String tableName = "item";

  ItemAdmin({
    required this.itemId,
    required this.itemName,
    this.itemImage,
    this.description,
    required this.price,
    required this.category,
  });

  factory ItemAdmin.fromJson(Map<String, dynamic> json) {
    return ItemAdmin(
      itemId: json["item_id"],
      itemName: json["item_name"],
      itemImage: json["item_image"],
      description: json["description"],
      price: json["price"],
      category: Category.fromJson(json["category"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "item_id": itemId,
      "item_name": itemName,
      "item_image": itemImage,
      "description": description,
      "price": price,
      "category": category.toJson(),
    };
  }
}

class ItemAdminSnapshot {
  ItemAdmin item;

  ItemAdminSnapshot(this.item);

  static Future<List<ItemAdmin>> getItemsAdminWithPagination({int startIndex = 0, int limit = 5, String? searchQuery}) async {
    final res = await SupabaseHelper.supabase
        .from(ItemAdmin.tableName)
        .select('*, category(category_id, category_name)')
        .range(startIndex, startIndex + limit - 1);

    if (res == null) {
      return [];
    }
    return (res as List).map((json) => ItemAdmin.fromJson(json)).toList();
  }

  static Future<Map<String, ItemAdmin>> getMapItemsAdmin() {
    return SupabaseSnapshot.getMapT<String, ItemAdmin>(
      table: ItemAdmin.tableName,
      fromJson: ItemAdmin.fromJson,
      getId: (p0) => p0.itemId,
      selectString:
      "*, category(category_id, category_name)",
    );
  }

  static Future<int> getTotalItemsAdmin({String? searchQuery}) async {
    final res = await SupabaseHelper.supabase
        .from(ItemAdmin.tableName)
        .select('item_id'); // Chỉ lấy ID
    if (res == null) {
      return 0;
    }
    return (res as List).length;
  }

  static Future<bool> update(ItemAdmin newItem) async {
    try {
      final supabase = SupabaseHelper.supabase;
      await supabase
          .from(ItemAdmin.tableName)
          .update(newItem.toJson())
          .eq("item_id", newItem.itemId);
      return true;
    } catch (e) {
      print('Error updating item: $e');
      return false;
    }
  }

  static Future<dynamic> insert(ItemAdmin newItem) async {
    final supabase = SupabaseHelper.supabase;
    final data = await supabase
        .from(ItemAdmin.tableName)
        .insert(newItem.toJson())
        .select(); // Lấy dữ liệu vừa insert nếu cần
    return data;
  }

  static Future<void> delete(String itemId) async {
    final supabase = SupabaseHelper.supabase;
    await supabase.from(ItemAdmin.tableName).delete().eq("item_id", itemId);
  }
}

