import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_home.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: "1",
      init: HomePizzaStoreController.get(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
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
                icon: Icon(Icons.list_alt_outlined),
                label: 'Hoạt động',
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
