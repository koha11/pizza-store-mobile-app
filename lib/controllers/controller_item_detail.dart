import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item_variant.model.dart';

class ItemDetailController extends GetxController {
  int amount = 1;
  final String categoryId;

  ItemDetailController(this.categoryId);

  Map<String, ItemVariant> _variantMaps = {};
  static ItemDetailController get(String id) => Get.find(tag: id);
  Iterable<ItemVariant> get variants => _variantMaps.values;

  // get cart

  void increaseAmount(String id) {
    ++amount;
    update([id]);
  }

  void decreaseAmount(String id) {
    if (amount > 1) {
      --amount;
      update([id]);
    }
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();

    _variantMaps = await ItemVariantSnapshot.getMapItemVariants(
      columnName: "category_id",
      columnValue: categoryId,
    );
  }
}

class BindingsItemDetail extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    final id = Get.arguments['id'];
    final categoryId = Get.arguments['category_id'];

    Get.put<ItemDetailController>(
      ItemDetailController(categoryId),
      tag: id,
      permanent: true,
    );
  }
}
