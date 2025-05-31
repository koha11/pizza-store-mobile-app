import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/pages/dashboard/PageDashboard.dart';
import 'package:pizza_store_app/pages/order_manager/PageOrdersList.dart';
import 'package:pizza_store_app/pages/profile/PageProfile.dart';

class DashboardManagerController extends GetxController {
  Map<int, int> dailyRevenue = {};
  Map<String, int> summary = {
    "totalOrder": 0,
    "totalProcessingOrder": 0,
    "totalRevenue": 0,
  };
  bool isLoading = true;
  int currentIndex = 0;
  final List<Widget> _pages = [
    PageDashboard(),
    PageOrdersList(),
    PageProfile(),
  ];
  static DashboardManagerController get() => Get.find();

  Widget getPage(int index) => _pages[index];
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getMonthlyRevenueDashboardData();
  }

  String getTitlePage() {
    switch (currentIndex) {
      case 0:
        return "Doanh thu";
      case 1:
        return "Danh sách các đơn hàng";
      case 2:
        return "Hồ sơ cá nhân";
      default:
        return "";
    }
  }

  void changePage(int index) {
    currentIndex = index;
    update(["1"]);
  }

  Future<void> getMonthlyRevenueDashboardData() async {
    isLoading = true;
    update();
    dailyRevenue = await CustomerOrderSnapshot.groupDataToStatisticChart();
    summary = await CustomerOrderSnapshot.getOrderSummaryStatistic();
    isLoading = false;
    update();
  }
}

class BindingDashboardDashboardController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardManagerController());
    Get.lazyPut(() => OrdersManagerController());
    Get.lazyPut(() => UserController());
  }
}
