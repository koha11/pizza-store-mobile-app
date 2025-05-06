import '../helpers/supabase.helper.dart';

class Item {
  String itemId, itemName;
  String? itemImage, description, categoryID;
  int price;

  static String tableName = "item";

  Item({
    required this.itemId,
    required this.itemName,
    this.itemImage,
    this.description,
    required this.price,
    required this.categoryID,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json["item_id"],
      itemName: json["item_name"],
      itemImage: json["item_image"],
      description: json["description"],
      price: json["price"],
      categoryID: json["category_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "item_id": itemId,
      "item_name": itemName,
      "item_image": itemImage,
      "description": description,
      "price": price,
      "category_id": categoryID,
    };
  }
}

class ItemSnapshot {
  Item item;

  ItemSnapshot(this.item);

  static Future<List<Item>> getItems() async {
    return SupabaseSnapshot.getList(
      table: Item.tableName,
      fromJson: Item.fromJson,
    );
  }

  static Future<Map<String, Item>> getMapItems() {
    return SupabaseSnapshot.getMapT<String, Item>(
      table: Item.tableName,
      fromJson: Item.fromJson,
      getId: (p0) => p0.itemId,
    );
  }
}
