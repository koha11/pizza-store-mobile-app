import 'dart:async';

import 'package:get/get.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import '../enums/OrderStatus.dart';

class OrderListController extends GetxController {
  List<CustomerOrder> pendingOrders = [];
  List<CustomerOrder> historyOrders = [];
  List<AppUser> user = [];
  List<AppUser> shipper = [];

  bool isLoadingPending = false;
  bool isLoadingHistory = false;
  bool isLoadingUser = false;
  bool isLoadingShipper = false;

  OrderStatus? orderStatus;
  List<dynamic> statuses = [
    null,
    ...OrderStatus.values.where((element) => element != OrderStatus.cart),
  ];

  StreamSubscription<List<CustomerOrder>>? pendingOrderSub;
  StreamSubscription<List<CustomerOrder>>? historyOrderSub;

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
    isLoadingPending = true;
    update();
    pendingOrders = await CustomerOrderSnapshot.getOrders(
        orObject: [
          {"status": "pending"},
          {"status": "shipping"},
        ],
    );
    isLoadingPending = false;
    update();
  }

  Future<void> listenToGetHistoryOrders() async{
    isLoadingHistory = true;
    update();
    historyOrders = await CustomerOrderSnapshot.getOrders(
      equalObject: {"status": "finished"}
    );
    isLoadingHistory = false;
    update();
  }

  Future<void> fetchCustomer() async {
    isLoadingUser = true;
    update();
    user = await AppUserSnapshot.getAppUsers(
      equalObject: {"role_id": "CUSTOMER"},
    );
    isLoadingUser = false;
    update();
  }

  Future<void> fetchShipper() async {
    isLoadingShipper = true;
    update();
    shipper = await AppUserSnapshot.getAppUsers(
      equalObject: {"role_id": "SHIPPER"},
    );
    isLoadingShipper = false;
    update();
  }

  @override
  void onClose() {
    pendingOrderSub?.cancel();
    historyOrderSub?.cancel();
    super.onClose();
  }
}

// Binding cho OrderListController
class BindingOrderList extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderListController>(() => OrderListController());
  }
}
