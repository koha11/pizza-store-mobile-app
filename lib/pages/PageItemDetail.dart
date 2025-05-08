import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_item_detail.dart';

import '../models/Item.model.dart';

class PageItemDetail extends StatelessWidget {
  Item item;
  PageItemDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder(
        id: item.itemId,
        tag: item.itemId,
        init: ItemDetailController.get(item.itemId),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(item.itemImage ?? ""),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item.itemName}",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${item.price}",
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(height: 2, thickness: 2),
                      SizedBox(height: 10),
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text("${item.description ?? ""}"),
                      SizedBox(height: 10),

                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.variants.length,
                        itemBuilder: (context, index) {
                          var variant = controller.variants.toList()[index];

                          return Text(variant.variantName);
                        },
                      ),

                      Container(height: 300),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: GetBuilder(
        id: item.itemId,
        tag: item.itemId,
        init: ItemDetailController.get(item.itemId),
        builder: (controller) {
          int amount = controller.amount;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          child: Icon(Icons.remove),
                          onPressed: () {
                            controller.decreaseAmount(item.itemId);
                          },
                        ),
                        SizedBox(width: 8),
                        Text("$amount", style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        ElevatedButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            controller.increaseAmount(item.itemId);
                          },
                        ),
                      ],
                    ),
                    Text(
                      "${item.price * amount}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.shopping_cart),
                    label: Text("Thêm vào giỏ hàng"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
