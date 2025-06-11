import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_history_cart.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/pages/auth/PageLogin.dart';
import 'package:pizza_store_app/pages/order_history/PageHistoryOderDetail.dart';

class PageHistoryOrderCart extends StatelessWidget {
  const PageHistoryOrderCart({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Get.find<UserController>().appUser?.userId;
    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Vui lòng đăng nhập để xem đơn hàng",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.to(PageLogin()),
                child: Text("Đăng nhập"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: GetBuilder<HistoryCartController>(
        init: HistoryCartController(),
        builder: (controller) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.pendingOrders.isEmpty) {
            return Center(child: Text("Không có đơn hàng nào!"));
          }
          return ListView.builder(
            itemCount: controller.pendingOrders.length,
            itemBuilder: (context, index) {
              final order = controller.pendingOrders[index];
              final orderDetails = order.orderDetails ?? [];
              // Tính tổng tiền từ orderDetails
              int subTotal = 0;
              if (orderDetails.isNotEmpty) {
                subTotal = orderDetails.fold(0, (sum, item) {
                  return sum + ((item.actualPrice ?? 0) * (item.amount ?? 0));
                });
              }
              int total = subTotal + (order.shippingFee ?? 0);

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Đơn hàng: ${order.orderId}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: order.status.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status.displayText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Divider(height: 20, thickness: 1),
                      Text(
                        "Danh sách món:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 6),
                      ...orderDetails.map(
                        (detail) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_pizza,
                                size: 18,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "${detail.item.itemName ?? 'Món'} x${detail.amount}",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tạm tính:",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            formatMoney(money: subTotal),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Phí ship:",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${order.shippingFee} vnđ",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tổng cộng:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.redAccent,
                            ),
                          ),
                          Text(
                            "$total vnđ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(
                              PageHistoryOderDetail(
                                selectedItems: orderDetails,
                                order: order,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: Icon(Icons.receipt_long),
                          label: Text(
                            "Xem chi tiết",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}