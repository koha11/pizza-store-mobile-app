import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/pages/PageOrderDetails.dart';

import '../controllers/controller_pending_order.dart';
import '../enums/OrderStatus.dart';

class PagePendingOrder extends StatelessWidget {
  PagePendingOrder({super.key});
  final orderListController = Get.put(OrderListController());

  @override
  Widget build(BuildContext context) {
    int index = 0;
    return GetBuilder<OrderListController>(
      init: OrderListController.get(),
        builder: (controller) {
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
            body: _buildBody(index, context),
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
                index = value;
                controller.update();
              },
            ),
          );

        },
    );

  }
  //Danh sách đơn hàng
  Widget _buildHome() {
    return GetBuilder<OrderListController>(
      init: OrderListController.get(),
      builder: (controller) {
        if (controller.isLoadingPending) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildOrderList(controller.pendingOrders);
      },
    );
  }
  Widget _buildOrderList(List<CustomerOrder> orders) {
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
                                  _buildInfoRow(Icons.person, order.customer?.userName ?? "",
                                      iconColor: Colors.blue),
                                  _buildInfoRow(Icons.location_on, order.shippingAddress ?? "",
                                      iconColor: Colors.red),
                                  _buildInfoRow(Icons.phone, order.customer?.phoneNumber ?? "",
                                      iconColor: Colors.green),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    "${order.orderTime?.day}/${order.orderTime?.month}/${order.orderTime?.year}",
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
  Widget _buildShipperInfoSection(BuildContext context) {
    return GetBuilder<OrderListController>(
      init: OrderListController.get(),
        builder: (controller) {
          if (controller.isLoadingShipper) {
            return const Center(child: CircularProgressIndicator());
          }
          final shipper = controller.shipper.isNotEmpty ? controller.shipper.first : null;

          if (shipper == null) {
            return const Center(child: Text("Không có thông tin nhân viên"));
          }
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
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
                    SizedBox(height: 10,),
                    //Hình ảnh nhân viên
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: shipper.avatar != null && shipper.avatar!.isNotEmpty
                          ? Image.network(
                        shipper.avatar!,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.person, size: 100),
                    ),
                    //Thông tin nhân viên
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildShipperInfoRow(
                            Icons.badge,
                            shipper.userId ,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildShipperInfoRow(
                            Icons.person,
                            shipper.userName,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildShipperInfoRow(
                            Icons.phone,
                            shipper.phoneNumber,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          );
        },
    );
  }
  Widget _buildShipperInfoRow(IconData icon, String text, Color iconColor) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
  //Lịch sử đơn hàng
  Widget _buildHistory() {
    return GetBuilder<OrderListController>(
      init: OrderListController.get(),
      builder: (controller) {
        if (controller.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildOrderList(controller.historyOrders);
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

  Widget _buildBody(int index, BuildContext context){
    switch(index) {
      case 0: return _buildHome();
      case 1: return _buildHistory();
      case 2: return _buildShipperInfoSection(context);
      default: return _buildHome();
    }
  }
}