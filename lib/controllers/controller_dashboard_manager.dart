import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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
    "totalShippingOrder": 0,
    "totalFinishedOrder": 0,
    "totalConfirmedOrder": 0,
  };
  bool isLoading = true;
  int currentIndex = 0;

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return PageDashboard();
      case 1:
        return PageOrdersList();
      case 2:
        return PageProfile();
      default:
        return Container();
    }
  }

  static DashboardManagerController get() => Get.find();

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

    final result = await CustomerOrderSnapshot.getOrderSummaryStatistic();
    summary = result["summary"];
    dailyRevenue = result["dailyRevenue"];
    isLoading = false;
    update();
  }
}

class BindingDashboardController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardManagerController());
  }
}
