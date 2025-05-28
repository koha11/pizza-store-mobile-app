import 'category.model.dart';

import '../helpers/supabase.helper.dart';

class Item {
  String itemId, itemName;
  Category category;
  String? itemImage, description;
  int price;

  static const String tableName = "item";

  Item({
    required this.itemId,
    required this.itemName,
    this.itemImage,
    this.description,
    required this.price,
    required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
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

class ItemSnapshot {
  Item item;

  ItemSnapshot(this.item);

  static Future<Item?> getItemById(String itemId) async {
    return SupabaseSnapshot.getById(
      table: Item.tableName,
      fromJson: Item.fromJson,
      selectString: "*, category(*)",
      idKey: "item_id",
      idValue: itemId,
    );
  }

  static Future<List<Item>> getItems() async {
    return SupabaseSnapshot.getList(
      table: Item.tableName,
      fromJson: Item.fromJson,
      selectString: "*, category(*)",
    );
  }

  static Future<Map<String, Item>> getMapItems() {
    return SupabaseSnapshot.getMapT<String, Item>(
      table: Item.tableName,
      fromJson: Item.fromJson,
      getId: (p0) => p0.itemId,
      selectString: "*, category(*)",
    );
  }

  static Future<void> createItem({
    required Item item,
  }) async {
    await SupabaseSnapshot.insert(
      table: Item.tableName,
      insertObject: {
        "item_id": item.itemId,
        "item_name": item.itemName,
        "item_image": item.itemImage,
        "description": item.description,
        "price": item.price,
        "category_id": item.category.categoryId,
      },
    );
  }

  static Future<void> deleteItem({
    required Item item,
  }) async {
    await SupabaseSnapshot.delete(
      table: Item.tableName,
      equalObject: {'item_id': item.itemId},
    );
  }

  static Future<void> updateItem({
    required Item item,
  }) async {
    await SupabaseSnapshot.update(
      table: Item.tableName,
      updateObject: {
        "item_name": item.itemName,
        "item_image": item.itemImage,
        "description": item.description,
        "price": item.price,
        "category_id": item.category.categoryId,
      },
      equalObject: {"item_id": item.itemId},
    );
  }

  static Future<List<Item>> searchItems(String query) async {
    try {
      final List<Item> items = await SupabaseSnapshot.search<Item>(
        table: Item.tableName,
        columnName: 'item_name',
        query: query,
        fromJson: Item.fromJson,
        selectString: '*, category(*)',
      );
      return items;
    } catch (e) {
      throw 'Lỗi khi tìm kiếm Item: $e';
    }
  }
}
