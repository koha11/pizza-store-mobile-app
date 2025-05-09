import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/pages/PageItemDetail.dart';

import '../controllers/controller_item_detail.dart';
import '../controllers/controller_search.dart';

class PageSearch extends StatelessWidget {
  const PageSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: MySearchingBar()),
      body: GetBuilder(
        id: "1",
        init: SearchItemController.get(),
        builder: (controller) {
          final items = controller.items.toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Text(items[index].itemName),
                    onTap:
                        () => Get.to(
                          PageItemDetail(item: items[index]),
                          binding: BindingsItemDetail(),
                          arguments: {
                            'id': items[index].itemId,
                            'category_id': items[index].category.categoryId,
                          },
                        ),
                  );
                },
                separatorBuilder: (context, index) => Divider(thickness: 2),
                itemCount: items.length,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MySearchingBar extends StatelessWidget {
  const MySearchingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController searchController = SearchController();
    final controller = SearchItemController.get();

    return SizedBox(
      height: 40,
      child: SearchBar(
        controller: searchController,
        hintText: "Nhập món bạn muốn tìm ...",
        onChanged: (value) {
          controller.searchItem(value);
        },
        trailing: [
          IconButton(
            onPressed: () {
              searchController.clear();
              controller.searchItem("");
            },
            icon: Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
