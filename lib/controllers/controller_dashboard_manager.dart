import 'package:get/get.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

class DashboardManagerController extends GetxController {
  Map<int, int> dailyRevenue = {};
  int totalOrder = 0;
  int totalRevenue = 0;
  int totalProcessingOrder = 0;
  bool isLoading = true;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getOrdersByCurrentMonthAndYear();
  }

  Future<void> getOrdersByCurrentMonthAndYear() async {
    isLoading = true;
    update();
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstDayOfNextMonth =
        (now.month == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
    List<CustomerOrder> orders = await CustomerOrderSnapshot.getOrders(
      ltObject: {"order_time": firstDayOfNextMonth.toIso8601String()},
      gtObject: {"order_time": firstDayOfMonth.toIso8601String()},
    );
    List<CustomerOrder> ordersToday =
        orders.where((order) {
          final orderTime = order.orderTime;
          return orderTime != null &&
              orderTime.year == now.year &&
              orderTime.month == now.month &&
              orderTime.day == now.day;
        }).toList();

    totalOrder =
        ordersToday
            .where((order) => order.status.name == OrderStatus.finished.name)
            .length;
    ;
    totalProcessingOrder =
        ordersToday
            .where((order) => order.status.name != OrderStatus.finished.name)
            .length;
    totalRevenue = ordersToday
        .where((order) => order.status.name == OrderStatus.finished.name)
        .fold<int>(0, (sum, order) => sum + (order.totalAmount ?? 0));

    for (var order in orders) {
      final orderTime = order.orderTime;
      if (orderTime == null || order.status.name != OrderStatus.finished.name)
        continue;
      final day = orderTime.day;
      dailyRevenue[day] = (dailyRevenue[day] ?? 0) + (order.total ?? 0);
    }
    isLoading = false;
    update();
  }
}

class BindingDashboardDashboardController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardManagerController());
  }
}
