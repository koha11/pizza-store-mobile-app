import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_history_cart.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:pizza_store_app/pages/order_history/PageHistoryOrder.dart';
import 'package:pizza_store_app/widgets/ShowSnackbar.dart';

import '../../layouts/MainLayout.dart';
import '../../widgets/LoadingDialog.dart';

class PageHistoryOrderDetail extends StatefulWidget {
  final List<OrderDetail> selectedItems;
  PageHistoryOrderDetail({
    super.key,
    required this.selectedItems,
    required this.order,
  });
  final CustomerOrder order;
  @override
  State<PageHistoryOrderDetail> createState() => _PageHistoryOrderDetailState();
}

class _PageHistoryOrderDetailState extends State<PageHistoryOrderDetail> {
  @override
  Widget build(BuildContext context) {
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
                    _buildPriceRow(
                      "Tạm tính:",
                      formatMoney(
                        money:
                            ((widget.order.total ?? 0) -
                                (widget.order.shippingFee ?? 0)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      "Phí vận chuyển:",
                      formatMoney(money: widget.order.shippingFee!),
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      "Tổng cộng:",
                      formatMoney(money: widget.order.total ?? 0),
                      isTotal: true,
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
              const Text("Thông tin giao hàng"),
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
                        loadingDialog();
                        await CustomerOrderSnapshot.deletePendingOrder(
                          widget.order,
                        );
                        // Cập nhật lại danh sách đơn hàng
                        await HistoryCartController.get().fetchPendingOrders();
                        showSnackBar(desc: "Đã hủy đơn hàng!", success: true);
                        Get.offAll(
                          () => MainLayout(),
                          binding: getRoleControllerBindings(""),
                        ); // Quay lại trang danh sách đơn hàng
                      } catch (e) {
                        showSnackBar(
                          desc: "Không thể hủy đơn hàng: $e",
                          success: false,
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