import 'dart:async';

import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

import '../enums/OrderStatus.dart';

class OrderListShipperController extends GetxController {
  List<CustomerOrder> pendingOrders = [];
  List<CustomerOrder> historyOrders = [];

  bool isLoadingPending = true;
  bool isLoadingHistory = true;
  bool isLoadingUser = true;
  bool isLoadingShipper = true;

  List<dynamic> statuses = [
    null,
    ...OrderStatus.values.where((element) => element != OrderStatus.cart),
  ];

  static OrderListShipperController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    Future.wait([listenToGetPendingOrders(), listenToGetHistoryOrders()]);
  }

  Future<void> listenToGetPendingOrders() async {
    pendingOrders = await CustomerOrderSnapshot.getOrders(
      orObject: [
        {"status": "confirmed"},
        {"status": "shipping"},
      ],
      equalObject: {"shipper_id": UserController.get().appUser!.userId},
    );
    isLoadingPending = false;
    update();
  }

  Future<void> listenToGetHistoryOrders() async {
    historyOrders = await CustomerOrderSnapshot.getOrders(
      equalObject: {
        "status": "finished",
        "shipper_id": UserController.get().appUser!.userId,
      },
    );
    isLoadingHistory = false;
    update();
  }
}

// Binding cho OrderListController
class BindingOrderList extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderListShipperController>(() => OrderListShipperController());
  }
}
