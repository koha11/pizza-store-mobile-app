import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_home.dart';

class PageHome extends StatelessWidget {
  PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomePizzaStoreController.get(),
      id: "1",
      builder: (controller) =>  SingleChildScrollView(
        child: Column(
          children: [
            Image.network("https://ilmio.vn/uploads/slider/10.png"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Find by category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  "See All",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            CarouselSlider(
              items: [
                Text("Test 1"),
                Text("Test 2"),
                Text("Test 3"),
                Text("Test 4"),
                Text("Test 5"),
              ],
              options: CarouselOptions(
                height: 200,
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
              ),
            ),
            GridView.count(
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.75,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
              controller.items
                      .map(
                        (item) => Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(item.itemName),
                              Image.network(item.itemImage ?? ""),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
