import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/admin/PageAdmin.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/pages/home/PageHome.dart';
import 'package:pizza_store_app/pages/home/PageItem.dart';
import 'package:pizza_store_app/pages/PageHistoryOrderCart.dart';
import 'package:pizza_store_app/pages/PagePendingOrder.dart';
import 'package:pizza_store_app/pages/profile/PageProfile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.model.dart';

class HomePizzaStoreController extends GetxController {
  int currentIndex = 0;
  String _currentCategoryId = "CI0001";
  final List<Widget> _pages = [
    PageHome(),
    //./PagePendingOrder(),
    PagePendingCart(),
    PageProfile(),
    PageItem(),
  ];
  Map<String, Item> _itemMaps = {};
  Map<String, Category> _categoryMaps = {};

  User? _currUser;

  Iterable<Item> get items => _itemMaps.values;
  static HomePizzaStoreController get() => Get.find();
  Iterable<Category> get categories => _categoryMaps.values;

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    _itemMaps = await ItemSnapshot.getMapItems();
    _categoryMaps = await CategorySnapshot.getMapCategories();

    update(["1"]);
  }

  Widget getPage(int index) => _pages[index];

  Iterable<Item> getItems(String categoryId) =>
      items.where((item) => item.category.categoryId == categoryId);

  User? getCurrUser(User user) {
    return _currUser;
  }

  String getCurrCategoryId() => _currentCategoryId;

  void changePage(int index) {
    currentIndex = index;
    update(["1"]);
  }

  void setCurrUser(User user) {
    _currUser = user;
  }

  void setCurrCategoryId(String categoryId) {
    _currentCategoryId = categoryId;
    update(["1"]);
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
