import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import '../controllers/controller_ShoppingCart.dart';

class PageDetailItemCart extends StatelessWidget {
  final OrderDetail item;
  PageDetailItemCart({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi Tiết Sản Phẩm"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      item.item?.itemImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.item!.itemImage!,
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.fastfood, size: 100),
                      const SizedBox(height: 12),
                      const Text(
                        "Ảnh Chi tiết Sản phẩm",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.qr_code),
                      title: Text("Mã Sản Phẩm: ${item.itemId}"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(
                          "Tên Sản Phẩm: ${item.item?.itemName ?? "No Name"}"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.format_list_numbered),
                      title: Text("Số Lượng: ${item.amount}"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: Text(
                          "Giá Sản Phẩm: ${item.actualPrice} Vnđ"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text("Chi tiết Sản Phẩm:"),
                      subtitle: Text(
                        item.item?.description ?? "Không có mô tả",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
