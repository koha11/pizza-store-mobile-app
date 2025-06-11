import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/pages/auth/PageLogin.dart';
import 'package:pizza_store_app/pages/shipper/PagePendingOrder.dart';
import 'package:pizza_store_app/pages/home/PageSearch.dart';
import 'package:pizza_store_app/pages/PageShopping_cart.dart';

import '../controllers/controller_home.dart';
import '../controllers/controller_search.dart';
import '../controllers/controller_location.dart';

class MainLayout extends StatelessWidget {
  // final LocationController controller = Get.put(LocationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: GetX<LocationController>(
          init: LocationController.get(),
          builder: (controller) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: controller.fetchLocation,
                  icon: Icon(Icons.location_on_outlined),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      controller.selectedAddress.value,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(PageSearch(), binding: BindingsSearch());
            },
            icon: Icon(Icons.search),
          ),
          GetBuilder<ShoppingCartController>(
            init: ShoppingCartController.get(),
            builder: (controller) {
              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                showBadge: controller.totalItems > 0,
                badgeContent: Text(
                  '${controller.totalItems}',
                  style: TextStyle(color: Colors.white),
                ),
                child: IconButton(
                  onPressed: () {
                    if (UserController.get().appUser == null) {
                      Get.to(() => PageLogin());
                    } else {
                      Get.to(
                        PageShoppingCart(),
                        binding: BindingsShoppingCart(),
                      );
                    }
                  },
                  icon: Icon(Icons.shopping_cart),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: GetBuilder(
        init: HomePizzaStoreController.get(),
        builder:
            (controller) => BottomNavigationBar(
              currentIndex: controller.currentIndex % 3,
              onTap: (value) {
                if (value == 2 && UserController.get().appUser == null) {
                  Get.to(() => PageLogin());
                } else {
                  controller.changePage(value);
                }
              },
              selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
              iconSize: 32.0,
              unselectedLabelStyle: TextStyle(color: Colors.white),
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_outlined),
                  label: 'Hoạt động',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
      ),
      body: GetBuilder(
        init: HomePizzaStoreController.get(),
        builder: (controller) => controller.getPage(controller.currentIndex),
      ),
    );
  }
}

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocationController());
  }
}
