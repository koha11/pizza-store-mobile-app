import 'dart:async';

import 'package:get/get.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

class OrdersManagerController extends GetxController {
  List<CustomerOrder> orders = [];
  bool isLoading = false;
  OrderStatus? orderStatus;
  List<dynamic> statuses = [
    null,
    ...OrderStatus.values.where((element) => element != OrderStatus.cart),
  ];
  StreamSubscription<List<CustomerOrder>>? orderSub;
  static OrdersManagerController get() => Get.find();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getOrders();
  }

  void setStatus(OrderStatus? status) {
    orderStatus = status;
    update(["orders"]);
  }

  Future<void> getOrders() async {
    isLoading = true;
    update(["orders"]);
    orders = await CustomerOrderSnapshot.getOrders(sortByOrderTimeDesc: true);
    isLoading = false;
    update(["orders"]);
  }
}

class BindingsOrderManagerController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersManagerController>(() => OrdersManagerController());
  }
}
