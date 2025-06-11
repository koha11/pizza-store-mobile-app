import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_history_cart.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';

class PageHistoryOderDetail extends StatefulWidget {
  final List<OrderDetail> selectedItems;
  PageHistoryOderDetail({
    super.key,
    required this.selectedItems,
    required this.order,
  });
  final CustomerOrder order;
  @override
  State<PageHistoryOderDetail> createState() => _PageHistoryOderDetailState();
}

class _PageHistoryOderDetailState extends State<PageHistoryOderDetail> {
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
                          Text(
                            formatMoney(
                              money: widget.order.shippingFee!.toInt(),
                            ),
                          ),
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

              Card(
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
                        child: Text("Địa chỉ: ${widget.order.shippingAddress}"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.order.status == OrderStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await OrderDetailSnapshot.clearCart(
                          orderId: widget.order.orderId,
                        );
                        // Cập nhật lại danh sách đơn hàng
                        final controller = Get.find<HistoryCartController>();
                        await controller.fetchPendingOrders();
                        Get.back(); // Quay lại trang danh sách đơn hàng
                        Get.snackbar(
                          "Thành công",
                          "Đã hủy đơn hàng!",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } catch (e) {
                        Get.snackbar(
                          "Lỗi",
                          "Không thể hủy đơn hàng: $e",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      "Hủy đơn hàng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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