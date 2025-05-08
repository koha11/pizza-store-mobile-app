import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/pages/PageItemDetail.dart';

import '../controllers/controller_home.dart';
import '../controllers/controller_item_detail.dart';
import '../models/Item.model.dart';

class PageHome extends StatelessWidget {
  PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomePizzaStoreController.get(),
      id: "1",
      builder:
          (controller) => SingleChildScrollView(
            child: Column(
              children: [
                Image.network("https://ilmio.vn/uploads/slider/10.png"),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Find by category",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "See All",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      CarouselSlider(
                        items:
                            controller.categories
                                .map((category) => Text(category.categoryName))
                                .toList(),
                        options: CarouselOptions(
                          height: 50,
                          autoPlay: false,
                          enlargeCenterPage: false,
                          viewportFraction: 0.2,
                        ),
                      ),
                      SizedBox(height: 30),
                      ItemsGridView(items: controller.items),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class ItemsGridView extends StatelessWidget {
  Iterable<Item> items;

  ItemsGridView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 0.75,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children:
          items
              .map(
                (item) => GridTile(
                  child: GestureDetector(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Image.network(item.itemImage ?? "")),
                        SizedBox(height: 10),
                        Text(
                          item.itemName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "${item.price} vnđ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.to(
                        PageItemDetail(item: item),
                        binding: BindingsItemDetail(),
                        arguments: {'id': item.itemId},
                      );
                    },
                  ),
                ),
              )
              .toList(),
    );
  }
}
