import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item_variant.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';

class ItemDetailController extends GetxController {
  int amount = 1;
  final String categoryId, tag;

  ItemDetailController(this.categoryId, this.tag);

  Map<String, Variant>? _variantMaps;
  Iterable<ItemVariant>? _itemVariants;
  Map<String, List<Variant>>? _myVariants;
  Map<String, String> _variantCheckList = {};

  static ItemDetailController get(String id) => Get.find(tag: id);
  // Iterable<Variant>? get variants => _variantMaps?.values;
  Map<String, List<Variant>>? get variants => _myVariants;
  Map<String, String> get variantCheckList => _variantCheckList;

  // get cart

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    _itemVariants = await ItemVariantSnapshot.getItemVariants(
      equalObject: {"category_id": categoryId},
    );

    List<String> variantIds =
        _itemVariants == null
            ? []
            : _itemVariants!.map((e) => e.variantId).toList();

    _variantMaps = await VariantSnapshot.getMapVariants();

    _myVariants = {};

    _variantMaps!.forEach((variantId, variant) {
      if (variantIds.contains(variantId)) {
        if (_myVariants!.containsKey(variant.variantType.variantTypeName)) {
          _myVariants!.update(variant.variantType.variantTypeName, (
            variantList,
          ) {
            variantList.add(variant);
            return variantList;
          });
        } else {
          _myVariants!.assign(variant.variantType.variantTypeName, [variant]);

          _variantCheckList.assign(variant.variantType.variantTypeName, "");
        }
      }
    });

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
