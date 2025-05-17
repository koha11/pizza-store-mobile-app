import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

class PageOrdersList extends StatelessWidget {
  PageOrdersList({super.key});

  final currencyFormat = NumberFormat.currency(locale: "vi_VN", symbol: "₫");
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: "orders",
      init: UserController.get(),
      builder: (controller) {
        final List<CustomerOrder> orders = [
          CustomerOrder(
            orderId: "OR0001",
            customerId: "U001",
            managerId: "M001",
            shipperId: "S001",
            orderTime: DateTime.now().subtract(Duration(hours: 2)),
            acceptTime: DateTime.now().subtract(
              Duration(hours: 1, minutes: 30),
            ),
            deliveryTime: null,
            finishTime: null,
            status: OrderStatus.pending,
            paymentMethod: false,
            total: 200000,
            shippingFee: 15000,
            note: "Giao giờ nghỉ trưa",
            shippingAddress: "123 Lê Lợi, Nha Trang",
          ),
          CustomerOrder(
            orderId: "OR0002",
            customerId: "U002",
            managerId: "M002",
            shipperId: "S002",
            orderTime: DateTime.now().subtract(Duration(days: 1, hours: 3)),
            acceptTime: DateTime.now().subtract(Duration(days: 1, hours: 2)),
            deliveryTime: DateTime.now().subtract(Duration(days: 1, hours: 1)),
            finishTime: DateTime.now().subtract(Duration(days: 1)),
            status: OrderStatus.pending,
            paymentMethod: true,
            total: 350000,
            shippingFee: 20000,
            note: "Gọi trước khi giao",
            shippingAddress: "456 Nguyễn Trãi, Nha Trang",
          ),
          CustomerOrder(
            orderId: "OR0003",
            customerId: "U003",
            managerId: "M001",
            shipperId: null,
            orderTime: DateTime.now().subtract(Duration(hours: 5)),
            acceptTime: null,
            deliveryTime: null,
            finishTime: null,
            status: OrderStatus.pending,
            paymentMethod: false,
            total: 150000,
            shippingFee: 10000,
            note: null,
            shippingAddress: "789 Trần Phú, Nha Trang",
          ),
          CustomerOrder(
            orderId: "OR0004",
            customerId: "U004",
            managerId: "M003",
            shipperId: "S004",
            orderTime: DateTime.now().subtract(Duration(hours: 4)),
            acceptTime: DateTime.now().subtract(
              Duration(hours: 3, minutes: 30),
            ),
            deliveryTime: DateTime.now().subtract(Duration(hours: 2)),
            finishTime: null,
            status: OrderStatus.pending,
            paymentMethod: false,
            total: 280000,
            shippingFee: 15000,
            note: "Không lấy ớt",
            shippingAddress: "101 Hùng Vương, Nha Trang",
          ),
        ];
        ;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Danh sách đơn hàng"),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body:
              orders.isEmpty
                  ? Center(child: Text("Chưa có đơn hàng nào"))
                  : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mã đơn: ${order.orderId}',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dateFormat.format(
                                      order.orderTime ?? DateTime.now(),
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.payment, color: Colors.blueAccent),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      order.paymentMethod
                                          ? 'Đã thanh toán'
                                          : 'Chưa thanh toán',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      order.shippingAddress ??
                                          'Không có địa chỉ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tổng: ${currencyFormat.format(order.total ?? 0)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue),
                                  SizedBox(width: 6),
                                  Text(
                                    'Trạng thái: ${_statusOrder(order.status)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _statusColor(order.status),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.deepPurpleAccent;
      case OrderStatus.shipping:
        return Colors.blue;
      case OrderStatus.finished:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusOrder(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Đang xử lý";
      case OrderStatus.shipping:
        return "Đang giao";
      case OrderStatus.finished:
        return "Đã hoàn thành";
      default:
        return "";
    }
  }
}
