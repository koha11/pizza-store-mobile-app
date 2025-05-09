import 'package:get/get.dart';

import '../models/Item.model.dart';

class SearchItemController extends GetxController {
  String searchString = "";
  Map<String, Item> _itemMaps = {};

  static SearchItemController get() => Get.find();
  Iterable<Item> get items => _itemMaps.values.where(
    (item) => item.itemName.toLowerCase().contains(searchString.toLowerCase()),
  );

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();

    _itemMaps = await ItemSnapshot.getMapItems();

    update(["1"]);
  }

  void searchItem(String query) {
    searchString = query;
    update(["1"]);
  }
}

class BindingsSearch extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<SearchItemController>(() => SearchItemController());
  }
}
