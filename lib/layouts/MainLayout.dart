import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/pages/PageHome.dart';
import 'package:pizza_store_app/pages/PageSearch.dart';

import '../controllers/controller_home.dart';
import '../controllers/controller_search.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: GetBuilder(
          id: "1",
          init: HomePizzaStoreController.get(),
          builder: (controller) {
            if (controller.currentIndex == 3) {
              return BackButton(onPressed: () => controller.changePage(0));
            } else {
              return Text("");
            }
          },
        ),
        title: GetBuilder(
          id: "1",
          init: HomePizzaStoreController.get(),
          builder: (controller) {
            final list = ['Apple', 'Banana', 'Orange', 'Mango'];
            String? selectedItem;
            return DropdownButton<String>(
              value: selectedItem,
              items:
                  list
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                selectedItem = value;
              },
              hint: Text("Chọn địa chỉ của bạn"),
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
                      onPressed: () {},
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
