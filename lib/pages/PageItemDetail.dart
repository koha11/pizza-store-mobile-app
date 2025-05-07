import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';

import '../models/Item.model.dart';

class PageItemDetail extends StatefulWidget {
  Item item;
  PageItemDetail({super.key, required this.item});

  @override
  State<PageItemDetail> createState() => _PageItemDetailState();
}

class _PageItemDetailState extends State<PageItemDetail> {
  int amount = 1;
  @override
  Widget build(BuildContext context) {
    Item myItem = widget.item;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(myItem.itemImage ?? ""),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${myItem.itemName}",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${myItem.price}",
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  Row(children: []),
                  SizedBox(height: 20),
                  Divider(height: 2, thickness: 2),
                  SizedBox(height: 10),
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  Text("${myItem.description ?? ""}"),
                  SizedBox(height: 10),
                  Text(
                    "Món bạn có thể thử",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  Container(height: 300),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
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
                        if (amount > 1) {
                          --amount;
                          setState(() {});
                        }
                      },
                    ),
                    SizedBox(width: 8),
                    Text("$amount", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        ++amount;
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Text(
                  "${myItem.price * amount}",
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
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
