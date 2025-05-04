import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_home.dart';

class PageHome extends StatelessWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.network("https://ilmio.vn/uploads/slider/10.png"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Find by category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "See All",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
          GridView.count(
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.75,
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(20, (index) {
              return Container(
                height: 200,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Text("data $index"),
              );
            }),
          ),
        ],
      ),
    );
  }
}
