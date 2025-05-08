import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:pizza_store_app/pages/PageHome.dart';

import '../models/Item.model.dart';

class PageItem extends StatelessWidget {
  Iterable<Item> items;
  PageItem({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(child: ItemsGridView(items: items)),
    );
  }
}
