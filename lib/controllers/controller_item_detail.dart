import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item_variant.model.dart';
import 'package:pizza_store_app/models/category.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';

class ItemDetailController extends GetxController {
  int amount = 1;
  final String categoryId, tag;

  ItemDetailController(this.categoryId, this.tag);

  List<Variant>? _variants;
  Map<String, List<Variant>>? _variantsMap;
  Map<String, String> _variantCheckList = {};

  static ItemDetailController get(String id) => Get.find(tag: id);
  List<Variant>? get variants => _variants;
  Map<String, List<Variant>>? get variantsMap => _variantsMap;

  Map<String, String> get variantCheckList => _variantCheckList;

  // get cart

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    final category = await CategorySnapshot.getCategoryById(categoryId);

    _variants = category!.variants;
    _variantsMap = {};

    for (var variant in _variants!) {
      if (_variantsMap!.containsKey(variant.variantType.variantTypeName)) {
        _variantsMap!.update(variant.variantType.variantTypeName, (
          variantList,
        ) {
          variantList.add(variant);
          return variantList;
        });
      } else {
        _variantsMap!.assign(variant.variantType.variantTypeName, [variant]);

        _variantCheckList.assign(variant.variantType.variantTypeName, "");
      }
    }

    update([tag]);
  }

  void checkVariant({
    required String variantTypeName,
    required String variantId,
  }) {
    variantCheckList[variantTypeName] = variantId;
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
