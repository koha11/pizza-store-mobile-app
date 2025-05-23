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
    listenToGetOrders();
  }

  void setStatus(OrderStatus? status) {
    orderStatus = status;
    print("Status: ${orderStatus}");
    update(["orders"]);
  }

  void listenToGetOrders() async {
    isLoading = true;
    update(["orders"]);
    orderSub = CustomerOrderSnapshot.getOrdersStream().listen((data) {
      orders.assignAll(data);
      isLoading = false;
      update(["orders"]);
    });

    print(orders);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    orderSub?.cancel();
  }
}

class BindingsOrderManagerController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersManagerController>(() => OrdersManagerController());
  }
}
