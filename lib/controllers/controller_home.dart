import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/pages/PageHome.dart';
import 'package:pizza_store_app/pages/PageProfile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePizzaStoreController extends GetxController {
  int currentIndex = 0;
  final List<Widget> _pages = [PageHome(), PageProfile(), PageProfile()];
  Map<String, Item> _itemMaps = {};

  static HomePizzaStoreController get() => Get.find();
  Iterable<Item> get items => _itemMaps.values;

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    _itemMaps = await ItemSnapshot.getMapItems();

    update();
  }

  Widget getPage(int index) => _pages[index];

  void changePage(int index) {
    currentIndex = index;
    update(["1"]);
  }

  Future<void> signOut() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
    update(["1"]);
  }
}

class BindingsHomePizzaStore extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<HomePizzaStoreController>(() => HomePizzaStoreController());
  }
}
