import 'package:flutter/material.dart';
import 'package:pizza_store_app/admin/user_admin/PageAppUserAdmin.dart';
import 'package:pizza_store_app/admin/item_admin/PageItemsAdmin.dart';

class PageAdmin extends StatefulWidget {
  const PageAdmin({super.key});

  @override
  State<PageAdmin> createState() => _PageAdminState();
}

class _PageAdminState extends State<PageAdmin> {
  Widget _currentPage = const HomePageAdmin();

  void _navigateToPage(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width:300,),
              TextButton(
                onPressed: () => _navigateToPage(const HomePageAdmin()),
                child: const Text("Trang Chủ",style: TextStyle(
                  fontWeight: FontWeight.bold
                ),),
              ),
              TextButton(
                onPressed: () => _navigateToPage(PageItemsAdmin()),
                child: const Text("Sản Phẩm",style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
              ),
              TextButton(
                onPressed: () => _navigateToPage(PageAppUserAdmin()),
                child: const Text("Khách hàng",style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
              ),
              SizedBox(width: 300,),
            ],
          ),
        ),
      ),
      body: _currentPage, // Hiển thị trang hiện tại
      backgroundColor: Colors.pink[100],
    );
  }
}

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Chào mừng đến trang quản trị!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text("Chọn một mục trên thanh điều hướng để tiếp tục."),
        ],
      ),
    );
  }
}