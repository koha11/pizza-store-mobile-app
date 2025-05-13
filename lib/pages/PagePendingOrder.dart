import 'package:flutter/material.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/pages/PageHome.dart';

class PagePendingOrder extends StatefulWidget {
  PagePendingOrder({super.key});

  @override
  State<PagePendingOrder> createState() => _PagePendingOrderState();
}

class _PagePendingOrderState extends State<PagePendingOrder> {
  late Future<List<CustomerOrder>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = CustomerOrderSnapshot.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh Sách Đơn Hàng"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Màu nền dự phòng nếu ảnh lỗi
                          ),
                          child: Image.asset(
                            'asset/images/avt.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dòng mã nhân viên
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.badge, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'UI0001', // Cần lấy dữ liệu nhân viên thực tế nếu có
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Dòng họ tên
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.person, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'DƯƠNG QUANG THẮNG', // Cần lấy dữ liệu nhân viên thực tế nếu có
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Dòng số điện thoại
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.phone, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '0935xxxx79', // Cần lấy dữ liệu nhân viên thực tế nếu có
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!, width: 1),
                  ),
                  child: Text(
                    "DANH SÁCH ĐƠN HÀNG",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ),
              FutureBuilder<List<CustomerOrder>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Đã có lỗi xảy ra: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Không có đơn hàng nào."));
                  } else {
                    final orders = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PageHome(), // Chuyển đến trang chi tiết đơn hàng nếu cần
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.only(bottom: 10),
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "ĐƠN HÀNG: ${order.orderId}",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(Icons.person, size: 20, color: Colors.green),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "${order.customerId}", // Bạn có thể cần lấy tên khách hàng từ ID này
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on, size: 20, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "${order.shippingAddress}",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              // Bạn có thể hiển thị thêm thông tin khác nếu cần
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today, size: 20, color: Colors.orange),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "${order.orderTime.toLocal().toString().split(' ')[0]}", // Hiển thị ngày đặt hàng
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(order.status.toString().split('.').last),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              order.status.toString().split('.').last == "pending" ? "Đang chờ" : order.status.toString().split('.').last == "processing" ? "Đang xử lý" : order.status.toString().split('.').last == "delivered" ? "Đã giao" : "Đã hủy",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "delivered":
        return Colors.green;
      case "processing":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      case "pending":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}