import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/pages/PageDeliveryFailed.dart'; // Import các trang liên quan
import 'package:pizza_store_app/pages/PageDeliverySuccessful.dart'; // Import các trang liên quan
import '../controllers/controller_order_detail.dart'; // Đảm bảo đường dẫn đúng
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/pages/PageDeliveryFailed.dart'; // Import các trang liên quan
import 'package:pizza_store_app/pages/PageDeliverySuccessful.dart'; // Import các trang liên quan
import '../controllers/controller_order_detail.dart'; // Đảm bảo đường dẫn đúng

class PageOrderDetails extends StatelessWidget {
  final String orderId;

  const PageOrderDetails({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderDetailsController controller =
    Get.put(OrderDetailsController(orderId)); // Khởi tạo controller

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        // Sử dụng Obx để tự động cập nhật khi có thay đổi trong controller
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.orderDetails.isEmpty) {
          return const Center(child: Text("Không có chi tiết đơn hàng.")); //Xử lý edge case
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin khách hàng
              _buildCustomerInfoCard(controller),
              const SizedBox(height: 24),

              // Chi tiết đơn hàng
              _buildOrderDetailsCard(controller),
              const SizedBox(height: 24),

              // Thông tin giao hàng
              _buildDeliveryInfoCard(controller),
              const SizedBox(height: 24),

              // Nút hành động
              _buildActionButtons(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCustomerInfoCard(OrderDetailsController controller) {
    final firstItem = controller.orderDetails.first; // Truy cập phần tử đầu tiên
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
                  firstItem.customerName,
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
                      firstItem.phoneNumber,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                controller.openPhoneDial(firstItem.phoneNumber);
              },
              icon: const Icon(Icons.call, size: 20),
              label: const Text("Gọi ngay"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(OrderDetailsController controller) {
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
                Obx(() =>
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.orderDetails.length,
                      separatorBuilder: (context, index) =>
                      const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = controller.orderDetails[index];
                        return Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                item.itemName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(item.amount.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  "${item.unitPrice.toStringAsFixed(0)}đ",
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontSize: 15)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  "${item.subTotal.toStringAsFixed(0)}đ",
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontSize: 15)),
                            ),
                          ],
                        );
                      },
                    )),
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
                            "${controller.totalPrice.toStringAsFixed(0)}đ",
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
                            "${controller.orderDetails.isNotEmpty ? controller
                                .orderDetails
                                .first
                                .shippingFee
                                .toStringAsFixed(0) : '0'}đ",
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

  Widget _buildDeliveryInfoCard(OrderDetailsController controller) {
    final firstItem = controller.orderDetails.first; //chắc chắn có phần tử first
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
                Expanded( //Sử dụng Expanded để tránh tràn nếu địa chỉ quá dài.
                  child: Text(
                    firstItem.deliveryAddress,
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

  Widget _buildActionButtons(OrderDetailsController controller) {
    return Obx(() {
      // Sử dụng Obx để theo dõi sự thay đổi của orderStatus
      if (controller.orderStatus.value ==
          'finished') { // Kiểm tra trạng thái đơn hàng
        return const Center(
          child: Text(
            "Đơn hàng đã được giao", // Hiển thị thông báo
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Trong thực tế, bạn nên hiển thị một dialog xác nhận trước khi hủy
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
                            //Gọi hàm huỷ đơn hàng.
                            //controller.cancelOrder();
                            Get.back(); // Đóng dialog
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
              child:
              //Hiển thị button hoàn tất khi status là shipping.
              controller.orderStatus.value == 'shipping'
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
                //Nếu không phải shipping thì hiển thị button xác nhận đơn hàng
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
      }
    });
  }
}

