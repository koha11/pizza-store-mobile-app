import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';

class PageShoppingCart extends StatelessWidget {
  const PageShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    // Đảm bảo controller được khởi tạo
    final controller = Get.put(ShoppingCartController());
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Giỏ hàng")),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: GetBuilder<ShoppingCartController>(
          id: 'cart_items',  // ID để cập nhật UI
          builder: (controller) {
            print('Building cart with ${controller.cartItems.length} items');
            if (controller.cartItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("asset/images/anhnen.png", width: 150),
                    const SizedBox(height: 10),
                    const Text(
                      "Giỏ hàng trống!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MainLayout()),
                        );
                      },
                      child: const Text("Tìm kiếm món ăn"),
                    )
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.cartItems.values.elementAt(index);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: item.item?.itemImage != null
                              ? Image.network(
                                  item.item!.itemImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fastfood, size: 40),
                          title: Text(item.item?.itemName ?? "Không rõ tên"),
                          subtitle: Text("${item.actualPrice} vnđ"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  controller.updateItemAmount(
                                    item.itemId,
                                    item.amount - 1,
                                  );
                                },
                              ),
                              Text("${item.amount}"),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  controller.updateItemAmount(
                                    item.itemId,
                                    item.amount + 1,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  controller.removeFromCart(item.itemId);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng tiền:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${controller.totalAmount} vnđ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.snackbar(
                              'Thông báo',
                              'Chức năng đặt hàng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text(
                            "Đặt hàng",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
