import 'package:flutter/material.dart';
import 'package:pizza_store_app/models/customer_order_info.dart';
import 'package:pizza_store_app/pages/PageHome.dart';
import 'package:pizza_store_app/pages/PageOrderDetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PagePendingOrder extends StatefulWidget {
  const PagePendingOrder({super.key});

  @override
  State<PagePendingOrder> createState() => _PagePendingOrderState();
}

class _PagePendingOrderState extends State<PagePendingOrder> {
  List<CustomerOrderInfo> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await Supabase.instance.client
          .from('customer_order')
          .select('''
      order_id,
      shipping_address,
      shipper_id,
      order_time,
      status,
      app_user!customer_order_customer_id_fkey (
        user_name,
        phone_number
      ),
      shipper:app_user!customer_order_shipper_id_fkey (
        user_id,
        user_name,
        phone_number
      )
    ''');


      print("Dữ liệu trả về: $response");

      if (response is List) {
        setState(() {
          orders = response.map((json) => CustomerOrderInfo.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Dữ liệu không hợp lệ");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy dữ liệu: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh Sách Đơn Hàng"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
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
                                  child: Text(orders.isNotEmpty ? orders[0].shipperId : '',
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
                                    orders.isNotEmpty ? orders[0].shipperName : '',
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
                                    orders.isNotEmpty ? orders[0].shipperPhone : '',
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
                  child: Center(
                    child: Text(
                      "DANH SÁCH ĐƠN HÀNG (${orders.length})", // Thêm tổng số đơn ở đây
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
                physics: NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: EdgeInsets.only(top: 10),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex:2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Đơn hàng: ${order.orderId}", style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),),
                                    _buildInfoRow(Icons.person, order.customerName, iconColor: Colors.blue),
                                    _buildInfoRow(Icons.location_on, order.shippingAddress, iconColor: Colors.red),
                                    _buildInfoRow(Icons.phone, order.phoneNumber, iconColor: Colors.green),
                                    _buildInfoRow(
                                      Icons.calendar_today,
                                      "${order.orderTime.day}/${order.orderTime.month}/${order.orderTime.year}",
                                      iconColor: Colors.orange,
                                    ),
                                  ],
                                )
                              ),
                              SizedBox(width: 10,),
                              Center(
                                child: Expanded(
                                  flex: 1,
                                  child: _buildStatusBadge(order.status),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 7,),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PageOrderDetails(orderId: order.orderId)), // Thay PageHome() bằng màn hình bạn muốn điều hướng đến
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[500], // Màu nền
                                foregroundColor: Colors.white, // Màu chữ
                                elevation: 5, // Độ nổi của button
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Bo góc
                                ),
                              ),
                              child: Text(
                                "<< Xem chi tiết >>",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
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
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    if (status == "finished") {
      bgColor = Colors.green;
    } else if (status == "shipping") {
      bgColor = Colors.orange;
    } else {
      bgColor = Colors.red;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration:
      BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

