import 'package:flutter/material.dart';

class PageOrderDetailManager extends StatelessWidget {
  PageOrderDetailManager({super.key});
  final fakeUser = {
    "user_id": "U001",
    "user_name": "Nguyễn Văn A",
    "user_email": "vana@gmail.com",
    "phone_number": "0912345678",
    "user_avatar": null,
  };

  final fakeOrder = {
    "order_id": "OR0001",
    "customer_id": "U001",
    "manager_id": "M002",
    "shipper_id": "S003",
    "order_time": "2025-05-17 14:22",
    "status": "Chờ xác nhận",
    "payment_method": false,
    "total_amount": 220000,
    "shipping_fee": 20000,
    "note": "Giao trước 5h",
    "shipping_address": "123 Trần Phú, Nha Trang",
  };

  final fakeOrderDetails = [
    {
      "item_id": "IT001",
      "item_name": "Pizza Hải sản",
      "item_image": "https://via.placeholder.com/50",
      "amount": 1,
      "actual_price": 120000,
      "note": "Không ớt",
    },
    {
      "item_id": "IT002",
      "item_name": "Pizza Bò",
      "item_image": "https://via.placeholder.com/50",
      "amount": 2,
      "actual_price": 80000,
      "note": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final order = fakeOrder;
    final user = fakeUser;
    final details = fakeOrderDetails;

    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết đơn")),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [Text("Đơn đặt #OR001")]),
      ),
    );
  }
}
