import 'package:get/get.dart';

class ShoppingCartController extends GetxController{

}
class BindingsShoppingcart extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<ShoppingCartController>(() => ShoppingCartController());
  }
}