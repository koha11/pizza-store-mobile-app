import 'package:get/get.dart';
import 'package:pizza_store_app/models/category.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';
import 'package:flutter/material.dart';

class ItemDetailController extends GetxController {
  int amount = 1;
  final String categoryId, tag;

  ItemDetailController(this.categoryId, this.tag);

  List<Variant>? _variants;
  Map<String, List<Variant>>? _variantsMap;
  Map<String, List<String>> _variantCheckList = {};

  static ItemDetailController get(String id) => Get.find(tag: id);
  List<Variant>? get variants => _variants;
  Map<String, List<Variant>>? get variantsMap => _variantsMap;

  Map<String, List<String>> get variantCheckList => _variantCheckList;

  // get cart

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    final category = await CategorySnapshot.getCategoryById(categoryId);

    _variants = category!.variants;
    _variantsMap = {};

    for (var variant in _variants!) {
      //
      if (_variantsMap!.containsKey(variant.variantType.variantTypeName)) {
        _variantsMap!.update(variant.variantType.variantTypeName, (
          variantList,
        ) {
          variantList.add(variant);
          return variantList;
        });
      } else {
        // init _variantsMap va checklist
        _variantsMap!.assign(variant.variantType.variantTypeName, [variant]);
        _variantCheckList.assign(variant.variantTypeId, [""]);
      }
    }

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

  int totalVariant({required int totalPrice}) {
    int total = totalPrice;
    // Duyệt qua tất cả các variant type và variant được chọn
    _variantCheckList.forEach((variantTypeId, variantIds) {
      if (variantIds.isNotEmpty) {
        // Tìm các variant tương ứng và cộng dồn priceChange
        for (var variantId in variantIds) {
          final variant = _variants?.firstWhere(
            (v) => v.variantId == variantId,
          );

          if (variant != null) {
            total += variant.priceChange.toInt();
          }
        }
      }
    });
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