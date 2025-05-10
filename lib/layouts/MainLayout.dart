import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/pages/PageSearch.dart';
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
          init: Get.put(LocationController()),
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
                      "Chọn vị trí ${controller.selectedAddress.value}"
                      ,
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
          GetBuilder(
            init: HomePizzaStoreController.get(),
            id: "1",
            builder:
                (controller) => Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                         Get.to(PageshoppingCart(),binding: BindingsShoppingcart());
                      },
                      icon: Icon(Icons.shopping_cart),
                    ),
                  ],
                ),
          ),
        ],
      ),
      bottomNavigationBar: GetBuilder(
        init: HomePizzaStoreController.get(),
        id: "1",
        builder:
            (controller) => BottomNavigationBar(
              currentIndex: controller.currentIndex % 3,
              onTap: (value) {
                controller.changePage(value);
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
        id: "1",
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
