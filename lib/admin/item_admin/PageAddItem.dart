import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/category.model.dart';

import '../../controllers/controller_item.dart';
import '../../models/Item.model.dart';

class PageAddItem extends StatefulWidget {
  const PageAddItem({super.key});

  @override
  State<PageAddItem> createState() => _PageAddItemState();
}

class _PageAddItemState extends State<PageAddItem> {
  final ItemController _controller = Get.find<ItemController>();

  TextEditingController txtId = TextEditingController();
  TextEditingController txtTen = TextEditingController();
  TextEditingController txtGia = TextEditingController();
  TextEditingController txtMota = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadCategories();
  }

  Future<void> _pickImage() async {
    await _controller.pickAndUploadImage();
  }

  Future<void> _addItem() async {
    if (txtId.text.isEmpty || txtTen.text.isEmpty || txtGia.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin.');
      return;
    }
    if (_controller.uploadedImageUrl == null || _controller.uploadedImageUrl!.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng tải lên một ảnh sản phẩm.');
      return;
    }
    if (_controller.selectedCategory == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn danh mục.');
      return;
    }

    final newItem = Item(
      itemId: txtId.text,
      itemName: txtTen.text,
      price: int.parse(txtGia.text),
      description: txtMota.text,
      itemImage: _controller.uploadedImageUrl!,
      category: _controller.selectedCategory!,
    );

    await _controller.addItem(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
              "Thêm sản phẩm",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: txtId,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: const InputDecoration(
                            labelText: "Id",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: txtTen,
                          decoration: const InputDecoration(
                            labelText: "Tên sản phẩm",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: txtGia,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: const InputDecoration(
                            labelText: "Giá",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: txtMota,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Mô tả",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GetBuilder<ItemController>(
                          builder: (controller) {
                            return DropdownButtonFormField<Category>(
                              value: controller.selectedCategory,
                              decoration: const InputDecoration(
                                labelText: "Danh mục",
                                border: OutlineInputBorder(),
                              ),
                              items: controller.category?.map((Category category) {
                                return DropdownMenuItem<Category>(
                                  value: category,
                                  child: Text(category.categoryName),
                                );
                              }).toList(),
                              onChanged: (Category? newValue) {
                                controller.setSelectedCategory(newValue);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Vui lòng chọn danh mục';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    children: [
                      GetBuilder<ItemController>(
                        builder: (controller) {
                          return _buildImagePreview(controller);
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Chọn ảnh"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Thêm sản phẩm"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(ItemController controller) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: controller.isUploadingImage
          ? const Center(child: CircularProgressIndicator())
          : controller.uploadedImageUrl != null && controller.uploadedImageUrl!.isNotEmpty
          ? Image.network(
        controller.uploadedImageUrl!,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.error, color: Colors.red),
      )
          : const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50, color: Colors.grey),
          Text('Chưa có ảnh', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}