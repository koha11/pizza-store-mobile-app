import 'package:get/get.dart';
import 'package:pizza_store_app/models/app_user.model.dart';

class ShipperController extends GetxController {
  List<AppUser> shipperList = [];
  bool isLoading = false;
  static ShipperController get() => Get.find();
  @override
  void onInit() {
    super.onInit();
    fetchShippers();
  }

  Future<void> fetchShippers() async {
    isLoading = true;
    update();
    shipperList = await AppUserSnapshot.getAppUsers(
      equalObject: {"role_id": "SHIPPER"},
    );
    isLoading = false;
    update();
  }
}

class BindingShipperController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipperController>(() => ShipperController());
  }
}
