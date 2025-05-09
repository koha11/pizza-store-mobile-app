import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item_variant.model.dart';

class ItemDetailController extends GetxController {
  int amount = 1;
  final String categoryId, tag;

  ItemDetailController(this.categoryId, this.tag);

  Map<String, ItemVariant>? _variantMaps;
  static ItemDetailController get(String id) => Get.find(tag: id);
  Iterable<ItemVariant>? get variants => _variantMaps?.values;

  // get cart

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    _variantMaps = await ItemVariantSnapshot.getMapItemVariants(
      columnName: "category_id",
      columnValue: categoryId,
    );

    print(_variantMaps);
    print(variants);

    update([tag]);
  }
}

class BindingsItemDetail extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    final id = Get.arguments['id'];
    final categoryId = Get.arguments['category_id'];

    Get.put<ItemDetailController>(
      ItemDetailController(categoryId, id),
      tag: id,
      permanent: true,
    );
  }
}
