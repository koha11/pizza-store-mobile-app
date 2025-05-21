import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_pending_cart.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PagePendingCart extends StatelessWidget {
  const PagePendingCart({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Get.find<UserController>().appUser?.userId;
    return Scaffold(
      appBar: AppBar(title: Text("Đơn hàng đang chờ")),
      body: GetBuilder<ShoppingCartPending>(
        init: ShoppingCartPending()..fetchPendingOrders(userId!),
        builder: (controller) {
          if (controller.pendingOrders.isEmpty) {
            return Center(child: Text("Không có đơn hàng nào!"));
          }
          return ListView.builder(
            itemCount: controller.pendingOrders.length,
            itemBuilder: (context, index) {
              final order = controller.pendingOrders[index];
              return FutureBuilder<Map<String, OrderDetail>>(
                future: CustomerOrderSnapshot.getCartItems(order.orderId),
                builder: (context, snapshot) {
                  final details = snapshot.data?.values.toList() ?? [];
                  return Card(
                    margin: EdgeInsets.all(12),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Đơn hàng: ${order.orderId}", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...details.map((detail) => Text("${detail.item?.itemName ?? ''} x${detail.amount}")),
                          SizedBox(height: 8),
                          Text("Tổng tiền: ${order.total}đ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: OrderStatus.fromString(order.status).color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(OrderStatus.fromString(order.status).displayText, style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Xem chi tiết
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text("<< Xem chi tiết >>"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
