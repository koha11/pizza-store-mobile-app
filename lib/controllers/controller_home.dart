import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/pages/PageHome.dart';
import 'package:pizza_store_app/pages/PageProfile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePizzaStoreController extends GetxController {
  Session? _session;
  late int currentIndex;
  late List<Widget> _pages;
  static HomePizzaStoreController get() => Get.find();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    currentIndex = 0;
    _pages = [PageHome(), PageHome(), PageProfile(controller: this)];
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    _pages = [PageHome(), PageHome(), PageProfile(controller: this)];
  }

  void setSession(Session session) {
    _session = session;
  }

  Session? get session => _session;

  Widget getPage(int index) => _pages[index];

  void changePage(int index) {
    currentIndex = index;
    update(["home"]);
  }
}

class BindingsHomePizzaStore extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => HomePizzaStoreController());
  }
}
