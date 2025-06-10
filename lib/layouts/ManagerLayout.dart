import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_dashboard_manager.dart';
import 'package:pizza_store_app/pages/shipper/PagePendingOrder.dart';
import 'package:pizza_store_app/pages/home/PageSearch.dart';
import 'package:pizza_store_app/pages/PageShopping_cart.dart';

import '../controllers/controller_home.dart';
import '../controllers/controller_search.dart';
import '../controllers/controller_location.dart';

class ManagerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: "1",
      init: DashboardManagerController.get(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "${controller.getTitlePage()}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          bottomNavigationBar: GetBuilder<DashboardManagerController>(
            id: "1",
            builder:
                (controller) => BottomNavigationBar(
                  backgroundColor: Colors.white,
                  currentIndex: controller.currentIndex,
                  onTap: (value) {
                    controller.changePage(value);
                  },
                  selectedItemColor:
                      Theme.of(context).colorScheme.inversePrimary,
                  iconSize: 32.0,
                  unselectedLabelStyle: TextStyle(color: Colors.white),
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Doanh thu',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart),
                      label: 'Đơn hàng',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Hồ sơ',
                    ),
                  ],
                ),
          ),
          body: GetBuilder<DashboardManagerController>(
            id: "1",
            builder:
                (controller) => controller.getPage(controller.currentIndex),
          ),
        );
      },
    );
  }
}
