import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'dart:math';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:pizza_store_app/pages/order_history/PageHistoryOderDetail.dart';
import 'package:pizza_store_app/pages/order_history/PageHistoryOrder.dart';
import '../controllers/controller_ShoppingCart.dart';
import '../controllers/controller_user.dart';
import '../models/user_address.model.dart';

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chi tiết đơn hàng",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        border: const TableBorder(
                          horizontalInside: BorderSide(
                            width: 0.5,
                            color: Colors.black12,
                          ),
                        ),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  "Món",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  "SL",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  "Đơn giá",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  "Thành tiền",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          ...widget.selectedItems.map(
                            (item) => TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    item.item.itemName ?? "Không rõ tên",
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text("${item.amount}"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    formatMoney(money: item.actualPrice),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    formatMoney(
                                      money: item.actualPrice * item.amount,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tạm tính:",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(formatMoney(money: subTotal)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Phí vận chuyển:",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(formatMoney(money: shippingFee)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng cộng:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatMoney(money: total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Thông tin giao hàng",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GetBuilder<UserController>(
                builder: (userController) {
                  final addresses = userController.appUser!.addresses ?? [];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child:
                                addresses.isEmpty
                                    ? const Text("Không có địa chỉ")
                                    : DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedAddressId,
                                      items:
                                          addresses.map((address) {
                                            return DropdownMenuItem<String>(
                                              value: address.address,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    address.addressNickName ??
                                                        "",
                                                  ),
                                                  Text(address.address),
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
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Get.dialog(
                      Center(child: CircularProgressIndicator()),
                      barrierDismissible:
                          false, // prevent closing by tapping outside
                    );

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
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    "Đặt Hàng",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
