import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_store_app/models/category.model.dart';
import '../controllers/item_controller.dart';
import '../model/item.admin.model.dart';

class PageUpdateItem extends StatefulWidget {
  final ItemAdmin item;

  const PageUpdateItem({super.key, required this.item});

  @override
  State<PageUpdateItem> createState() => _PageUpdateItemState();
}

class _PageUpdateItemState extends State<PageUpdateItem> {
  late final UpdateItemController _controller;
  Future<List<Category>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _controller = UpdateItemController(
      context: context,
      setStateCallback: setState,
      initialItem: widget.item,
    );
    // Initialize categories future and set selected category after loading
    _categoriesFuture = _controller.fetchCategories().then((categories) {
      // Find the matching category in the fetched list
      final matchingCategory = categories.firstWhere(
            (c) => c.categoryId == widget.item.category.categoryId,
        orElse: () => categories.first, // fallback to first if not found
      );
      setState(() {
        _controller.selectedCategory = matchingCategory;
      });
      return categories;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    _controller.pickImage(source);
  }

  void _updateItem() async {
    _controller.updateItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Cập nhật sản phẩm", style:
        TextStyle(
          fontWeight: FontWeight.bold,
        ),)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Item ID (Không cho phép chỉnh sửa)
                      TextFormField(
                        initialValue: widget.item.itemId,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: "Id",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _controller.itemNameController,
                        decoration: const InputDecoration(
                          labelText: "Tên sản phẩm",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _controller.priceController,
                        keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                        decoration: const InputDecoration(
                          labelText: "Giá",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _controller.descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Mô tả",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Category>>(
                        future: _categoriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Lỗi tải danh mục: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Không có danh mục nào.');
                          } else {
                            // Ensure selected category is in the list
                            final categories = snapshot.data!;
                            if (_controller.selectedCategory == null ||
                                !categories.contains(_controller.selectedCategory)) {
                              _controller.selectedCategory = categories.first;
                            }

                            return DropdownButtonFormField<Category>(
                              decoration: const InputDecoration(
                                labelText: "Danh mục",
                                border: OutlineInputBorder(),
                              ),
                              value: _controller.selectedCategory,
                              items: categories.map((category) {
                                return DropdownMenuItem<Category>(
                                  value: category,
                                  child: Text(category.categoryName),
                                );
                              }).toList(),
                              onChanged: (Category? newValue) {
                                setState(() {
                                  _controller.selectedCategory = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Vui lòng chọn danh mục';
                                }
                                return null;
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Phần hiển thị và cập nhật ảnh
                Expanded(
                  child: Center(child: Text("Thêm chức năng upload hình ảnh Web App")),
                  // child: GestureDetector(
                  //   onTap: () {
                  //     showModalBottomSheet(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return SafeArea(
                  //           child: Column(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: <Widget>[
                  //               ListTile(
                  //                 leading: const Icon(Icons.photo_library),
                  //                 title: const Text('Chọn từ thư viện'),
                  //                 onTap: () {
                  //                   _pickImage(ImageSource.gallery);
                  //                   Navigator.pop(context);
                  //                 },
                  //               ),
                  //               ListTile(
                  //                 leading: const Icon(Icons.camera_alt),
                  //                 title: const Text('Chụp ảnh'),
                  //                 onTap: () {
                  //                   _pickImage(ImageSource.camera);
                  //                   Navigator.pop(context);
                  //                 },
                  //               ),
                  //             ],
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  //   child: Container(
                  //     height: 200,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.grey),
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //     child: _controller.pickedImageFile == null
                  //         ? _controller.currentImageUrl != null
                  //         ? ClipRRect(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //       child: Image.network(
                  //         _controller.currentImageUrl!,
                  //         fit: BoxFit.cover,
                  //         width: double.infinity,
                  //         height: double.infinity,
                  //         errorBuilder: (context, error, stackTrace) {
                  //           return const Center(
                  //             child: Icon(
                  //               Icons.image_not_supported_outlined,
                  //               size: 60,
                  //               color: Colors.grey,
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     )
                  //         : const Center(
                  //       child: Icon(
                  //         Icons.image_outlined,
                  //         size: 60,
                  //         color: Colors.grey,
                  //       ),
                  //     )
                  //         : ClipRRect(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //       child: Image.file(
                  //         File(_controller.pickedImageFile!.path),
                  //         fit: BoxFit.cover,
                  //         width: double.infinity,
                  //         height: double.infinity,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Update Button
            ElevatedButton(
              onPressed: _updateItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Cập nhật sản phẩm"),
            ),
          ],
        ),
      ),
    );
  }
}