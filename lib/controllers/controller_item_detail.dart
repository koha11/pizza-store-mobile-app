import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item_variant.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';

class ItemDetailController extends GetxController {
  int amount = 1;
  final String categoryId, tag;

  ItemDetailController(this.categoryId, this.tag);

  Map<String, Variant>? _variantMaps;
  Iterable<ItemVariant>? _itemVariants;

  Map<String, Variant> _myVariants = {};

  static ItemDetailController get(String id) => Get.find(tag: id);
  Iterable<Variant>? get variants => _variantMaps?.values;

  // get cart

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    _itemVariants = await ItemVariantSnapshot.getItemVariants(
      equalObject: {"category_id": categoryId},
    );

    _variantMaps = await VariantSnapshot.getMapVariants();

    _variantMaps!.forEach((variantId, variant) {
      if (_itemVariants == true) {
        _myVariants.assign(variant.variantType.variantTypeName, variant);
      }
    });

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
      // permanent: true,
    );
  }
}
