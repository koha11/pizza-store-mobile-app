import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/customer_order_info.dart';
import 'package:pizza_store_app/pages/PageOrderDetails.dart';

import '../controllers/controller_pending_order.dart';
import '../enums/OrderStatus.dart';

class PagePendingOrder extends StatefulWidget {
  PagePendingOrder({super.key});

  @override
  State<PagePendingOrder> createState() => _PagePendingOrderState();
}

class _PagePendingOrderState extends State<PagePendingOrder> {
  final OrderController orderController = Get.put(OrderController());

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child:
          Text("IL MIO",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white70,
            ),
          )
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            label: "Đơn hàng",
            icon: Icon(Icons.home, color: Colors.blue,),
          ),
          BottomNavigationBarItem(
            label: "Lịch sử",
            icon: Icon(Icons.access_time, color: Colors.red,),
          ),
          BottomNavigationBarItem(
            label: "Thông tin",
            icon: Icon(Icons.person, color: Colors.green,),
          ),
        ],
        onTap: (value){
          setState(() {
            index = value;
          });
        },
      ),
    );
  }

  //Danh sách đơn hàng
  Widget _buildHome() {
    return StreamBuilder<List<CustomerOrderInfo>>(
      stream: orderController.pendingOrderStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        return _buildOrderList(orders); // Pass the pending orders list
      },
    );
  }
  Widget _buildOrderList(List<CustomerOrderInfo> orders) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!, width: 1),
                ),
                child: Center(
                  child: Text(
                    "DANH SÁCH ĐƠN HÀNG (${orders.length})", // Update count based on the passed list
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(top: 10),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Đơn hàng: ${order.orderId}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  _buildInfoRow(Icons.person, order.customerName,
                                      iconColor: Colors.blue),
                                  _buildInfoRow(Icons.location_on,
                                      order.shippingAddress,
                                      iconColor: Colors.red),
                                  _buildInfoRow(Icons.phone, order.phoneNumber,
                                      iconColor: Colors.green),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    "${order.orderTime.day}/${order.orderTime.month}/${order.orderTime.year}",
                                    iconColor: Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: _buildStatusBadge(order.status),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => PageOrderDetails(orderId: order.orderId));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[500],
                              foregroundColor: Colors.white,
                              elevation: 5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "<< Xem chi tiết >>",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
  //Thông tin Shipper
  Widget _buildShipperInfoSection(OrderController controller) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!, width: 1),
                ),
                child: Text(
                  "THÔNG TIN NHÂN VIÊN GIAO HÀNG",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ),
            //Hình ảnh nhân viên
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 3 / 4,
                child: Image.asset(
                  'asset/images/avt.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            //Thông tin nhân viên
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 3 / 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShipperInfoRow(
                      Icons.badge,
                      controller.shipperId.value,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildShipperInfoRow(
                      Icons.person,
                      controller.shipperName.value,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildShipperInfoRow(
                      Icons.phone,
                      controller.shipperPhone.value,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
  Widget _buildShipperInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  //Lịch sử đơn hàng
  Widget _buildHistory() {
    return StreamBuilder<List<CustomerOrderInfo>>(
      stream: orderController.historyOrderStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        return _buildOrderList(orders); // Pass the history orders list
      },
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody(int index){
    switch(index) {
      case 0: return _buildHome();
      case 1: return _buildHistory();
      case 2: return _buildShipperInfoSection(orderController);
      default: return _buildHome();
    }
  }
}