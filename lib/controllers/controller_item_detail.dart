import 'package:get/get.dart';

import '../models/variant.model.dart';

class ItemDetailController extends GetxController {
  late int amount;
  Map<String, Variant> _variantMaps = {};
  static ItemDetailController get(String id) => Get.find(tag: id);
  Iterable<Variant> get variants => _variantMaps.values;

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
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    amount = 1;
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    _variantMaps = await VariantSnapshot.getMapVariants();

    update();
  }
}

class BindingsItemDetail extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    final id = Get.arguments['id'];

    Get.put<ItemDetailController>(
      ItemDetailController(),
      tag: id,
      permanent: true,
    );
  }
}
