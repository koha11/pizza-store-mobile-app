import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/admin/PageAdmin.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/pages/home/PageHome.dart';
import 'package:pizza_store_app/pages/home/PageItem.dart';
import 'package:pizza_store_app/pages/order_history/PageHistoryOrder.dart';
import 'package:pizza_store_app/pages/shipper/PagePendingOrder.dart';
import 'package:pizza_store_app/pages/profile/PageProfile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.model.dart';

class HomePizzaStoreController extends GetxController {
  late int currentIndex;
  late String _currentCategoryId;
  bool isHomeLoading = true;

  final List<Widget> _pages = [
    PageHome(),
    PageHistoryOrderCart(),
    PageProfile(),
    PageItem(),
  ];

  Map<String, Item> _itemMaps = {};
  Map<String, Category> _categoryMaps = {};

  Iterable<Item> get items => _itemMaps.values;
  static HomePizzaStoreController get() => Get.find();
  Iterable<Category> get categories => _categoryMaps.values;

  @override
  void onInit() async {
    super.onInit();

    currentIndex = 0;
    _currentCategoryId = "CI0001";
    _itemMaps = await ItemSnapshot.getMapItems();
    _categoryMaps = await CategorySnapshot.getMapCategories();

    isHomeLoading = false;
    update();
  }

  Widget getPage(int index) => _pages[index];

  Iterable<Item> getItems(String categoryId) =>
      items.where((item) => item.category.categoryId == categoryId);

  String getCurrCategoryId() => _currentCategoryId;

  void changePage(int index) {
    currentIndex = index;
    update();
  }

  void setCurrCategoryId(String categoryId) {
    _currentCategoryId = categoryId;
    update();
  }

  void refreshHome() {
    _currentCategoryId = "CI0001";
    currentIndex = 0;
    update();
  }
}

class BindingsHomePizzaStore extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<HomePizzaStoreController>(() => HomePizzaStoreController());
  }
}
