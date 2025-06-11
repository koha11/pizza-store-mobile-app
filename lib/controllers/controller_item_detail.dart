import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/category.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';
import 'package:flutter/material.dart';

class ItemDetailController extends GetxController {
  int amount = 1;
  final String categoryId, tag;
  Category? _category;
  Item? _item;
  bool isItemDetailLoading = true;

  ItemDetailController(this.categoryId, this.tag);

  List<Variant>? _variants;
  Map<String, List<Variant>>? _variantsMap; // key la variantTypeId
  Map<String, List<String>> _variantCheckList =
      {}; // key la variantTypeId, value la List<variantId>

  static ItemDetailController get(String id) => Get.find(tag: id);

  Item? get item => _item;
  Category? get category => _category;
  List<Variant>? get variants => _variants;
  Map<String, List<Variant>>? get variantsMap => _variantsMap;
  Map<String, List<String>> get variantCheckList => _variantCheckList;

  // get cart

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    _item = await ItemSnapshot.getItemById(tag);
    _category = _item!.category;

    _variants = _category!.variants;
    _variantsMap = {};

    for (var variant in _variants!) {
      //
      if (_variantsMap!.containsKey(variant.variantTypeId)) {
        _variantsMap!.update(variant.variantTypeId, (variantList) {
          variantList.add(variant);
          return variantList;
        });
      } else {
        // init _variantsMap va checklist
        _variantsMap!.assign(variant.variantTypeId, [variant]);
        _variantCheckList.assign(variant.variantTypeId, [""]);
      }
    }

    update([tag]);
  }

  void adjustAmount(int amount) {
    if (amount < 0) {
      return;
    }

    this.amount = amount;
    update([tag]);
  }

  void checkVariant({
    required String variantTypeId,
    required String variantId,
  }) {
    final isRequired =
        _variants!
            .firstWhere((element) => element.variantTypeId == variantTypeId)
            .variantType
            .isRequired;
    if (isRequired) {
      variantCheckList[variantTypeId] = [variantId];
    } else {
      for (var vi in variantCheckList[variantTypeId]!) {
        if (vi == variantId) {
          variantCheckList[variantTypeId]!.remove(vi);
          return;
        }
      }

      variantCheckList[variantTypeId]!.add(variantId);
    }

    update([tag]);
  }

  int getItemDetailTotal() {
    if (_item == null) {
      return 0;
    }

    int total = _item!.price;

    variantCheckList.forEach(
      (variantTypeId, variantIds) => variantIds.forEach((variantId) {
        if (variantId.isNotEmpty) {
          total +=
              variantsMap![variantTypeId]!
                  .firstWhere((variant) => variant.variantId == variantId)
                  .priceChange;
        }
      }),
    );

    total *= amount;

    return total;
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
