import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/pages/home/PageItemDetail.dart';

import '../../controllers/controller_home.dart';
import '../../controllers/controller_item_detail.dart';
import '../../models/Item.model.dart';
import 'PageItem.dart';

class PageHome extends StatelessWidget {
  PageHome({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(HomePizzaStoreController());

    return GetBuilder(
      init: HomePizzaStoreController.get(),
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
                          GestureDetector(
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                fontSize: 20,
                              ),
                            ),
                            onTap: () {
                              controller.changePage(3);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      CarouselSlider(
                        items:
                            controller.categories
                                .map(
                                  (category) => OutlinedButton(
                                    onPressed: () {
                                      controller.setCurrCategoryId(
                                        category.categoryId,
                                      );
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          controller.getCurrCategoryId() ==
                                                  category.categoryId
                                              ? WidgetStatePropertyAll<Color>(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.inversePrimary,
                                              )
                                              : null,
                                    ),
                                    child: Text(category.categoryName),
                                  ),
                                )
                                .toList(),
                        options: CarouselOptions(
                          height: 50,
                          autoPlay: false,
                          enlargeCenterPage: false,
                          initialPage: 0,
                          viewportFraction: 0.4,
                          enableInfiniteScroll: true,
                        ),
                      ),
                      SizedBox(height: 30),
                      ItemsGridView(
                        items: controller.getItems(
                          controller.getCurrCategoryId(),
                        ),
                      ),
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
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.5,
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
                        Image.network(
                          item.itemImage ?? "",
                          fit: BoxFit.fitWidth,
                          height: 200,
                        ),
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
                          formatMoney(money: item.price),
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
                        arguments: {
                          'id': item.itemId,
                          'category_id': item.category.categoryId,
                        },
                      );
                    },
                  ),
                ),
              )
              .toList(),
    );
  }
}
