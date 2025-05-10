import 'package:flutter/material.dart';

<<<<<<< HEAD
class PageShoppingCart extends StatelessWidget {
  const PageShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
=======
class PageshoppingCart extends StatefulWidget {
  const PageshoppingCart({super.key});

  @override
  State<PageshoppingCart> createState() => _PageshoppingCartState();
}

class _PageshoppingCartState extends State<PageshoppingCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giỏ hàng"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Muốn ăn lăn ra trang Home"),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {

                },
                child: Text("Tìm kiếm món ăn"))
          ],
        ),
      ),
    );
>>>>>>> main
  }
}
