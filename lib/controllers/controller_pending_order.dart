import 'dart:async';

import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import '../enums/OrderStatus.dart';

class OrderListController extends GetxController {
  List<CustomerOrder> pendingOrders = [];
  List<CustomerOrder> historyOrders = [];
  List<AppUser> user = [];
  List<AppUser> shipper = [];

  bool isLoadingPending = true;
  bool isLoadingHistory = true;
  bool isLoadingUser = true;
  bool isLoadingShipper = true;

  List<dynamic> statuses = [
    null,
    ...OrderStatus.values.where((element) => element != OrderStatus.cart),
  ];

  static OrderListController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async{
    Future.wait([
      listenToGetPendingOrders(),
      listenToGetHistoryOrders(),
      fetchCustomer(),
      fetchShipper(),
    ]);
  }

  Future<void> listenToGetPendingOrders() async{
    pendingOrders = await CustomerOrderSnapshot.getOrders(
      orObject: [
        {"status": "pending"},
        {"status": "shipping"},
      ],
      equalObject: {"shipper_id": UserController.get().appUser!.userId}
    );
    isLoadingPending = false;
    update();
  }

  Future<void> listenToGetHistoryOrders() async{
    historyOrders = await CustomerOrderSnapshot.getOrders(
      equalObject: {
        "status": "finished",
        "shipper_id": UserController.get().appUser!.userId
      },
    );
    isLoadingHistory = false;
    update();
  }

  Future<void> fetchCustomer() async {
    user = await AppUserSnapshot.getAppUsers(
      equalObject: {"role_id": "CUSTOMER"},
    );
    isLoadingUser = false;
    update();
  }

  Future<void> fetchShipper() async {
    shipper = await AppUserSnapshot.getAppUsers(
      equalObject: {"role_id": "SHIPPER"},
    );
    isLoadingShipper = false;
    update();
  }

}

// Binding cho OrderListController
class BindingOrderList extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderListController>(() => OrderListController());
  }
}
