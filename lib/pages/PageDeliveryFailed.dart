import 'package:flutter/material.dart';
import 'package:pizza_store_app/pages/shipper/PagePendingOrder.dart';

class PageDeliveryFailed extends StatelessWidget {
  const PageDeliveryFailed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thất Bại"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "asset/images/thatbai.png",
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 25),
              Text(
                "ĐƠN HÀNG GIAO THẤT BẠI",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Rất tiếc đơn hàng của bạn không thể giao thành công.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,MaterialPageRoute(
                        builder: (context) => PagePendingOrder()
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    "QUAY VỀ TRANG CHỦ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // Xử lý liên hệ hỗ trợ
                },
                child: Text(
                  "Liên hệ hỗ trợ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
