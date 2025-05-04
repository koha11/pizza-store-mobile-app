import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_home.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePizzaStoreController>(
      id: "home",
      init: HomePizzaStoreController.get(),
      builder: (controller) {
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex,
            onTap: (value) {
              controller.changePage(value);
            },
            selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
            iconSize: 32.0,
            unselectedLabelStyle: TextStyle(color: Colors.white),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          body: controller.getPage(controller.currentIndex),
        );
      },
    );
  }
}
