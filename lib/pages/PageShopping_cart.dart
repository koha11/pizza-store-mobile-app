import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/pages/PageConfirmBuy.dart';
import '../dialogs/dialog.dart';
import '../widgets/ShowSnackbar.dart';

class PageShoppingCart extends StatefulWidget {
  const PageShoppingCart({super.key});

  @override
  State<PageShoppingCart> createState() => _PageShoppingCartState();
}

class _PageShoppingCartState extends State<PageShoppingCart> {
  late BuildContext mycontext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Giỏ hàng")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Nút chọn/bỏ chọn tất cả
          IconButton(
            icon: const Icon(Icons.check_box_outline_blank),
            onPressed: () {
              final controller = Get.find<ShoppingCartController>();
              controller.checkAndUnAllItems();
            },
            tooltip: 'Chọn/Bỏ chọn tất cả',
          ),
          // Nút xóa các mục đã chọn
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final controller = Get.find<ShoppingCartController>();
              bool? xacNhan = await showConfirmDialog(
                context,
                "Bạn có muốn xóa các mục đã chọn?",
              );

              if (xacNhan == true) {
                await controller.removeSelectedItems();
                showSnackBar(desc: "Đã xóa các mục đã chọn", success: true);
              }
            },
            tooltip: 'Xóa mục đã chọn',
          ),
        ],
      ),
      body: GetBuilder(
        init: ShoppingCartController.get(),
        builder: (controller) {
          if (controller.cart == null) {
            controller.initializeCart();
            return Center(child: CircularProgressIndicator());
          }

          if (controller.cart!.orderDetails!.isEmpty) {
            return Center(
              child: RefreshIndicator(
                onRefresh: () async => await controller.loadCart(),
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
                        Get.back();
                        HomePizzaStoreController.get().changePage(0);
                      },
                      child: const Text("Tìm kiếm món ăn"),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadCart(),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.cart!.orderDetails!.length,
                    itemBuilder: (context, index) {
                      mycontext = context;
                      final item = controller.cart!.orderDetails![index];

                      return Slidable(
                        key: ValueKey(item.itemId),
                        endActionPane: ActionPane(
                          extentRatio: 0.3,
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                bool? xacNhan = await showConfirmDialog(
                                  mycontext,
                                  "Bạn có muốn xóa ${item.item.itemName}?",
                                );

                                if (xacNhan == true) {
                                  await controller.removeFromCart(
                                    orderDetail: item,
                                  );
                                  showSnackBar(
                                    desc: "Đã xóa các mục đã chọn",
                                    success: true,
                                  );
                                }
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_forever,
                              label: 'Xóa',
                              autoClose: true,
                              flex: 1,
                            ),
                          ],
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value:
                                      controller.checkedItems[item.itemId] ??
                                      false,
                                  onChanged: (bool? value) {
                                    controller.toggleItemCheck(item.itemId);
                                  },
                                ),
                                item.item.itemImage != null
                                    ? Image.network(
                                      item.item.itemImage!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.fastfood, size: 40),
                              ],
                            ),
                            title: Text(item.item.itemName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...item.variantMaps.entries.map((entry) {
                                  return Text(
                                    "  * ${entry.value.map((variant) => variant.variantName).join(", ")},",
                                  );
                                }),
                                Text(formatMoney(money: item.actualPrice)),
                              ],
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    controller.updateAmount(item.itemId, true);
                                  },
                                ),
                                Text("${item.amount}"),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    controller.updateAmount(item.itemId, false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
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
                            formatMoney(money: controller.totalSelectedAmount),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final selectedItems = controller.getSelectedItems();
                            if (selectedItems.isEmpty) {
                              showSnackBar(
                                desc: "Vui lòng chọn ít nhất một món",
                                success: false,
                              );
                              return;
                            }
                            Get.to(
                              () =>
                                  PageConfirmBuy(selectedItems: selectedItems),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.inversePrimary,
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
            ),
          );
        },
      ),
    );
  }
}
