import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:pizza_store_app/pages/home/PageHome.dart';

import '../../controllers/controller_home.dart';
import '../../models/Item.model.dart';

class PageItem extends StatelessWidget {
  const PageItem({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: "1",
      init: HomePizzaStoreController.get(),
      builder:
          (controller) => SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ItemsGridView(items: controller.items),
              ),
            ),
          ),
    );
  }
}
