import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/dialogs/dialog.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';

import '../../controllers/controller_item_admin.dart';

class PageItemsAdmin extends StatefulWidget {
  PageItemsAdmin({super.key});

  @override
  State<PageItemsAdmin> createState() => _PageItemsAdminState();
}

class _PageItemsAdminState extends State<PageItemsAdmin> {
  final itemController = Get.put(ItemAdminController());

  @override
  void initState() {
    super.initState();
    itemController.resetSearchState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemAdminController>(
      init: ItemAdminController.get(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Quản lý Sản phẩm',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: controller.handleSearch,
                      ),
                    ),
                    const Expanded(flex: 1, child: Text("")),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () => showAddItemDialog(context),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue[200]!,
                          ),
                        ),
                        tooltip: 'Thêm sản phẩm',
                        icon: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Thêm'),
                            SizedBox(width: 8.0),
                            Icon(Icons.add),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const SizedBox(height: 2),
                  controller.isLoadingItem
                      ? const Center(child: CircularProgressIndicator())
                      : Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          'Hình ảnh',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 4,
                                      child: Text(
                                        'Tên sản phẩm',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Loại',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Giá',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Thao tác',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.paginatedItems.length,
                                itemBuilder: (context, index) {
                                  final item = controller.paginatedItems[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(item.itemId),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child:
                                              item.itemImage != null &&
                                                      item.itemImage!.isNotEmpty
                                                  ? Image.network(
                                                    item.itemImage!,
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.contain,
                                                  )
                                                  : const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(item.itemName),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.category.categoryName,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            formatMoney(money: item.price),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                color: Colors.blue,
                                                onPressed:
                                                    () => showUpdateItemDialog(
                                                      context,
                                                      item,
                                                    ), //sửa
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                color: Colors.red,
                                                onPressed: () async {
                                                  await controller
                                                      .confirmAndRemoveItem(
                                                        context,
                                                        item,
                                                      );
                                                }, //xóa
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed:
                                        controller.currentPage > 1
                                            ? controller.previousPage
                                            : null,
                                  ),
                                  Text(
                                    'Trang ${controller.currentPage}/${controller.totalPages}',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed:
                                        controller.currentPage <
                                                controller.totalPages
                                            ? controller.nextPage
                                            : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
