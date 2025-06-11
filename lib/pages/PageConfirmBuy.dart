import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'dart:math';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:pizza_store_app/pages/order_history/PageHistoryOderDetail.dart';
import 'package:pizza_store_app/pages/order_history/PageHistoryOrder.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
import '../controllers/controller_ShoppingCart.dart';
import '../controllers/controller_user.dart';

class PageConfirmBuy extends StatefulWidget {
  final List<OrderDetail> selectedItems;
  PageConfirmBuy({super.key, required this.selectedItems});

  @override
  State<PageConfirmBuy> createState() => _PageConfirmBuyState();
}

class _PageConfirmBuyState extends State<PageConfirmBuy> {
  int shippingFee = (10 + Random().nextInt(11)) * 1000;
  String? selectedAddressId;

  @override
  Widget build(BuildContext context) {
    int subTotal = widget.selectedItems.fold(
      0,
      (sum, item) => sum + (item.actualPrice * item.amount),
    );
    int totalAmount = widget.selectedItems.fold(
      0,
      (sum, item) => sum + item.amount,
    );
    int total = subTotal + shippingFee;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Chi tiết đơn hàng",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...widget.selectedItems.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.item.itemName ?? "Không rõ tên",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...item.variantMaps.entries.map((entry) {
                                      final variantNames = entry.value
                                          .map((variant) => variant.variantName)
                                          .join(", ");
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          "• $variantNames",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "x${item.amount}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMoney(
                                      money: item.actualPrice * item.amount,
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      _buildPriceRow("Tạm tính:", formatMoney(money: subTotal)),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        "Phí vận chuyển:",
                        formatMoney(money: shippingFee),
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        "Tổng cộng:",
                        formatMoney(money: total),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Thông tin giao hàng",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GetBuilder<UserController>(
                        builder: (userController) {
                          final addresses =
                              userController.appUser!.addresses ?? [];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child:
                                      addresses.isEmpty
                                          ? const Text(
                                            "Không có địa chỉ",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )
                                          : DropdownButton<String>(
                                            isExpanded: true,
                                            value: selectedAddressId,
                                            items:
                                                addresses.map((address) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: address.address,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          address.addressNickName ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        Text(
                                                          address.address,
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedAddressId = value;
                                              });
                                            },
                                            underline: Container(),
                                          ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedAddressId == null) {
                        Get.snackbar(
                          "Lỗi",
                          "Vui lòng chọn địa chỉ giao hàng",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      await ShoppingCartController.get().placeOrder(
                        shippingFee: shippingFee,
                        address: selectedAddressId!,
                        totalAmount: totalAmount,
                      );

                      HomePizzaStoreController.get().changePage(1);
                      Get.off(
                        () => MainLayout(),
                        binding: getRoleControllerBindings(""),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Đặt Hàng",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    loadingDialog();

                    await ShoppingCartController.get().placeOrder(
                      shippingFee: shippingFee,
                      address: selectedAddressId!,
                      totalAmount: totalAmount,
                    );

                    HomePizzaStoreController.get().changePage(1);
                    Get.offAll(
                      () => MainLayout(),
                      binding: getRoleControllerBindings(""),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 16,
            color: isTotal ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }
}