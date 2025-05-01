import 'package:get/get.dart';

class HomePizzaStoreController extends GetxController {
  static HomePizzaStoreController get() => Get.find();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }
}

class BindingsHomePizzaStore extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => HomePizzaStoreController());
  }
}
