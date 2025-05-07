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

  User? _currUser;

  static HomePizzaStoreController get() => Get.find();
  Iterable<Item> get items => _itemMaps.values;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    _itemMaps = await ItemSnapshot.getMapItems();
    update(["1"]);
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    _itemMaps = await ItemSnapshot.getMapItems();

    update(["1"]);
  }

  Widget getPage(int index) => _pages[index];

  void changePage(int index) {
    currentIndex = index;
    update(["1"]);
  }

  void setCurrUser(User user) {
    _currUser = user;
  }

  User? getCurrUser(User user) {
    return _currUser;
  }

  Future<void> signOut() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
    _currUser = null;
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
