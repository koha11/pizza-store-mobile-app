import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controller_order_detail.dart';

class PageOrderDetails extends StatelessWidget {
  final String orderId;

  PageOrderDetails({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailsController>(
      init: OrderDetailsController(orderId: orderId),
      builder: (controller) {
        if (controller.isLoadingCustomerOrder || controller.isLoadingUser) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.customerOrder == null) {
          return const Scaffold(
            body: Center(child: Text("Không tìm thấy đơn hàng")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Chi tiết đơn hàng",
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin khách hàng
                _CustomerInfoCard(controller: controller),
                const SizedBox(height: 24),
                // Chi tiết đơn hàng
                _OrderDetailsCard(controller: controller),
                const SizedBox(height: 24),
                // Thông tin giao hàng
                _DeliveryInfoCard(controller: controller),
                const SizedBox(height: 24),
                // Nút hành động
                _ActionButtons(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final OrderDetailsController controller;

  const _CustomerInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = controller.customer;
    if (user == null) {
      return const Center(child: Text("Không có thông tin khách hàng"));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      user.phoneNumber,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                controller.openPhoneDial(user.phoneNumber);
              },
              icon: const Icon(Icons.call, size: 20),
              label: const Text("Gọi ngay"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  final OrderDetailsController controller;
  _OrderDetailsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final order = controller.customerOrder!;
    final orderDetails = order.orderDetails ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chi tiết đơn hàng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header bảng
                const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Món",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("SL",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Đơn giá",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Thành tiền",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),
                const Divider(thickness: 1, height: 24),
                // Danh sách món
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderDetails.length,
                  itemBuilder: (context, index) {
                    final orderDetail = orderDetails[index];
                    return Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            orderDetail.item.itemName,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(orderDetail.amount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              "${orderDetail.item.price.toStringAsFixed(0)}đ",
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                              "${(orderDetail.amount * orderDetail.item.price).toStringAsFixed(0)}đ",
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ],
                    );
                  },
                ),

                const Divider(thickness: 1, height: 24),
                // Tổng cộng
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tạm tính:",
                            style: TextStyle(fontSize: 15)),
                        Text(
                            "${controller.subTotal.toStringAsFixed(0)}đ",
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Phí vận chuyển:",
                            style: TextStyle(fontSize: 15)),
                        Text(
                            "${order.shippingFee?.toStringAsFixed(0) ?? "0"}đ",
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tổng cộng:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                            "${controller.grandTotal.toStringAsFixed(0)}đ",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliveryInfoCard extends StatelessWidget {
  final OrderDetailsController controller;

  const _DeliveryInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final order = controller.customerOrder!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thông tin giao hàng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text("${order.shippingAddress ?? "Không có địa chỉ "} ",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final OrderDetailsController controller;

  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = controller.customerOrder!;
      final status = controller.orderStatus.value;

      if (status == 'finished') {
        return const Center(
          child: Text(
            "Đơn hàng đã được giao",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text("Xác nhận hủy đơn hàng"),
                    content: const Text(
                        "Bạn có chắc chắn muốn hủy đơn hàng này?"),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Không"),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Có"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Hủy đơn hàng"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: status == 'shipping'
                ? ElevatedButton(
              onPressed: () {
                controller.markOrderAsFinished();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Hoàn tất đơn hàng"),
            )
                : ElevatedButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text("Xác nhận đơn hàng"),
                    content: const Text(
                        "Bạn có chắc chắn muốn xác nhận đơn hàng này?"),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Không"),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.confirmOrder();
                          Get.back();
                        },
                        child: const Text("Có"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Xác nhận đơn hàng"),
            ),
          ),
        ],
      );
    });
  }
}