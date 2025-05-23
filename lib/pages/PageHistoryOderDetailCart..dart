import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';

class PagePendingDetailCart extends StatefulWidget {
  final List<OrderDetail> selectedItems;
  PagePendingDetailCart({
    super.key,
    required this.selectedItems,
    required this.order,
  });
  final CustomerOrder order;
  @override
  State<PagePendingDetailCart> createState() => _PagePendingDetailCartState();
}

class _PagePendingDetailCartState extends State<PagePendingDetailCart> {
  @override
  Widget build(BuildContext context) {
    int subTotal = widget.selectedItems.fold(
      0,
      (sum, item) => sum + (item.actualPrice * item.amount),
    );
    int total = subTotal + (widget.order.shippingFee ?? 0);
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
                                    item.item?.itemName ?? "Không rõ tên",
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text("${item.amount}"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text("${item.actualPrice}đ"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    "${item.actualPrice * item.amount}đ",
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
                          Text("${subTotal}đ"),
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
                          Text("${widget.order.shippingFee}đ"),
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
                            "${total}đ",
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
                id: "address",
                builder: (userController) {
                  final addresses = userController.userAddress?.first.address;
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
                          Expanded(child: Text("Địa chỉ: ${addresses}")),
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
                    Get.snackbar(
                      "Thành công",
                      "Hủy đơn hàng!",
                      snackPosition: SnackPosition.BOTTOM,
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
                    "Hủy đơn hàng",
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
